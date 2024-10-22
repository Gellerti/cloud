#!/bin/bash

# Start RabbitMQ server in the background
service rabbitmq-server start

# Wait for RabbitMQ to start
sleep 10

# Enable RabbitMQ management plugin
rabbitmq-plugins enable rabbitmq_management

# Add RabbitMQ admin user
rabbitmqctl add_user admin 
rabbitmqctl set_user_tags admin administrator
rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"

# Keep the container running
tail -f /dev/null
