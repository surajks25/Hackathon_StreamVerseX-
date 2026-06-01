from airflow import DAG
from airflow.providers.standard.operators.python import PythonOperator
from datetime import datetime


def hello_streamversex():
    print("StreamVerseX Airflow DAG is running!")


with DAG(
    dag_id="streamversex_dag",
    start_date=datetime(2025, 1, 1),
    schedule=None,
    catchup=False,
) as dag:

    hello_task = PythonOperator(
        task_id="hello_task",
        python_callable=hello_streamversex,
    )