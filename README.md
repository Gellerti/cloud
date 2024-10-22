Описание
Этот проект содержит Docker Compose файл и Dockerfile для создания и запуска контейнера с RabbitMQ на базе Ubuntu 20.04. Проект также включает скрипты для автоматической установки и настройки RabbitMQ

Установка
Клонируйте репозиторий:
git clone [https://github.com/cloud.git](https://github.com/Gellerti/cloud.git).git
cd ваш_репозиторий
Соберите Docker образ:
docker-compose build

Запуск
Запустите контейнер с RabbitMQ:

docker-compose up -d

RabbitMQ будет доступен по следующим портам:
5672: Порт для подключения к RabbitMQ.
15672: Порт для доступа к веб-интерфейсу управления RabbitMQ.
Вы можете получить доступ к веб-интерфейсу управления RabbitMQ по адресу http://IP:15672.



Описание файлов
docker-compose.yml: Файл конфигурации Docker Compose для запуска контейнера с RabbitMQ.
Dockerfile: Файл для создания Docker образа на базе Ubuntu 20.04 с установленным RabbitMQ.
startup.sh: Скрипт для запуска RabbitMQ сервера и настройки управления.
install_rabbitmq.sh: Скрипт для автоматической установки и настройки RabbitMQ на Ubuntu.
