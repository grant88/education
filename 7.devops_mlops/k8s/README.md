## Что такое k8s?
Это ПО для автоматизации, развертывания и управления контейниризированными приложениями
Возможности:
* мониторинг сервисов
* балансировка нагрузки
* автоматическое управление хранилищами (монтирование)
* автоматическое создание и развертывание контейнеров
* автоматический перезапуск
* healthchecks
* хранение credentials

## В чём преимущество контейнеризации над виртуализацией?
Затраты (трудозатраты, ПО, hardware) на создание, запуск, хранение, передачу, миграцию с железа на железо контейнеров намного ниже, чем те же действия с виртуальными машинами в гипервизоре.

## В чём состоит принцип самоконтроля k8s?
Если в кластере k8s какой-либо контейнер становится неработающим, то k8s автоматически обнаруживает это и пытается перезапустить неработающий контейнер

## Как вы думаете, зачем Вам понимать принципы деплоя в k8s?
Принципы деплоя в k8s необходимо понимать, чтобы при разработке приложений заложиться но то, чтобы эти приложения можно было органично встроить в работающий на k8s техпроцесс


## Какое из средств управления секретами наиболее распространено в использовании совместно с k8s?
* Kubernetes Secret:
    * generic - хранение паролей/токенов
    * docker-registry - данные авторизаций
    * tls - сертификаты

* HashiCorp Vault - как альтернатива Kubernetes Secret
