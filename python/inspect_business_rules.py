
from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_DIR / "data" / "raw"

# Load datasets
plans = pd.read_parquet(RAW_DIR / "plans.parquet")
organizations = pd.read_parquet(RAW_DIR / "organizations.parquet")
users = pd.read_parquet(RAW_DIR / "users.parquet")
subscriptions = pd.read_parquet(RAW_DIR / "subscriptions.parquet")
invoices = pd.read_parquet(RAW_DIR / "invoices.parquet")
events = pd.read_parquet(RAW_DIR / "usage_events.parquet")


def show_values(df, column, label):
    print(f"\n{label}")
    print(df[column].value_counts(dropna=False).to_string())


def check_dates(df, columns, table_name):
    print(f"\n--- {table_name}: DATE VALIDATION ---")

    for column in columns:
        dates = pd.to_datetime(df[column], errors="coerce")

        print(f"\n{column}")
        print(f"Invalid dates: {dates.isna().sum():,}")

        if dates.notna().any():
            print(f"Earliest: {dates.min()}")
            print(f"Latest:   {dates.max()}")


print("=" * 60)
print("BUSINESS RULE VALIDATION")
print("=" * 60)

# 1. Categorical values
show_values(plans, "tier", "PLAN TIERS")
show_values(plans, "billing_interval", "BILLING INTERVALS")
show_values(organizations, "industry", "INDUSTRIES")
show_values(organizations, "country", "COUNTRIES")
show_values(organizations, "acquisition_channel", "ACQUISITION CHANNELS")
show_values(users, "role", "USER ROLES")
show_values(subscriptions, "cancel_reason", "CANCELLATION REASONS")
show_values(invoices, "status", "INVOICE STATUSES")
show_values(events, "event_type", "EVENT TYPES")

# 2. Date validation
check_dates(
    organizations,
    ["signed_up_on"],
    "ORGANIZATIONS"
)

check_dates(
    users,
    ["joined_on", "deactivated_on"],
    "USERS"
)

check_dates(
    subscriptions,
    ["started_on", "ended_on"],
    "SUBSCRIPTIONS"
)

check_dates(
    invoices,
    ["issued_on", "period_start", "period_end", "paid_on"],
    "INVOICES"
)

# 3. Subscription date logic
sub_start = pd.to_datetime(subscriptions["started_on"], errors="coerce")
sub_end = pd.to_datetime(subscriptions["ended_on"], errors="coerce")

print("\n--- SUBSCRIPTION DATE LOGIC ---")
print("End date before start date:", (sub_end < sub_start).sum())

# 4. User date logic
user_joined = pd.to_datetime(users["joined_on"], errors="coerce")
user_deactivated = pd.to_datetime(users["deactivated_on"], errors="coerce")

print("\n--- USER DATE LOGIC ---")
print("Deactivation before joining:", (user_deactivated < user_joined).sum())

# 5. Invoice amount validation
invoice_amount = pd.to_numeric(invoices["amount"], errors="coerce")

print("\n--- INVOICE AMOUNT VALIDATION ---")
print("Non-numeric amounts:", invoice_amount.isna().sum())
print("Zero amounts:", (invoice_amount == 0).sum())
print("Negative amounts:", (invoice_amount < 0).sum())
print("Minimum amount:", invoice_amount.min())
print("Maximum amount:", invoice_amount.max())

# 6. Usage event validation
print("\n--- USAGE EVENT VALIDATION ---")
print("Zero quantities:", (events["quantity"] == 0).sum())
print("Negative quantities:", (events["quantity"] < 0).sum())

# 7. Verify user belongs to the same organization as the event
event_users = events.dropna(subset=["user_id"]).copy()

event_users["user_id"] = event_users["user_id"].astype("int64")

user_org = users[["user_id", "organization_id"]]

event_check = event_users.merge(
    user_org,
    on="user_id",
    how="left",
    suffixes=("_event", "_user")
)

mismatches = event_check[
    event_check["organization_id_event"]
    != event_check["organization_id_user"]
]

print("\n--- EVENT USER-ORGANIZATION VALIDATION ---")
print("Events with user IDs:", len(event_users))
print("Organization mismatches:", len(mismatches))

print("\n" + "=" * 60)
print("BUSINESS RULE VALIDATION COMPLETED")
print("=" * 60)
