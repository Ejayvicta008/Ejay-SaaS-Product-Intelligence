
from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_DIR / "data" / "raw"
OUTPUT_DIR = PROJECT_DIR / "data" / "processed"

OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

# Load datasets
users = pd.read_parquet(RAW_DIR / "users.parquet")
subscriptions = pd.read_parquet(RAW_DIR / "subscriptions.parquet")
invoices = pd.read_parquet(RAW_DIR / "invoices.parquet")
plans = pd.read_parquet(RAW_DIR / "plans.parquet")
events = pd.read_parquet(RAW_DIR / "usage_events.parquet")
organizations = pd.read_parquet(RAW_DIR / "organizations.parquet")

print("=" * 60)
print("ANOMALY INVESTIGATION")
print("=" * 60)

# 1. Missing vs genuinely invalid dates
print("\n1. DATE VALIDATION")

date_checks = {
    "users": (users, ["joined_on", "deactivated_on"]),
    "subscriptions": (subscriptions, ["started_on", "ended_on"]),
    "invoices": (invoices, ["issued_on", "paid_on"])
}

for table_name, (df, columns) in date_checks.items():

    for column in columns:

        original = df[column]
        parsed = pd.to_datetime(original, errors="coerce")

        missing = original.isna().sum()
        invalid = (original.notna() & parsed.isna()).sum()

        print(
            f"{table_name}.{column}: "
            f"Missing={missing:,}, Invalid={invalid:,}"
        )

# 2. Subscription end date before start date
subscriptions["started_on"] = pd.to_datetime(
    subscriptions["started_on"]
)

subscriptions["ended_on"] = pd.to_datetime(
    subscriptions["ended_on"]
)

bad_subscriptions = subscriptions[
    subscriptions["ended_on"].notna()
    & (subscriptions["ended_on"] < subscriptions["started_on"])
]

bad_subscriptions.to_csv(
    OUTPUT_DIR / "anomaly_subscriptions_invalid_dates.csv",
    index=False
)

print("\n2. INVALID SUBSCRIPTION DATES")
print(f"Records: {len(bad_subscriptions)}")
print(bad_subscriptions.to_string(index=False))

# 3. User deactivation before joining
users["joined_on"] = pd.to_datetime(users["joined_on"])
users["deactivated_on"] = pd.to_datetime(users["deactivated_on"])

bad_users = users[
    users["deactivated_on"].notna()
    & (users["deactivated_on"] < users["joined_on"])
]

bad_users.to_csv(
    OUTPUT_DIR / "anomaly_users_invalid_dates.csv",
    index=False
)

print("\n3. INVALID USER DATES")
print(f"Records: {len(bad_users)}")
print(bad_users.to_string(index=False))

# 4. Zero-value invoices by status and plan
invoices["amount"] = pd.to_numeric(invoices["amount"])

invoice_details = (
    invoices
    .merge(subscriptions[["subscription_id", "plan_id"]], on="subscription_id")
    .merge(plans[["plan_id", "plan_name", "tier"]], on="plan_id")
)

zero_invoices = invoice_details[invoice_details["amount"] == 0]

zero_summary = zero_invoices.groupby(
    ["status", "plan_name", "tier"],
    dropna=False
).size().reset_index(name="invoice_count")

zero_summary.to_csv(
    OUTPUT_DIR / "analysis_zero_invoices.csv",
    index=False
)

print("\n4. ZERO-VALUE INVOICES BY STATUS AND PLAN")
print(zero_summary.to_string(index=False))

# 5. Missing payment date by invoice status
payment_summary = invoices.groupby(
    "status",
    dropna=False
).agg(
    total_invoices=("invoice_id", "count"),
    missing_payment_dates=("paid_on", lambda x: x.isna().sum())
).reset_index()

print("\n5. PAYMENT DATE BY STATUS")
print(payment_summary.to_string(index=False))

# 6. Missing user IDs by event type
event_summary = events.groupby(
    "event_type"
).agg(
    total_events=("event_id", "count"),
    missing_user_ids=("user_id", lambda x: x.isna().sum())
).reset_index()

print("\n6. MISSING USER IDS BY EVENT TYPE")
print(event_summary.to_string(index=False))

# 7. Missing cancellation reasons by subscription end status
print("\n7. SUBSCRIPTION END DATE AND CANCELLATION REASON")

print(
    subscriptions.groupby(
        [
            subscriptions["ended_on"].isna().map({
                True: "No end date",
                False: "Has end date"
            }),
            subscriptions["cancel_reason"].isna().map({
                True: "No cancellation reason",
                False: "Has cancellation reason"
            })
        ]
    ).size().to_string()
)

print("\n" + "=" * 60)
print("ANOMALY INVESTIGATION COMPLETED")
print(f"Output folder: {OUTPUT_DIR}")
print("=" * 60)
