# Use the official Ubuntu image as a base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update -y && \
    apt-get install -y curl gnupg apt-transport-https && \
    curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | gpg --dearmor | tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null && \
    curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | gpg --dearmor | tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg > /dev/null && \
    curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | gpg --dearmor | tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg > /dev/null && \
    tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases from a Cloudsmith mirror
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu focal main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu focal main

## Provides RabbitMQ from a Cloudsmith mirror
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu focal main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu focal main
EOF

# Update package list and install RabbitMQ and Erlang
RUN apt-get update -y && \
    apt-get install -y erlang-base \
        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
        erlang-runtime-tools erlang-snmp erlang-ssl \
        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl && \
    apt-get install rabbitmq-server -y --fix-missing

# Copy the startup script
COPY startup.sh /usr/local/bin/startup.sh
RUN chmod +x /usr/local/bin/startup.sh

# Expose RabbitMQ ports
EXPOSE 5672 15672

# Set the default command to run the startup script
CMD ["/usr/local/bin/startup.sh"]
