terraform {
  required_version = ">= 1.0.0"

  required_providers {
    rustack = {
      source  = "pilat/rustack"
      version = "1.1.7"
    }
  }
}

provider "rustack" {
  api_endpoint = "https://cloud.mephi.ru"
  token        = "bc1a0b4d46d74887d59b577f1d6704fa52121d76"
}

data "rustack_project" "my_project" {
  name = "Rabbitmq"
}

data "rustack_hypervisor" "kvm" {
  project_id = data.rustack_project.my_project.id
  name       = "РУСТЭК"
}

data "rustack_vdc" "vdc" {
  project_id = data.rustack_project.my_project.id
  name       = "Rabbitmq" 
}

data "rustack_network" "service_network" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Сеть"
}

data "rustack_storage_profile" "ssd" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "ssd"
}

data "rustack_template" "ubuntu20" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Ubuntu 20.04"
}

data "rustack_firewall_template" "allow_default" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Разрешить исходящие"
}

data "rustack_firewall_template" "allow_ssh" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Разрешить SSH"
}

data "rustack_firewall_template" "allow_rabbitmq" {
  vdc_id = data.rustack_vdc.vdc.id
  name   = "Rabbitmq"
}


resource "rustack_port" "vm_port_1" {
  vdc_id = data.rustack_vdc.vdc.id
  network_id = data.rustack_network.service_network.id
  firewall_templates = [
    data.rustack_firewall_template.allow_default.id,
    data.rustack_firewall_template.allow_rabbitmq.id,
    data.rustack_firewall_template.allow_ssh.id,
  ]
}

resource "rustack_vm" "rabbitmq_1" {    
  vdc_id = data.rustack_vdc.vdc.id
  name   = "RabbitMQ-1"
  cpu    = 4
  ram    = 8

  template_id = data.rustack_template.ubuntu20.id
  user_data   = file("user_data.yaml")

  system_disk {
    size                = 30
    storage_profile_id = data.rustack_storage_profile.ssd.id
  }

  ports = [rustack_port.vm_port_1.id]
  floating = true
}
