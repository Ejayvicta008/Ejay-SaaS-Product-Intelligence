
from pathlib import Path
import pandas as pd

PROJECT_DIR = Path(__file__).resolve().parent.parent
RAW_DIR = PROJECT_DIR / "data" / "raw"

files = sorted(RAW_DIR.glob("*.parquet"))

for file in files:
    df = pd.read_parquet(file)

    print("\n" + "=" * 70)
    print(f"TABLE: {file.stem}")
    print("=" * 70)

    for column in df.columns:
        series = df[column]

        print(f"\nColumn: {column}")
        print(f"Data type: {series.dtype}")
        print(f"Null count: {series.isna().sum():,}")
        print(f"Distinct values: {series.nunique(dropna=True):,}")

        if pd.api.types.is_numeric_dtype(series):
            print(f"Minimum: {series.min()}")
            print(f"Maximum: {series.max()}")

        if series.dtype == "object" or isinstance(
            series.dtype, pd.StringDtype
        ):
            lengths = series.dropna().astype(str).str.len()

            if not lengths.empty:
                print(f"Maximum text length: {lengths.max()}")

        if series.dtype == "object":
            print("Sample values:")
            print(series.dropna().head(3).tolist())
