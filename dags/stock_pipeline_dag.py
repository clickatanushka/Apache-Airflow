from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    "owner": "anushka",
    "retries": 2,
    "retry_delay": timedelta(minutes=5),
    "email_on_failure": False,
}

with DAG(
    dag_id="stock_market_pipeline",
    default_args=default_args,
    description="Daily stock data ingestion and transformation",
    schedule_interval="0 18 * * 1-5",
    start_date=datetime(2024, 1, 1),
    catchup=False,
    tags=["finance", "dbt", "stocks"],
) as dag:

    ingest_task = BashOperator(
        task_id="ingest_raw_stock_data",
        bash_command="python /opt/airflow/ingestion/ingest_stocks.py",
    )

    dbt_run = BashOperator(
        task_id="run_dbt_models",
        bash_command="cd /opt/airflow/dbt_project && dbt run --profiles-dir .",  # noqa: E501
    )

    dbt_test = BashOperator(
        task_id="test_dbt_models",
        bash_command="cd /opt/airflow/dbt_project && dbt test --profiles-dir .",  # noqa: E501
    )

    ingest_task >> dbt_run >> dbt_test
