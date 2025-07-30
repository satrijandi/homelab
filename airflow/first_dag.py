from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.bash import BashOperator

# Define default arguments for the DAG
default_args = {
    'owner': 'admin',
    'depends_on_past': False,
    'start_date': datetime(2025, 7, 30),
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG
dag = DAG(
    'first_dag_hello_world',
    default_args=default_args,
    description='Simple Hello World DAG',
    schedule=None,  # Manual trigger only
    catchup=False,
    tags=['tutorial', 'hello_world'],
)

# Define a simple bash task
hello_world_task = BashOperator(
    task_id='hello_world_bash',
    bash_command='echo "Hello World from Airflow!"',
    dag=dag,
)

# Single task DAG - no dependencies needed
hello_world_task