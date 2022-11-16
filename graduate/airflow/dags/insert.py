import datetime

from airflow import DAG
from airflow import macros
from airflow.operators.bash import BashOperator

from textwrap import dedent

with DAG(
    dag_id='store',
    default_args={
        'depends_on_past': False,
        'email': ['airflow@example.com'],
        'email_on_failure': False,
        'email_on_retry': False,
        'retries': 1,
    },
    description='A dbt run DAG',
    schedule='0 5 * * *',
    start_date=datetime.datetime(2022, 8, 1),
    end_date=datetime.datetime(2022, 11, 1),
    max_active_runs=1,
    catchup=True
) as dag:

    DBT_DIR = "/opt/airflow/dags/dbt/store"
    DBT_PROFILES_DIR = DBT_DIR
    DBT_PROFILE_TARGET = "prod"
    current_date = "{{ (data_interval_start + macros.timedelta(hours=3)).strftime('%Y-%m-%d') }}"
    dbt_yml = "{current_date: " + current_date + "}"

    dbt_run_current_date = BashOperator(
        task_id='dbt_run_current_date',
        bash_command=f"dbt run --vars '{dbt_yml}' --profile store --project-dir {DBT_DIR} --profiles-dir {DBT_PROFILES_DIR} -t {DBT_PROFILE_TARGET}",
    )

    dbt_run_current_date.doc_md = dedent(
        """\
    #### Task Documentation
    This is a simple dbt run documentation
    """
    )

    dbt_run_current_date
