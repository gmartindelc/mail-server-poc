output "instance_id" {
  description = "Instance ID"
  value       = vultr_instance.server.id
}

output "instance_label" {
  description = "Instance label"
  value       = vultr_instance.server.label
}

output "main_ip" {
  description = "Main IP address of the VPS"
  value       = vultr_instance.server.main_ip
}

output "default_password" {
  description = "Default root password (sensitive)"
  value       = vultr_instance.server.default_password
  sensitive   = true
}

output "region" {
  description = "Region where the instance is deployed"
  value       = vultr_instance.server.region
}

output "os" {
  description = "Operating system"
  value       = vultr_instance.server.os
}

output "vcpu_count" {
  description = "Number of vCPUs"
  value       = vultr_instance.server.vcpu_count
}

output "ram" {
  description = "RAM in MB"
  value       = vultr_instance.server.ram
}

output "disk" {
  description = "Disk size in GB"
  value       = vultr_instance.server.disk
}

output "status" {
  description = "Instance status"
  value       = vultr_instance.server.status
}

# Output for saving to file (Vault format)
output "vault_secret_json" {
  description = "JSON formatted output for HashiCorp Vault"
  value = jsonencode({
    instance_id       = vultr_instance.server.id
    label             = vultr_instance.server.label
    hostname          = vultr_instance.server.hostname
    main_ip           = vultr_instance.server.main_ip
    default_password  = vultr_instance.server.default_password
    region            = vultr_instance.server.region
    os                = vultr_instance.server.os
    plan              = vultr_instance.server.plan
    created_at        = vultr_instance.server.date_created
  })
  sensitive = true
}
