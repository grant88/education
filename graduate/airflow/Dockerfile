FROM apache/airflow:2.4.2
RUN python -m pip install --upgrade pip
RUN pip install dbt-core dbt-postgres
RUN dbt deps
RUN apt update && apt install git vim