# terraform/main.tf

terraform {
  required_providers {
    vultr = {
      source  = "vultr/vultr"
      version = "~> 2.0"
    }
  }
  required_version = ">= 1.0"
}

provider "vultr" {
  api_key = var.vultr_api_key
}

# Get available OS images
data "vultr_os" "debian" {
  filter {
    name   = "name"
    values = [var.os_name]
  }
}

# Get available plans
data "vultr_plan" "server_plan" {
  filter {
    name   = "name"
    values = [var.server_plan]
  }
}

# Get available regions
data "vultr_region" "server_region" {
  filter {
    name   = "city"
    values = [var.region]
  }
}

# Create SSH key from provided public key
resource "vultr_ssh_key" "server_key" {
  name    = "${var.hostname}-ssh-key"
  ssh_key = var.ssh_public_key
}

# Create the VPS instance
resource "vultr_instance" "mail_server" {
  plan     = data.vultr_plan.server_plan.id
  region   = data.vultr_region.server_region.id
  os_id    = data.vultr_os.debian.id
  label    = var.label
  hostname = var.hostname
  tags     = var.tags

  # SSH key for authentication
  ssh_key_ids = [vultr_ssh_key.server_key.id]

  # Enable IPv6
  enable_ipv6 = true

  # Minimal user data
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "Vultr instance provisioned at $(date)" > /root/provision.log
    hostnamectl set-hostname ${var.hostname}
  EOF
  )

  # Resource-specific settings
  ddos_protection  = false
  activation_email = false
}
