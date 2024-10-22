#!/bin/bash

# Ожидаем, пока нода будет готова
sleep 10

rabbitmqctl stop_app

rabbitmqctl join_cluster rabbit@rabbitmq-node1

rabbitmqctl start_app
