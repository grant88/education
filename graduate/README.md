# Дипломная работа

## Цель: составить документацию процессов ETL на основе датасета [Supermarket](https://www.kaggle.com/aungpyaeap/supermarket-sales?select=supermarket_sales+-+Sheet1.csv)


### Этапы выполнения дипломной работы
* Обработать и проанализировать данные из датасета
* Сформировать нормализованную схему данных (NDS)
* Сформировать состав таблиц фактов и измерений (DDS)
* Сформировать ETL-процессы: для заливки данных в NDS и для создания витрин
* Сформировать набор метрик и дашбордов на их основе
* Оформить результаты, сформулировать выводы

# Инструменты для выполнения задания
  * PostgreSQL - для хранения данных. Развернута в облаке `vk cloud`
  * Python
  * Jupyter Notebook - для анализа данных
  * [dbt](https://docs.getdbt.com/) - для формирования sql запросов
  * [airflow](https://airflow.apache.org/) - для оркестрации ETL
  * docker, docker-compose - развертывание локальной БД (dev+test), airflow окружения
  * git - для версионирования
  * [github pages](https://pages.github.com/) + dbt-docs
  * [DataLens](https://datalens.yandex.ru/) - для создания дашбордов


# Этап 1. Обработка и анализ данных из датасета Supermarket
Этап 1. выполнен в jupyter notebook [step1_analysis.ipynb](step1_analysis.ipynb)

# Этап 2. Формирование схемы звезда в NDS и DDS

`NDS` - normalized data store. Хранилище нормализованных данных — это внутреннее хранилище основных данных в форме одной или нескольких нормализованных реляционных баз данных с целью интеграции данных из различных исходных систем.

`DDS` - detail data store. Представляет собой доступное пользователю хранилище данных в виде одной или нескольких реляционных баз данных, где данные расположены в многомерном формате для поддержки аналитических запросов.

## Общее описание модели данных

Модель потоков данных или `Linage`:
  * `Raw` - данные из систем источников
  * `Staging` - слой предобработанных и очищенных данных
  * `NDS` - данные в 3й нормальной форме, в схеме звезда
  * `DDS` - слой данных для BI систем

![Модель данных](./data/linage.jpg)

## Состав таблиц по схемам в БД:

Описание всех таблиц доступно в самогенерирующейся с помощью [`dbt`](https://docs.getdbt.com/) документации к [DWH Superstore](https://grant88.github.io/#!/overview)
Документация схемы БД доступна по адресу https://grant88.github.io/

* `raw`
  * [supermarket_sales](https://grant88.github.io/#!/source/source.store.raw_data.supermarket_sales)
* `store` Объекты в схеме логически разбиты на предназначения таблиц:
  * `staging`
    * [sales_stg](https://grant88.github.io/#!/model/model.store.sales_stg)
  * `sales`
    * [sales](https://grant88.github.io/#!/model/model.store.sales)
  * `dim` - dimensions, измерения или справочники
    * [customer_type](https://grant88.github.io/#!/model/model.store.customer_type)
    * [payment](https://grant88.github.io/#!/model/model.store.gender)
    * [product_line](https://grant88.github.io/#!/model/model.store.product_line)
    * [supercenter](https://grant88.github.io/#!/model/model.store.supercenter)
    * [gender](https://grant88.github.io/#!/model/model.store.gender)
  * `bi` marts, витрины данных для BI-систем
    * [transactions](https://grant88.github.io/#!/model/model.store.transactions)
    * [transactions_monthly](https://grant88.github.io/#!/model/model.store.transactions_monthly)

![Схема данных хранилища в БД](./data/diagramm3.jpg)

# Этап 3. Формирование витринного слоя данных

TO DO:

# ETL-процессы: для заливки данных в NDS и для создания витрин

TO DO:

# Набор метрик и дашбордов на их основе

TO DO:

```powershell
cd graduate
python -m venv .venv
.venv\Scripts\Activate.ps1
python -m pip install --upgrade pip
pip install dbt-core
pip install dbt-postgres
```


```powershell
cd airflow
docker pull apache/airflow:2.4.2
docker build -t apache/airflow_dbt:2.4.2 .
docker-compose up airflow-init
docker-compose up
```

В контейнере airflow-scheduler 
подкладываем конфигурационный файл `/opt/airflow/dags/dbt/store/profiles.yml`
или на локалхосте 
`graduate\airflow\dags\dbt\store\profiles.yml`

```yml
store:
  outputs:

    dev:
      type: postgres
      threads: 1
      host: localhost
      port: 5432
      user: netology
      pass: netology
      dbname: netology
      schema: store

    prod: # указываются вводные продакшн БД
      type: postgres
      threads: 1
      host: localhost
      port: 5432
      user: netology
      pass: netology
      dbname: netology
      schema: store

  target: prod
```

Поднимается локальная база `dev` для тестирования и разработки
```powershell
docker run -d -p 5432:5432 --name pg -e POSTGRES_PASSWORD=123 postgres:latest
docker exec -it pg /bin/bash
```

В ней производятся нужные манипуляции с созданием БД и настройкой пользователя
```bash
psql -U postgres
create user netology;
create database netology;
GRANT ALL PRIVILEGES ON DATABASE netology TO netology;
ALTER USER netology WITH PASSWORD 'netology';
```


Проверяем настройки dbt локально:
```powershell
cd graduate\airflow\dags\dbt\store
dbt --version
dbt deps
dbt debug
dbt run --vars '{current_date: 2022-08-01}' --target dev
```

Если в локальном контейнере pg проверки dbt прошли успешно, то настраиваем БД в облаке
в соответствии с dbt target prod в конфигурационном файле profiles.yml. Аналогично локальной БД создаем таблицу `raw.supermarket_sales` и загружаем в нее данные

В контейнере airflow_airflow-scheduler_1
```powershell
docker exec -it airflow_airflow-scheduler_1 /bin/bash
```
Проверяем настройки dbt уже на продовой БД:
```bash
cd /opt/airflow/dags/dbt/store
dbt --version
dbt deps
dbt debug
dbt run --vars '{current_date: 2022-08-01}' --target prod
```

Если все прошло успешно, то заходим web UI airflow
по адресу http://localhost:8080/
и активируем `dag store`

Ожидаем наполнения витрин данных 

