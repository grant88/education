import datetime

import pendulum

from airflow import DAG
from airflow import macros
from airflow.operators.bash import BashOperator

with DAG(
    dag_id='insert_supermarket',
    schedule='0 0 * * *',
    start_date=pendulum.datetime(2022, 8, 1, tz="UTC"),
    catchup=False,
    dagrun_timeout=datetime.timedelta(minutes=60),
    tags=['raw'],
) as dag:

    current_date = "{{ (data_interval_start + macros.timedelta(hours=3)).strftime('%Y-%m-%d') }}"
    dbt_yml = "{current_date: " + current_date + "}"

    dbt_run_current_date = BashOperator(
        task_id='dbt_run_current_date',
        bash_command=f"dbt run --vars '{dbt_yml}'",
    )

    dbt_run_current_date
