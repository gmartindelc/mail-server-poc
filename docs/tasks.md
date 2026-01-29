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

Status: PARTIAL

Tasks:

- [~] Task 1.5.1: Configure UFW Firewall
  - Estimate: 20 minutes
  - Dependencies: 1.3.1, 1.3.2
  - Automation: task_1_5_1.yml → configure_ufw_firewall.yml
  - Status: Port 80 added for Let's Encrypt, remaining ports pending

## Milestone 2: Mail Server Core Services

Status: COMPLETE (100%)
Dependencies: Milestone 1 complete

### Task Group 2.1: PostgreSQL Container Deployment

Status: COMPLETE

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

- [x] Task 2.1.4: Verify PostgreSQL container and connectivity
  - Estimate: 20 minutes
  - Dependencies: 2.1.3
  - Completed on: 2026-01-29

### Task Group 2.2: Mail Server Core Services

Status: COMPLETE

Tasks:

- [x] Task 2.2.1: Install and configure Postfix MTA
  - Estimate: 60 minutes
  - Dependencies: 2.1.4
  - Automation: task_2.2.1.yml → install_postfix.yml
  - Completed on: 2026-01-22

- [x] Task 2.2.2: Install and configure Dovecot IMAP/LMTP
  - Estimate: 60 minutes
  - Dependencies: 2.2.1
  - Automation: task_2.2.2.yml → install_dovecot.yml
  - Completed on: 2026-01-26
  - Notes: Dovecot 2.4 on Debian 13 required specific configuration

- [x] Task 2.2.3: Install and configure OpenDKIM
  - Estimate: 45 minutes
  - Dependencies: 2.2.2
  - Automation: task_2.2.3.yml → install_opendkim.yml
  - Completed on: 2026-01-26

