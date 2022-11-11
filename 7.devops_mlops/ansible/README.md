# Установка ПО на удаленных серверах с помощью Ansible 

## Prerequisites
Нужны поднятые 2 виртуальные машины, с ip адресами, до которых можно достучаться, например в облаке
В нашем случае это
* 158.160.3.99
* 158.160.10.238
Желательно с пользователем `ansible`

## Развертывание окружения
```powershell
docker pull ubuntu:latest
docker run -it ubuntu
```

## Генерация ssh ключей
Для доступа с помощью ansible до виртуальных машин по ssh в случае нашего облака, необходимо сгенерировать ssh ключи и подключить публичный ключ к обоим виртуальными машинам
```bash
ssh-keygen
cat .ssh/id_rsa.pub
```
Копируем содержимое публичного ключа в виртуалки при их создании

## Установка Ansible в ubuntu контейнере
```bash
apt update
apt install software-properties-common
apt install ansible
ansible --version
```

## Копируем заготовленные template из репозитория
```bash
git clone https://github.com/grant88/education.git
cd 7.devops_mlops/ansible
mkdir /etc/ansible
cp inventory /etc/ansible/hosts
vim /etc/ansible/ansible.cfg
```

Вставляем текст шаблона конфига из интернета 
[ansible.cfg](https://github.com/ansible/ansible/blob/stable-2.9/examples/ansible.cfg) в `/etc/ansible/ansible.cfg`

Расскоментируем строку 
```yaml
inventory      = /etc/ansible/hosts
```

В конфиге `inventory` правим доступные нам сервера, с которыми будем работать
```bash
vim /etc/ansible/hosts
```

## Running
Запустим ansible playbook
```bash
ansible-playbook homework.yaml
```
