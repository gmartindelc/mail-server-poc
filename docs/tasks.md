# Mail Server Cluster PoC - Task Tracking

## Milestone 1: Environment Setup & Foundation

Status: 100% Complete

### Task Group 1.1: VPS Provisioning & Base Configuration

Status: COMPLETE

Tasks:

- [x] Task 1.1.1: Provision Vultr VPS (2CPU/4GB/80GB SSD) with Debian 13
  - Estimate: 30 minutes
  - Dependencies: None
  - Automation/Artifacts: terraform deploy.sh
  - Assigned to: GMCE
  - Completed on: 2024-12-18

### Task Group 1.2: System User Administration

Status: COMPLETE

Tasks:

- [x] Task 1.2.1: Modify sudoers file to add NOPASSWD to sudo users

  - Estimate: 15 minutes
  - Dependencies: 1.1.1
  - Automation: task_1.2.1.yml → modify_sudoers_nopasswd.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-05

- [x] Task 1.2.2: Remove linuxuser

  - Estimate: 10 minutes
  - Dependencies: 1.2.1
  - Automation: task_1.2.2.yml → remove_linuxuser.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-05

- [x] Task 1.2.3: Create phalkonadmin user (UID 1000)

  - Estimate: 15 minutes
  - Dependencies: 1.2.2
  - Automation: task_1.2.3.yml → create_phalkonadmin.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-05

- [x] Task 1.2.4: Configure SSH key authentication (disable root, enable phalkonadmin)

  - Estimate: 20 minutes
  - Dependencies: 1.2.3
  - Automation: task_1.2.4.yml → setup_ssh_key_auth.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-05

- [x] Task 1.2.5: Test SSH connection and verify configuration

  - Estimate: 10 minutes
  - Dependencies: 1.2.4
  - Automation: task_1.2.5.yml → test_ssh_connection.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-05

- [x] Task 1.2.6: Install Docker Compose

  - Estimate: 20 minutes
  - Dependencies: 1.2.4
  - Automation: task_1.2.6.yml → install_docker.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-05

- [x] Task 1.2.7: Post-configuration cleanup and verification
  - Estimate: 15 minutes
  - Dependencies: 1.2.6
  - Automation: task_1.2.7.yml → fix_user_uid.yml + cleanup_main_sudoers.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-05

### Task Group 1.3: System Hardening

Status: COMPLETE

Tasks:

- [x] Task 1.3.1: Configure basic system hardening

  - Estimate: 45 minutes
  - Dependencies: 1.2.7
  - Automation: task_1.3.1.yml → system_hardening.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-07

- [x] Task 1.3.2: Integrate VPS into WireGuard VPN

  - Estimate: 45 minutes
  - Dependencies: 1.3.1
  - Automation: task_1.3.2.yml → install_wireguard.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-07

- [x] Task 1.3.3: Configure network interfaces and DNS resolution

  - Estimate: 30 minutes
  - Dependencies: 1.3.2
  - Automation: task_1.3.3.yml → verify_network_interfaces.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-07

- [x] Task 1.3.4: Restrict SSH to VPN only and set startup dependency

  - Estimate: 30 minutes
  - Dependencies: 1.3.3
  - Automation: task_1.3.4.yml → configure_ssh_vpn_only.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-07

- [x] Task 1.3.5: Install and configure fail2ban
  - Estimate: 30 minutes
  - Dependencies: 1.3.1
  - Automation: task_1.3.5.yml → install_fail2ban.yml
  - Assigned to: GMCE
  - Completed on: 2025-01-07

### Task Group 1.4: Directory Structure & Storage

Status: COMPLETE

Tasks:

- [x] Task 1.4.1: Create mail system directory structure

  - Estimate: 20 minutes
  - Dependencies: 1.3.1
  - Automation: task_1.4.1.yml → create_mail_directories.yml
  - Assigned to: GMCE
  - Completed on: 2026-01-12

- [x] Task 1.4.2: Set proper permissions and ownership for directories

  - Estimate: 20 minutes
  - Dependencies: 1.4.1
  - Automation: task_1.4.2.yml → configure_directory_permissions.yml
  - Assigned to: GMCE
  - Completed on: 2026-01-12

- [x] Task 1.4.3: Configure disk quotas for /var/mail/vmail/ (prepare only)
  - Estimate: 30 minutes
  - Dependencies: 1.4.2
  - Automation: task_1.4.3.yml → prepare_disk_quotas.yml
  - Assigned to: GMCE
  - Completed on: 2026-01-12

### Task Group 1.5: Firewall Configuration (UFW)

Status: NOT STARTED

Tasks:

- [ ] Task 1.5.1: Configure UFW Firewall
  - Estimate: 20 minutes
  - Dependencies: 1.3.1, 1.3.2
  - Automation: task_1_5_1.yml → configure_ufw_firewall.yml

## Milestone 2: Database Layer Implementation

Status: 75% Complete (3 of 4 tasks)
Dependencies: Milestone 1 complete

### Task Group 2.1: PostgreSQL Container Deployment

Status: In Progress

Tasks:

- [x] Task 2.1.1: Create PostgreSQL Docker Compose configuration

  - Estimate: 30 minutes
  - Dependencies: 1.4.2
  - Automation: task_2.1.1.yml → deploy_postgresql_container.yml
  - Completed on: 2026-01-12

- [x] Task 2.1.2: Configure PostgreSQL for mail server authentication

  - Estimate: 45 minutes
  - Dependencies: 2.1.1
  - Automation: task_2.1.2.yml → configure_mail_database.yml
  - Completed on: 2026-01-12

- [x] Task 2.1.3: Configure PostgreSQL backups and WAL archiving

  - Estimate: 45 minutes
  - Dependencies: 2.1.2
  - Automation: task_2.1.3.yml → configure_database_backups.yml
  - Completed on: 2026-01-12

- [ ] Task 2.1.4: Verify PostgreSQL container and connectivity
  - Estimate: 20 minutes
  - Dependencies: 2.1.3

---

## Newly Discovered Tasks

- Task Group 1.5: Firewall Configuration (UFW)
  - [ ] Task 1.5.1: Configure UFW Firewall — Not Started

**Legend:**

- [x] Complete
- [ ] Not Started
- [~] In Progress
- [!] Blocked
