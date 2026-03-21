import requests
import pandas as pd
from sqlalchemy import create_engine
from datetime import datetime
import time

TICKERS = [
    "AAPL",
    "GOOGL",
    "MSFT",
    "AMZN",
    "META",
    "TSLA",
    "NFLX",
    "NVDA",
    "JPM",
    "BAC",
]

API_KEY = "OLJQTFIJFNWPOOSS"
DB_CONN = "postgresql+psycopg2://airflow:airflow@postgres:5432/airflow"


def ingest_stock_data():
    engine = create_engine(DB_CONN)
    all_data = []

    for ticker in TICKERS:
        print(f"Fetching {ticker}...")
        url = f"https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol={ticker}&outputsize=compact&apikey={API_KEY}"
        response = requests.get(url)
        data = response.json()

        if "Time Series (Daily)" not in data:
            print(
                f"⚠️ Skipping {ticker}: {data.get('Note') or data.get('Information') or 'unknown error'}"
            )
            continue

        ts = data["Time Series (Daily)"]
        rows = []
        for date_str, values in ts.items():
            rows.append(
                {
                    "date": date_str,
                    "open": float(values["1. open"]),
                    "high": float(values["2. high"]),
                    "low": float(values["3. low"]),
                    "close": float(values["4. close"]),
                    "volume": int(values["5. volume"]),
                    "ticker": ticker,
                }
            )
        df = pd.DataFrame(rows)
        all_data.append(df)
        print(f"✅ {ticker}: {len(df)} rows")
        time.sleep(12)

    if not all_data:
        raise Exception("No data fetched for any ticker!")

    final_df = pd.concat(all_data, ignore_index=True)
    final_df["ingested_at"] = datetime.now()

    final_df.to_sql(
        "raw_stock_prices", engine, if_exists="replace", index=False, schema="public"
    )
    print(f"✅ Total: {len(final_df)} rows for {len(all_data)} tickers")


if __name__ == "__main__":
    ingest_stock_data()
