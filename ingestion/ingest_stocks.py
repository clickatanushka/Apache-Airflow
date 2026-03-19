import yfinance as yf
import pandas as pd
from sqlalchemy import create_engine
from datetime import datetime, timedelta

TICKERS = ["AAPL", "GOOGL", "MSFT", "AMZN", "META",
           "TSLA", "NFLX", "NVDA", "JPM", "BAC"]

DB_CONN = "postgresql+psycopg2://airflow:airflow@postgres:5432/airflow"

def ingest_stock_data():
    engine = create_engine(DB_CONN)
    end = datetime.today()
    start = end - timedelta(days=90)

    all_data = []
    for ticker in TICKERS:
        df = yf.download(ticker, start=start, end=end, progress=False)
        df = df.reset_index()
        df.columns = ['date', 'open', 'high', 'low', 'close', 'volume']
        df['ticker'] = ticker
        all_data.append(df)

    final_df = pd.concat(all_data, ignore_index=True)
    final_df['ingested_at'] = datetime.now()

    final_df.to_sql(
        'raw_stock_prices',
        engine,
        if_exists='replace',
        index=False,
        schema='public'
    )
    print(f"✅ Ingested {len(final_df)} rows for {len(TICKERS)} tickers")

if __name__ == "__main__":
    ingest_stock_data()