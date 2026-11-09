
from pathlib import Path
import pandas as pd

# Project directory
PROJECT_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_DIR / "data" / "raw"

files = [
    "plans.parquet",
    "organizations.parquet",
    "users.parquet",
    "subscriptions.parquet",
    "invoices.parquet",
    "usage_events.parquet"
]

print("=" * 60)
print("SAAS PRODUCT INTELLIGENCE - DATA PROFILING")
print("=" * 60)

for file in files:

    file_path = RAW_DIR / file

    print(f"\n{'=' * 60}")
    print(f"TABLE: {file}")
    print("=" * 60)

    if not file_path.exists():
        print("FILE NOT FOUND!")
        continue

    df = pd.read_parquet(file_path)

    print(f"Rows: {len(df):,}")
    print(f"Columns: {len(df.columns)}")
    print(f"File size: {file_path.stat().st_size / 1024:.2f} KB")

    print("\nCOLUMN INFORMATION:")
    print(df.dtypes)

    print("\nNULL VALUES:")
    print(df.isnull().sum())

    print("\nDUPLICATE ROWS:")
    print(df.duplicated().sum())

    print("\nSAMPLE RECORDS:")
    print(df.head(5).to_string(index=False))

print("\n" + "=" * 60)
print("PROFILING COMPLETED")
print("=" * 60)
