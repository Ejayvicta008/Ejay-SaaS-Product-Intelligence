
import pandas as pd
from sqlalchemy import create_engine, text
from urllib.parse import quote_plus
from pathlib import Path

# --------------------------------------------------
# CONFIGURATION
# --------------------------------------------------

PROJECT_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_DIR / "data" / "raw"

SERVER = r"DESKTOP-SNC6AI8\SQLEXPRESS"
DATABASE = "Ejay_SaaS_Product_Intelligence"
DRIVER = "ODBC Driver 18 for SQL Server"

connection_string = (
    f"DRIVER={{{DRIVER}}};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    "Trusted_Connection=yes;"
    "TrustServerCertificate=yes;"
)

connection_url = (
    "mssql+pyodbc:///?odbc_connect="
    + quote_plus(connection_string)
)

engine = create_engine(
    connection_url,
    fast_executemany=False
)

# --------------------------------------------------
# SOURCE TO TARGET MAPPING
# --------------------------------------------------

TABLES = {
    "plans.parquet": "Plans",
    "organizations.parquet": "Organizations",
    "users.parquet": "Users",
    "subscriptions.parquet": "Subscriptions",
    "invoices.parquet": "Invoices",
    "usage_events.parquet": "Usage_Events"
}

# --------------------------------------------------
# TEST CONNECTION
# --------------------------------------------------

print("Testing SQL Server connection...")

with engine.connect() as connection:
    result = connection.execute(text("SELECT 1"))
    print("Connection successful:", result.scalar())

# --------------------------------------------------
# LOAD DATA
# --------------------------------------------------

print("\nStarting data ingestion...")

for file_name, table_name in TABLES.items():

    file_path = RAW_DIR / file_name

    print(f"\nLoading {file_name}...")

    if not file_path.exists():
        print(f"ERROR: File not found: {file_path}")
        continue

    df = pd.read_parquet(file_path)

    source_count = len(df)

    # Check if staging table is empty
    with engine.connect() as connection:
        existing_count = connection.execute(
            text(f"SELECT COUNT(*) FROM stg.[{table_name}]")
        ).scalar()

    if existing_count > 0:
        print(f"SKIPPED: {table_name} already contains {existing_count:,} rows.")
        continue

    # Load data into SQL Server
    df.to_sql(
        name=table_name,
        con=engine,
        schema="stg",
        if_exists="append",
        index=False,
        chunksize=1000,
        method=None
    )

    # Validate SQL Server row count
    with engine.connect() as connection:
        target_count = connection.execute(
            text(f"SELECT COUNT(*) FROM stg.[{table_name}]")
        ).scalar()

    print(f"Source rows: {source_count:,}")
    print(f"SQL rows:    {target_count:,}")

    if source_count == target_count:
        print("STATUS: SUCCESS")
    else:
        print("STATUS: ROW COUNT MISMATCH")

print("\nData ingestion completed.")

engine.dispose()
