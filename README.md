# 📈 Financial Market Analytics Pipeline

An end-to-end **batch data engineering pipeline** that ingests daily stock market data, transforms it through layered dbt models, and orchestrates the entire workflow with Apache Airflow — all containerized with Docker.

> Built as a companion project to a [real-time streaming pipeline](https://github.com/clickatanushka/KafkaStockMarketETL) using Apache Kafka & Flink, this project covers the **batch processing** side of the modern data engineering stack.

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Apache Airflow                           │
│                                                                 │
│   ┌─────────────────┐    ┌──────────────┐    ┌──────────────┐  │
│   │ ingest_raw_data │ >> │ run_dbt_     │ >> │ test_dbt_    │  │
│   │ (PythonOperator)│    │ models       │    │ models       │  │
│   └────────┬────────┘    └──────┬───────┘    └──────────────┘  │
└────────────│──────────────────  │ ───────────────────────────── ┘
             │                   │
             ▼                   ▼
   ┌──────────────────┐   ┌──────────────────────────────────────┐
   │  Alpha Vantage   │   │           PostgreSQL                  │
   │  Stock Market    │   │                                       │
   │  API             │   │  public.raw_stock_prices  (raw)       │
   └──────────────────┘   │  analytics.stg_stock_prices (view)   │
                          │  analytics.int_stock_metrics (view)  │
                          │  analytics.stock_performance (table) │
                          └──────────────────────────────────────┘
```

---

## ⚙️ Tech Stack

| Layer | Tool |
|---|---|
| Orchestration | Apache Airflow 2.6 |
| Transformation | dbt (data build tool) 1.5 |
| Database | PostgreSQL 15 |
| Data Source | Alpha Vantage API |
| Containerization | Docker & Docker Compose |
| Language | Python 3.9, SQL |

---

## 📊 Data Flow

### 1. Ingestion
Daily OHLCV (Open, High, Low, Close, Volume) data is fetched for **10 major stocks** using the Alpha Vantage API and loaded into PostgreSQL as raw data.

**Tickers:** `AAPL, GOOGL, MSFT, AMZN, META, TSLA, NFLX, NVDA, JPM, BAC`

### 2. Transformation (dbt)
Data flows through three dbt model layers:

```
raw_stock_prices
      │
      ▼
stg_stock_prices        ← type casting, null filtering, renaming
      │
      ▼
int_stock_metrics       ← 7-day moving average, daily returns, 30-day volatility
      │
      ▼
stock_performance       ← final analytics table with trend signals (ABOVE_MA / BELOW_MA)
```
<img width="658" height="602" alt="image" src="https://github.com/user-attachments/assets/3f7bd67c-fb22-4746-ae78-c300d94f674e" />


### 3. Orchestration (Airflow)
A DAG runs daily at 6PM on weekdays (after US market close) with automatic retries and task dependency management.

```python
ingest_raw_stock_data >> run_dbt_models >> test_dbt_models
```
<img width="929" height="649" alt="image" src="https://github.com/user-attachments/assets/37fec3e3-a78f-447b-8c01-a8003a7f6b4e" />

---

## 📁 Project Structure

```
financial-data-pipeline/
│
├── docker-compose.yml              # Airflow + PostgreSQL setup
├── .env                            # Credentials (gitignored)
│
├── dags/
│   └── stock_pipeline_dag.py       # Airflow DAG definition
│
├── ingestion/
│   └── ingest_stocks.py            # Alpha Vantage → PostgreSQL
│
├── dbt_project/
│   ├── dbt_project.yml
│   ├── profiles.yml                # DB connection (gitignored)
│   └── models/
│       ├── staging/
│       │   ├── sources.yml
│       │   └── stg_stock_prices.sql
│       ├── intermediate/
│       │   └── int_stock_metrics.sql
│       └── marts/
│           └── stock_performance.sql
│
└── dashboard/
    └── screenshots/                # Metabase dashboard screenshots
```

---

## 🚀 Getting Started

### Prerequisites
- Docker & Docker Compose
- Alpha Vantage API key (free at [alphavantage.co](https://www.alphavantage.co))

### Setup

**1. Clone the repo**
```bash
git clone https://github.com/AnushkaJoshi14/financial-data-pipeline.git
cd financial-data-pipeline
```

**2. Add your API key to `.env`**
```bash
ALPHA_VANTAGE_API_KEY=your_api_key_here
```

**3. Initialize Airflow**
```bash
sudo chmod -R 777 logs
docker compose up airflow-init
```

**4. Start all services**
```bash
docker compose up -d
```

**5. Access Airflow UI**
```
http://localhost:8080
Username: admin
Password: admin
```

**6. Trigger the pipeline**
```bash
docker compose exec airflow-scheduler airflow dags unpause stock_market_pipeline
docker compose exec airflow-scheduler airflow dags trigger stock_market_pipeline
```

---

## 📐 dbt Models

### `stg_stock_prices` (view)
Cleans raw data — casts types, renames columns, filters nulls.

### `int_stock_metrics` (view)
Computes key financial metrics using window functions:
- **7-day moving average** — smooths price noise
- **Daily return %** — day-over-day price change
- **30-day volatility** — rolling standard deviation of close price

### `stock_performance` (table)
Final analytics-ready table with a **trend signal**:
- `ABOVE_MA` — price is above the 7-day moving average (bullish signal)
- `BELOW_MA` — price is below the 7-day moving average (bearish signal)

---

## 🔍 Sample Output


```
 ticker | price_date | close_price | moving_avg_7d | trend_signal 
--------+------------+-------------+---------------+--------------
 AAPL   | 2026-03-19 |      222.13 |        219.45 | ABOVE_MA
 NVDA   | 2026-03-19 |      876.34 |        891.20 | BELOW_MA
 MSFT   | 2026-03-19 |      415.67 |        412.33 | ABOVE_MA
```


---

## 👩‍💻 Author

**Anushka Joshi**  
B.Tech CSE (Data Science) — Bennett University  
[LinkedIn](https://linkedin.com/in/anushkajoshi) • [GitHub](https://github.com/AnushkaJoshi14) • anushka14joshi@gmail.com
