
from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_DIR / "data" / "raw"

# Load source files
plans = pd.read_parquet(RAW_DIR / "plans.parquet")
organizations = pd.read_parquet(RAW_DIR / "organizations.parquet")
users = pd.read_parquet(RAW_DIR / "users.parquet")
subscriptions = pd.read_parquet(RAW_DIR / "subscriptions.parquet")
invoices = pd.read_parquet(RAW_DIR / "invoices.parquet")
usage_events = pd.read_parquet(RAW_DIR / "usage_events.parquet")

print("=" * 60)
print("PRIMARY KEY VALIDATION")
print("=" * 60)

primary_keys = {
    "plans": (plans, "plan_id"),
    "organizations": (organizations, "organization_id"),
    "users": (users, "user_id"),
    "subscriptions": (subscriptions, "subscription_id"),
    "invoices": (invoices, "invoice_id"),
    "usage_events": (usage_events, "event_id")
}

for table_name, (df, key) in primary_keys.items():
    null_count = df[key].isna().sum()
    duplicate_count = df[key].duplicated().sum()

    print(f"\n{table_name}")
    print(f"Null primary keys: {null_count}")
    print(f"Duplicate primary keys: {duplicate_count}")

print("\n" + "=" * 60)
print("FOREIGN KEY VALIDATION")
print("=" * 60)


def check_relationship(child_df, child_column, parent_df, parent_column, label):

    child_values = child_df[child_column].dropna()

    invalid = ~child_values.isin(parent_df[parent_column])

    print(f"\n{label}")
    print(f"Total non-null references: {len(child_values):,}")
    print(f"Orphan references: {invalid.sum():,}")


check_relationship(
    users, "organization_id",
    organizations, "organization_id",
    "Users -> Organizations"
)

check_relationship(
    subscriptions, "organization_id",
    organizations, "organization_id",
    "Subscriptions -> Organizations"
)

check_relationship(
    subscriptions, "plan_id",
    plans, "plan_id",
    "Subscriptions -> Plans"
)

check_relationship(
    invoices, "subscription_id",
    subscriptions, "subscription_id",
    "Invoices -> Subscriptions"
)

check_relationship(
    usage_events, "organization_id",
    organizations, "organization_id",
    "Usage Events -> Organizations"
)

check_relationship(
    usage_events, "user_id",
    users, "user_id",
    "Usage Events -> Users"
)

print("\n" + "=" * 60)
print("RELATIONSHIP VALIDATION COMPLETED")
print("=" * 60)
