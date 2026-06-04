from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime


with DAG(
    dag_id="streamversex_dag",
    start_date=datetime(2025, 1, 1),
    schedule="@daily",
    catchup=False,
) as dag:

    kafka_producer = BashOperator(
        task_id="run_kafka_producer",
        bash_command="python /opt/airflow/dags/kafka_producer.py",
    )