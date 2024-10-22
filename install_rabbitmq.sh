#!/bin/bash -ex
#====================================================================
# install_rabbitmq.sh
#
# Ubuntu RabbitMQ Auto Install Script
#
# Copyright (c) 2024
# Distributed under the GNU General Public License, version 3.0.
#
#====================================================================

echo "Note: This script is specifically designed for Ubuntu"
echo ""

if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script!"
    exit 1
fi

# define functions
msg() {
    printf '%b\n' "$1" >&2
}

success() {
    msg "\33[32m[✔]\33[0m ${1}${2}"
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

program_exists() {
    command -v $1 >/dev/null 2>&1
}

function install_dependencies() {
    sudo apt-get update -y || return 1
    sudo apt-get install curl gnupg apt-transport-https -y || return 1
}

function add_repository_keys() {
    # Add RabbitMQ signing keys
    curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null
    curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-erlang.E495BB49CC4BBE5B.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg > /dev/null
    curl -1sLf https://github.com/rabbitmq/signing-keys/releases/download/3.0/cloudsmith.rabbitmq-server.9F4587F226208342.key | sudo gpg --dearmor | sudo tee /usr/share/keyrings/rabbitmq.9F4587F226208342.gpg > /dev/null
    success "Added repository signing keys"
}

function add_repository() {
    # Add RabbitMQ and Erlang repositories
    sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Provides modern Erlang/OTP releases from a Cloudsmith mirror
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu focal main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.E495BB49CC4BBE5B.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-erlang/deb/ubuntu focal main

## Provides RabbitMQ from a Cloudsmith mirror
##
deb [arch=amd64 signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu focal main
deb-src [signed-by=/usr/share/keyrings/rabbitmq.9F4587F226208342.gpg] https://ppa1.rabbitmq.com/rabbitmq/rabbitmq-server/deb/ubuntu focal main
EOF

    sudo apt-get update -y || return 1
    success "Added RabbitMQ and Erlang repositories"
}

function install_rabbitmq() {
    # Install Erlang packages
    sudo apt-get install -y erlang-base \
        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
        erlang-runtime-tools erlang-snmp erlang-ssl \
        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl || return 1
    
    # Install RabbitMQ server
    sudo apt-get install rabbitmq-server -y --fix-missing || return 1

    success "Installed RabbitMQ and Erlang"
}

function set_rabbitmq_users() {
    if program_exists rabbitmqctl; then
        rabbitmqctl list_users | grep -q guest && \
            rabbitmqctl delete_user guest >/dev/null && \
            success "Deleted user [guest]"
        rabbitmqctl list_users | grep -q admin || {
            rabbitmqctl add_user admin $ADMIN_PWD >/dev/null && \
            rabbitmqctl set_user_tags admin administrator >/dev/null && \
            rabbitmqctl set_permissions -p / admin ".*" ".*" ".*" >/dev/null && \
            success "Added user [admin]"
        }
    else
        msg "Command not found: rabbitmqctl" && return 1
    fi
}

function restart_rabbitmq() {
    sudo systemctl enable rabbitmq-server
    sudo systemctl restart rabbitmq-server
    success "Restarted RabbitMQ"
}

function print_usage() {
    echo "Usage: $(basename "$0") [OPTIONS...]"
    echo ""
    echo "Options"
    echo "  [-h|--help]                 Prints a short help text and exits"
    echo "  [-i|--install]              Install RabbitMQ server"
    echo "  [-u|--update]               Update RabbitMQ server"
    echo "  [-e|--erase]                Erase (uninstall) RabbitMQ server"
    echo "  [-c|--cookie] <cookie>      Set Erlang cookie"
}

# read options
TEMP=`getopt -o hiuec:j:n: --long help,install,update,erase,cookie: -n $(basename "$0") -- "$@"`
eval set -- "$TEMP"

# extract options and arguments
while true; do
    case "$1" in
        -h|--help) print_usage ; exit 0 ;;
        -i|--install) ACTION=install ; shift ;;
        -u|--update) ACTION=update ; shift ;;
        -e|--erase) ACTION=erase ; shift ;;
        -c|--cookie) COOKIE=$2 ; shift 2 ;;
        --) shift ; break ;;
        *) error "Internal error!" ;;
    esac
done

# Execute actions
case $ACTION in
    install)
        install_dependencies
        add_repository_keys
        add_repository
        install_rabbitmq
        restart_rabbitmq
        set_rabbitmq_users
        ;;
    update)
        sudo apt-get update -y
        sudo apt-get upgrade rabbitmq-server -y
        restart_rabbitmq
        ;;
    erase)
        sudo apt-get remove --purge rabbitmq-server -y
        sudo apt-get autoremove -y
        ;;
    *)
        print_usage
        ;;
esac
