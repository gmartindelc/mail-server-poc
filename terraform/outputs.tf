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

output "label" {
  value       = vultr_instance.mail_server.label
  description = "Label/name of the instance"
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

output "instance_id" {
  value       = vultr_instance.mail_server.id
  description = "Vultr instance ID for dashboard reference"
}

output "created_date" {
  value       = timestamp()
  description = "Timestamp when instance was created"
}

output "ssh_key_name" {
  value       = vultr_ssh_key.server_key.name
  description = "Name of SSH key configured"
}

output "dashboard_url" {
  value       = "https://my.vultr.com/subs/?id=${vultr_instance.mail_server.id}"
  description = "Direct link to instance in Vultr dashboard"
}

output "provisioning_summary" {
  value       = <<-EOT
    ================================================================================
    ✅ VULTR INSTANCE SUCCESSFULLY PROVISIONED!
    
    Instance Specifications:
    ------------------------
    IPv4 Address: ${vultr_instance.mail_server.main_ip}
    IPv6 Address: ${vultr_instance.mail_server.v6_main_ip}
    Hostname: ${vultr_instance.mail_server.hostname}
    Label: ${vultr_instance.mail_server.label}
    Region: ${var.region}
    OS: ${var.os_name}
    Plan: ${var.server_plan} (4GB RAM, 80GB SSD)
    Status: ${vultr_instance.mail_server.status}
    Instance ID: ${vultr_instance.mail_server.id}
    
    🔑 ROOT PASSWORD ACCESS INSTRUCTIONS:
    -------------------------------------
    The root password is NOT emailed. Access it via Vultr Dashboard:
    
    1. Login to: https://my.vultr.com
    2. Navigate to: Products → Cloud Compute
    3. Click on your server: "${vultr_instance.mail_server.label}"
    4. In the "Server Details" section
    5. Click "View" button next to "Password" field
    6. The root password will be revealed
    
    Direct Dashboard Link:
    ${vultr_instance.mail_server.main_ip ? "https://my.vultr.com/subs/?id=${vultr_instance.mail_server.id}" : "Will be available after provisioning"}
    
    SSH CONNECTION:
    ---------------
    Using Password (from Dashboard):
      ssh root@${vultr_instance.mail_server.main_ip}
      Password: [Retrieve from Vultr Dashboard as shown above]
    
    Using SSH Key Authentication:
      ssh -i ~/.ssh/id_rsa root@${vultr_instance.mail_server.main_ip}
    
    IMMEDIATE ACTIONS REQUIRED:
    ---------------------------
    1. Retrieve root password from Vultr Dashboard
    2. SSH into server: ssh root@${vultr_instance.mail_server.main_ip}
    3. Change root password immediately: `passwd`
    4. Verify SSH key authentication works
    5. Check system status: `uptime && df -h`
    
    NEXT TASK (1.1.2):
    ------------------
    Proceed with system hardening:
    - SSH configuration hardening
    - Firewall setup (UFW)
    - System updates
    - Basic security configuration
    
    ================================================================================
  EOT
  description = "Complete provisioning summary with connection instructions"
}

# Save instance outputs to JSON file
resource "local_file" "instance_outputs_json" {
  filename = "${path.module}/../instance_outputs.json"
  content = jsonencode({
    ipv4_address  = vultr_instance.mail_server.main_ip
    ipv6_address  = vultr_instance.mail_server.v6_main_ip
    hostname      = vultr_instance.mail_server.hostname
    label         = vultr_instance.mail_server.label
    region        = var.region
    os            = var.os_name
    plan          = var.server_plan
    status        = vultr_instance.mail_server.status
    instance_id   = vultr_instance.mail_server.id
    ssh_key_name  = vultr_ssh_key.server_key.name
    created_at    = timestamp()
    dashboard_url = "https://my.vultr.com/subs/?id=${vultr_instance.mail_server.id}"
    ssh_command   = "ssh root@${vultr_instance.mail_server.main_ip}"
    notes         = "Root password available in Vultr Dashboard under Server Details → Password (click 'View')"
  })
  depends_on = [vultr_instance.mail_server]
}

# Save detailed connection instructions to text file
resource "local_file" "connection_info_txt" {
  filename   = "${path.module}/../connection_info.txt"
  content    = <<-EOT
    MAIL SERVER PoC - VULTR INSTANCE CONNECTION INFORMATION
    ========================================================
    
    INSTANCE PROVISIONED SUCCESSFULLY!
    
    TECHNICAL SPECIFICATIONS:
    -------------------------
    IPv4 Address:      ${vultr_instance.mail_server.main_ip}
    IPv6 Address:      ${vultr_instance.mail_server.v6_main_ip}
    Hostname:          ${vultr_instance.mail_server.hostname}
    Label:             ${vultr_instance.mail_server.label}
    Region:            ${var.region}
    Operating System:  ${var.os_name}
    Server Plan:       ${var.server_plan} (4GB RAM, 80GB SSD)
    Instance ID:       ${vultr_instance.mail_server.id}
    Status:            ${vultr_instance.mail_server.status}
    Provisioned:       ${timestamp()}
    
    CRITICAL: ROOT PASSWORD ACCESS
    ------------------------------
    Vultr does NOT email the root password. You must retrieve it from the dashboard:
    
    STEP-BY-STEP PASSWORD RETRIEVAL:
    1. Open: https://my.vultr.com
    2. Login with your Vultr credentials
    3. Click on "Products" in the main menu
    4. Select "Cloud Compute" from the dropdown
    5. Find and click on your server: "${vultr_instance.mail_server.label}"
    6. In the server management page, locate "Server Details" section
    7. Find the "Password" field
    8. Click the "View" button next to it
    9. The root password will be displayed
    
    DIRECT DASHBOARD LINK:
    https://my.vultr.com/subs/?id=${vultr_instance.mail_server.id}
    
    SSH CONNECTION INSTRUCTIONS:
    ----------------------------
    
    OPTION 1: Using Password (Recommended for initial login)
      Command:    ssh root@${vultr_instance.mail_server.main_ip}
      Username:   root
      Password:   [From Vultr Dashboard as described above]
    
    OPTION 2: Using SSH Key (If configured)
      Command:    ssh -i ~/.ssh/id_rsa root@${vultr_instance.mail_server.main_ip}
      Note:       No password required if SSH key authentication works
    
    SECURITY CHECKLIST (IMMEDIATE ACTIONS):
    ---------------------------------------
    [ ] 1. Retrieve root password from Vultr Dashboard
    [ ] 2. SSH into server using the password
    [ ] 3. Immediately change root password: Type 'passwd' and follow prompts
    [ ] 4. Test SSH key authentication (if you have private key)
    [ ] 5. Verify system is running: 'uptime'
    [ ] 6. Check disk space: 'df -h'
    [ ] 7. Check network configuration: 'ip addr show'
    
    TROUBLESHOOTING:
    ----------------
    If you cannot SSH:
    1. Wait 2-3 minutes for the instance to fully boot
    2. Verify the password from Vultr Dashboard is correct
    3. Check if your IP is blocked by firewall (unlikely on fresh install)
    4. Try from different network if possible
    
    If password doesn't work:
    1. Use Vultr Dashboard → Server → View Console
    2. Reset password via Vultr Dashboard if needed
    
    NEXT PROJECT TASK (1.1.2):
    --------------------------
    Task: System Hardening (SSH, Firewall, Updates)
    Command to proceed: Check tasks.md for Task 1.1.2 details
    
    SUPPORT INFORMATION:
    -------------------
    Vultr Support: https://www.vultr.com/support/
    Instance Management: https://my.vultr.com
    
    Generated by Terraform on: ${timestamp()}
    
    ========================================================
    END OF CONNECTION INFORMATION
    ========================================================
  EOT
  depends_on = [vultr_instance.mail_server]
}

# Create a quick reference markdown file
resource "local_file" "quick_reference_md" {
  filename   = "${path.module}/../quick_reference.md"
  content    = <<-EOT
    # Mail Server PoC - Quick Reference
    
    ## Instance Details
    - **IPv4:** ${vultr_instance.mail_server.main_ip}
    - **Hostname:** ${vultr_instance.mail_server.hostname}
    - **Label:** ${vultr_instance.mail_server.label}
    - **Location:** ${var.region}
    - **OS:** ${var.os_name}
    - **RAM:** 4GB
    - **Storage:** 80GB SSD
    - **Status:** ${vultr_instance.mail_server.status}
    
    ## Password Access
    ### Vultr Dashboard Steps:
    1. **Login:** https://my.vultr.com
    2. **Navigate:** Products → Cloud Compute
    3. **Click:** ${vultr_instance.mail_server.label}
    4. **Find:** Server Details section
    5. **Click:** "View" next to Password
    
    ### Direct Link:
    https://my.vultr.com/subs/?id=${vultr_instance.mail_server.id}
    
    ## SSH Connection
    ```bash
    # Using password (from dashboard):
    ssh root@${vultr_instance.mail_server.main_ip}
    
    # Using SSH key:
    ssh -i ~/.ssh/id_rsa root@${vultr_instance.mail_server.main_ip}
    ```
    
    ## Immediate Commands After Login
    ```bash
    # Change root password
    passwd
    
    # Check system
    uptime
    df -h
    free -h
    ip addr show
    ```
    
    ## Next Task
    **Task 1.1.2:** System hardening (SSH, firewall, updates)
    
    ---
    *Generated: ${timestamp()}*
  EOT
  depends_on = [vultr_instance.mail_server]
}