- [x] Task 2.2.4: Configure SSL/TLS certificates (Let's Encrypt)
  - Estimate: 45 minutes
  - Dependencies: 2.2.3
  - Automation: task_2.2.4.yml → install_letsencrypt.yml
  - Completed on: 2026-01-26
  - Certificates: cucho1.phalkons.com, mail.phalkons.com (expires 2026-04-26)

- [x] Task 2.2.5: End-to-End Mail System Testing
  - Estimate: 30 minutes
  - Dependencies: 2.2.4
  - Automation: task_2.2.5.yml → test_mail_system.yml
  - Completed on: 2026-01-29
  - Health Score: 100% (9/9 checks passed)

- [x] Task 2.2.6: User Management Automation
  - Estimate: 90 minutes
  - Dependencies: 2.2.5
  - Automation: add_mail_user.yml, bulk_add_mail_users.yml
  - Completed on: 2026-01-29
  - Features: Interactive single user add, CSV bulk import
  - Documentation: BULK_ADD_USERS_GUIDE.md, THUNDERBIRD_SETUP_GUIDE.md

- [x] Task 2.2.7: Dovecot 2.4 Configuration Corrections
  - Estimate: 240 minutes (troubleshooting)
  - Dependencies: 2.2.2, 2.2.5
  - Automation: install_dovecot_corrected.yml
  - Completed on: 2026-01-29
  - Critical fixes for Debian 13 Dovecot 2.4 mail delivery
  - Documentation: MANUAL_FIXES_SUMMARY.md

## Milestone 3: Web Interfaces & Additional Services

Status: NOT STARTED
Dependencies: Milestone 2 complete

**Important:** Choose ONE webmail solution below. Do NOT install both Roundcube and SOGo.

### Option A: Webmail Interface (Roundcube)

**Recommended for:** Users who manage calendars/contacts in Thunderbird/Outlook desktop clients
**Architecture:** Nginx + Roundcube (webmail only) + Dovecot (IMAP)

#### Task Group 3.1: Nginx Web Server

Tasks:

- [ ] Task 3.1.1: Check for and remove Apache if installed
  - Estimate: 20 minutes
  - Dependencies: 2.2.4
  - Automation: check_remove_apache.yml
  - Check for Apache2 packages, stop service, remove packages
  - Verify no Apache processes remain (Debian may have Apache pre-installed)

- [ ] Task 3.1.2: Install and configure Nginx
  - Estimate: 45 minutes
  - Dependencies: 3.1.1
  - Automation: install_configure_nginx.yml
  - Install Nginx with SSL modules
  - Configure reverse proxy for Roundcube
  - Set up SSL termination with existing Let's Encrypt certificates

#### Task Group 3.2: Roundcube Installation

Tasks:

- [ ] Task 3.2.1: Install Roundcube packages
  - Estimate: 30 minutes
  - Dependencies: 3.1.2
  - Automation: install_roundcube.yml
  - Install Roundcube from Debian repositories
  - Configure web directory structure

- [ ] Task 3.2.2: Configure Roundcube database (PostgreSQL)
  - Estimate: 45 minutes
  - Dependencies: 3.2.1, 2.1.4
  - Automation: configure_roundcube_database.yml
  - Create Roundcube schema in PostgreSQL
  - Set up database connection

- [ ] Task 3.2.3: Set up Roundcube plugins
  - Estimate: 30 minutes
  - Dependencies: 3.2.2
  - Automation: configure_roundcube_plugins.yml
  - Install and configure ManageSieve plugin (mail filters)
  - Install password plugin (user password management)

- [ ] Task 3.2.4: Configure Roundcube with Dovecot/Postfix
  - Estimate: 30 minutes
  - Dependencies: 3.2.3
  - Automation: integrate_roundcube_mail.yml
  - Configure IMAP/SMTP settings
  - Test webmail functionality

#### Task Group 3.3: Optional Lightweight CalDAV Server (Radicale)

**Only if needed:** For centralized calendar/contacts storage accessible from multiple devices
Tasks:

- [ ] Task 3.3.1: Install and configure Radicale
  - Estimate: 60 minutes
  - Dependencies: 3.2.4
  - Automation: install_radicale.yml
  - Install Radicale CalDAV/CardDAV server
  - Configure PostgreSQL authentication
  - Set up SSL with existing certificates

- [ ] Task 3.3.2: Configure Thunderbird/Outlook for CalDAV/CardDAV
  - Estimate: 30 minutes
  - Dependencies: 3.3.1
  - Automation: none (client configuration guide)
  - Create user guide for client configuration

### Option B: Full Groupware (SOGo)

**Recommended for:** Web-based calendar/contacts needed, ActiveSync mobile support required
**Architecture:** Nginx + SOGo (email + calendar + contacts) + Dovecot (IMAP backend)

#### Task Group 3.4: Nginx Web Server (for SOGo)

Tasks:

- [ ] Task 3.4.1: Check for and remove Apache if installed
  - Estimate: 20 minutes
  - Dependencies: 2.2.4
  - Automation: check_remove_apache.yml
  - Same as Task 3.1.1

- [ ] Task 3.4.2: Install and configure Nginx for SOGo
  - Estimate: 45 minutes
  - Dependencies: 3.4.1
  - Automation: install_configure_nginx_sogo.yml
  - Install Nginx with SSL and proxy modules
  - Configure reverse proxy for SOGo web interface

#### Task Group 3.5: SOGo Installation and Configuration

Tasks:

- [ ] Task 3.5.1: Install SOGo packages
  - Estimate: 30 minutes
  - Dependencies: 3.4.2
  - Automation: install_sogo.yml
  - Install SOGo from repository
  - Install required dependencies

- [ ] Task 3.5.2: Configure SOGo database (PostgreSQL)
  - Estimate: 60 minutes
  - Dependencies: 3.5.1, 2.1.4
  - Automation: configure_sogo_database.yml
  - Create SOGo schema in PostgreSQL
  - Configure database connection and authentication

- [ ] Task 3.5.3: Configure SOGo with mail services
  - Estimate: 60 minutes
  - Dependencies: 3.5.2
  - Automation: configure_sogo_mail.yml
  - Integrate with Dovecot IMAP
  - Configure SMTP settings with Postfix
  - Set up CalDAV/CardDAV services

- [ ] Task 3.5.4: Configure ActiveSync (optional)
  - Estimate: 45 minutes
  - Dependencies: 3.5.3
  - Automation: configure_sogo_activesync.yml
  - Set up ActiveSync for mobile devices
  - Configure device management

---

## Newly Discovered Tasks

### Task Group 2.4: DNS Configuration

Status: PARTIAL

- [x] Task 2.4.1: Configure SPF DNS record
  - Completed on: 2026-01-29
  - Record: v=spf1 ip4:144.202.72.168 -all

- [ ] Task 2.4.2: Configure DKIM DNS records
  - Dependencies: 2.2.3
  - Records available: /root/dns_records.txt on server
- [ ] Task 2.4.3: Configure DMARC DNS records
  - Dependencies: 2.4.1, 2.4.2

## Decision Log

- **Webmail Choice:** Option A (Roundcube) selected - Users primarily use Thunderbird/Outlook for calendars/contacts
- **Apache Handling:** Explicit check and removal added before Nginx installation
- **Coexistence Policy:** Roundcube and SOGo should NOT both be installed

**Legend:**

- [x] Complete
- [ ] Not Started
- [~] In Progress
- [!] Blocked
