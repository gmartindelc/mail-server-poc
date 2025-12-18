# terraform/terraform.tfvars

# Server specifications (from Vultr_specs.md)
server_plan = "vc2-2c-4gb"
hostname    = "cucho1.phalkons.com"
region      = "Dallas"
os_name     = "Debian 13 x64 (Bookworm)"

# Instance configuration
label = "mail-server-poc"
tags  = ["mail-server", "poc", "production", "terraform-managed"]
