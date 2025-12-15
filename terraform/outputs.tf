# terraform/outputs.tf

# Instance information outputs
output "ipv4_address" {
  value       = vultr_instance.mail_server.main_ip
  description = "Public IPv4 address of the instance"
}

output "ipv6_address" {
  value       = vultr_instance.mail_server.v6_main_ip
  description = "Public IPv6 address of the instance"
}

output "hostname" {
  value       = vultr_instance.mail_server.hostname
  description = "Hostname of the instance"
}

output "region" {
  value       = var.region
  description = "Region where instance is deployed"
}

output "os" {
  value       = var.os_name
  description = "Operating system installed"
}

output "plan" {
  value       = var.server_plan
  description = "Server plan/size"
}

output "status" {
  value       = vultr_instance.mail_server.status
  description = "Current status of the instance"
}

output "created_date" {
  value       = timestamp()
  description = "Timestamp when instance was created"
}

output "ssh_key_name" {
  value       = vultr_ssh_key.server_key.name
  description = "Name of SSH key configured"
}

# Important information about credentials
output "credentials_info" {
  value       = <<-EOT
    
    =================================================================
    IMPORTANT: Vultr generates a random root password and emails it to you.
    
    Check your email for the Vultr welcome message containing:
    1. Root password for the server
    2. Server IP address
    
    Connection Information:
    - IPv4: ${vultr_instance.mail_server.main_ip}
    - IPv6: ${vultr_instance.mail_server.v6_main_ip}
    - Hostname: ${vultr_instance.mail_server.hostname}
    
    SSH Command:
    ssh root@${vultr_instance.mail_server.main_ip}
    
    Next Steps:
    1. Check email for root password
    2. SSH into server with provided credentials
    3. Change password immediately
    4. Proceed with Ansible configuration
    =================================================================
  EOT
  description = "Important notes about credentials and next steps"
}

# Local file outputs
resource "local_file" "instance_outputs_json" {
  filename = "${path.module}/../instance_outputs.json"
  content = jsonencode({
    ipv4_address = vultr_instance.mail_server.main_ip
    ipv6_address = vultr_instance.mail_server.v6_main_ip
    hostname     = vultr_instance.mail_server.hostname
    label        = vultr_instance.mail_server.label
    region       = var.region
    os           = var.os_name
    plan         = var.server_plan
    status       = vultr_instance.mail_server.status
    ssh_key_name = vultr_ssh_key.server_key.name
    created_at   = timestamp()
  })
}

resource "local_file" "connection_info_txt" {
  filename = "${path.module}/../connection_info.txt"
  content  = <<-EOT
    Mail Server PoC - Connection Information
    ========================================
    
    Instance Details:
    ----------------
    - IPv4 Address: ${vultr_instance.mail_server.main_ip}
    - IPv6 Address: ${vultr_instance.mail_server.v6_main_ip}
    - Hostname: ${vultr_instance.mail_server.hostname}
    - Label: ${vultr_instance.mail_server.label}
    - Region: ${var.region}
    - OS: ${var.os_name}
    - Plan: ${var.server_plan}
    - Status: ${vultr_instance.mail_server.status}
    - SSH Key: ${vultr_ssh_key.server_key.name}
    
    Credentials Information:
    -----------------------
    Vultr generates a random root password and sends it via email.
    Check your email for the welcome message from Vultr containing:
    1. Root password
    2. Server connection details
    
    SSH Connection:
    --------------
    Command: ssh root@${vultr_instance.mail_server.main_ip}
    Authentication: Use the password from Vultr email
    
    Security Recommendations:
    -------------------------
    1. Change root password immediately after first login
    2. Set up SSH key authentication
    3. Configure firewall rules
    4. Run system updates
    
    Next Steps:
    ----------
    1. Check email for root password
    2. SSH into server with provided credentials
    3. Change root password
    4. Proceed with Ansible configuration (Task 1.1.2)
    
    Generated on: ${timestamp()}
  EOT
}
