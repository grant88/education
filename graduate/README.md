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

![Схема данных хранилища в БД](./data/diagramm.jpg)


# ETL-процессы: для заливки данных в NDS и для создания витрин

Запуск ETL процессов происходит каждый день утром в 05:00 с помощью airflow

DAG этого процесса находится в файле [insert.py](./airflow/dags/insert.py)

Airflow будет запущен в контейнере на хосте localhost, для этого скачаем образ airflow c dockerhub

```powershell
docker pull apache/airflow:2.4.2
```

Создадим на его основе свой докер-образ `apache/airflow_dbt:2.4.2` в который доустановим dbt. Описание этого образа находится в файле [Dockerfile](./airflow/Dockerfile)

```powershell
cd airflow
docker build -t apache/airflow_dbt:2.4.2 .
```

После создания образа запустим airflow и его сервисы с помощью docker-compose. Конфигурация запуска находится в [docker-compose.yaml](./airflow/docker-compose.yaml)

```powershell
docker-compose up airflow-init
docker-compose up
```

Для работы dbt необходимо настроить конфигурационный файл [profiles.yml](./airflow/dags/dbt/store/profiles.yml) в котором указываются данные для подключения к БД хранилища. БД хранилища развернута в облаке. 

Пример заполнения файла `profiles.yml`:
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

В контейнере `airflow-scheduler` файл конфигурации dbt подключений `profiles.yml` будет доступен по пути `/opt/airflow/dags/dbt/store/profiles.yml` поскольку каталог
`./airflow/dags` в контейнере монтируется как volume в каталог `/opt/airflow/dags`

Подключимся к контейнеру `airflow-scheduler`:
```powershell
docker exec -it airflow_airflow-scheduler_1 /bin/bash
```

Если все прошло успешно, то заходим web UI airflow
по адресу http://localhost:8080/
и активируем DAG `store`

![DAG store](./data/airflow_dag.jpg)

После активации дага он будет итеративно наполнять хранилище данных
![DAG runs](./data/airflow_runs.jpg)

Календарь ежедневного наполнения данных будет выглядеть следующим образом:
![DAG calendar](./data/airflow_calendar.jpg)

Во время первого запуска dbt на основании sql выражений создаст таблицы:
![Таблицы](./data/tables.jpg)

Во время последующих итеративных запусков dbt уже не будет создавать эти таблицы, а будет их итеративно дополнять

Этот процесс будет актуален для таблицы фактов `sales`, стейджинговой витрины `sales_stg`, BI-витрины `transactions` а также для всех таблиц-измерений:
  * [customer_type](https://grant88.github.io/#!/model/model.store.customer_type)
  * [payment](https://grant88.github.io/#!/model/model.store.gender)
  * [product_line](https://grant88.github.io/#!/model/model.store.product_line)
  * [supercenter](https://grant88.github.io/#!/model/model.store.supercenter)
  * [gender](https://grant88.github.io/#!/model/model.store.gender)

Поэтому эти таблицы объединены общим свойством `incremental`:
```sql
{{
    config(
        materialized='incremental'
    )
}}
```
На основании этой настройки dbt в первый запуск создает таблицы с данными, в последующие запуски дополняет их инкрементально


# Этап 3. Формирование витринного слоя данных

Витринный слой данных для BI-систем состоит из двух таблиц-витрин:
* [transactions](https://grant88.github.io/#!/model/model.store.transactions)
* [transactions_monthly](https://grant88.github.io/#!/model/model.store.transactions_monthly)

Витирну [transactions_monthly](https://grant88.github.io/#!/model/model.store.transactions_monthly) отличает свойство материализации `table`
```sql
{{
    config(
        materialized='table'
    )
}}
```
Это свойство материализации витрины позволяет пересоздавать её данных каждый раз с появлением новых данных. Это бывает актуально например для неаддитивных метрик, которые должны отражать полные данные за неполный месяц, при условии, что витрина - по месяцам.

# Набор метрик и дашбордов на их основе

Дашборды созданы при помощи - DataLens. Выбор пал на этот инструмент потому что:
* сейчас Tableau не доступен на рынке РФ
* он бесплатный
* простой в использовании

# Документация объектов хранилища данных

Документация хранилища опубликована по адресу: https://grant88.github.io

Она формируется автоматически с помощью утилиты `dbt docs` на основании метаданных, описанных в файлах: 
* [staging_schema.yml](./airflow/dags/dbt/store/models/staging/staging_schema.yml)
* [dim_schema.yml](./airflow/dags/dbt/store/models/staging/dim_schema.yml)
* [marts_schema.yml](./airflow/dags/dbt/store/models/staging/marts_schema.yml)
* [bi_schema.yml](./airflow/dags/dbt/store/models/staging/bi_schema.yml)

## Использование этого инструмента позволяет:
* автоматически генерировать документацию
* запускать вебсервер с документацией
* отображать на вебстраницах:
  * общее описание хранилища, в нашем случае - `Supermarket store`
  * comments к объектам хранилища, в том числе автоматически оставлять COMMENT на колонке в объекте БД
  * comments к колонкам таблиц хранилища, в том числе автоматически оставлять COMMENT на колонке в объекте БД
  * взаимосвязи объектов - linage
  * типы данных столбцов объектов
  * тесты Data Quality, например
    * unique
    * not null
  * sql-скрипты, которые показывают трансформации в ELT в двух видах:
    * в конечном виде (compiled)
    * в виде шаблона jinja (templated)

### Формат файлов описания метаданных:
```yml
version: 2

models: # перечисляются логически объединненые таблицы, например, таблицы фактов
  - name: sales # наименование таблицы
    description: > # описание таблицы, будет также отражено в DDL комментариях к таблице
      This is sales main fact table 
    docs: # цвет таблицы на схемах с linage
      node_color: "#cd7f32"
    columns: # перечисляются все столбцы объекта
      - name: id
        description: incremental id # будет отражено также в DDL комментариях к столбцу таблицы
        tests: # базовые тесты Data Quality, также можно сюда указать custom tests
          - unique
          - not_null
      - name: invoice_id
        description: '{{ doc("invoice_id") }}' # описание для общего атрибута можно задать один раз, и использвать для в других таблицах
        tests:
          - unique
          - not_null
```

Для ее запуска необходимо выполнить:
```bash
dbt docs generate
```
Метаданные появятся в каталоге target в домашнем каталоге `dbt`- проекта: `/opt/airflow/dbt/store/target`

После этого остается перенести данные из каталога `target` на хостинг, либо локально запустить вебсервер:
```bash
dbt docs serve --port 8001
```
и перейти по адресу https://localhost:8001

## На примере одного объекта БД - таблица фактов `sales` рассмотрим, что отображает документация:

![Docs common](./data/docs_common.jpg)

Можно увидеть SQL код для трансформаций в ELT-процессе:
![Docs sql](./data/docs_sql.jpg)

Описание тестов Data Quality, constraints, зависимостей:
![Docs tests](./data/docs_tests.jpg)

Также можно отследить трансформации данных от самого источника:
![Docs linage](./data/docs_linage.jpg)

![Docs linage2](./data/docs_linage2.jpg)

