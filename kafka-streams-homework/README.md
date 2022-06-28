Инструкция:
* Скачать
* Поднять кластер кафки docker-compose.yaml
`docker-compose up -d`
* В Kafka Connect создать producer purchases_total из схемы purchases_total.avsc. Указать ключ - purchase_id.
* Запустить AmountAlertsAppTest
* Запустить AmountAlertsApp
* Появится топик amount_alerts-dsl с сообщениями - алертами
* Потушить кластер `docker-compose down`
