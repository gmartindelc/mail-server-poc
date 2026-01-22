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
  - Automation: task_1.5.1.yml → configure_ufw_firewall.yml

## Milestone 2: Mail Server Core Implementation

Status: 75% Complete
Dependencies: Milestone 1 complete

### Task Group 2.1: PostgreSQL Container Deployment

Status: COMPLETE (4 of 4 tasks)

Tasks:

- [x] Task 2.1.1: Create PostgreSQL Docker Compose configuration

  - Estimate: 30 minutes
  - Dependencies: 1.4.2
  - Automation: task_2.1.1.yml → deploy_postgresql_container.yml
  - Completed on: 2026-01-19

- [x] Task 2.1.2: Configure PostgreSQL for mail server authentication

  - Estimate: 45 minutes
  - Dependencies: 2.1.1
  - Automation: task_2.1.2.yml → configure_mail_database.yml
  - Completed on: 2026-01-22

- [x] Task 2.1.3: Configure PostgreSQL backups and WAL archiving

  - Estimate: 45 minutes
  - Dependencies: 2.1.2
  - Automation: task_2.1.3.yml → configure_database_backups.yml
  - Status: Skipped for PoC (backup infrastructure not needed for testing)

- [x] Task 2.1.4: Verify PostgreSQL container and connectivity
  - Estimate: 20 minutes
  - Dependencies: 2.1.2
  - Automation: task_2.1.4.yml → verify_postgresql_setup.yml
  - Completed on: 2026-01-19

### Task Group 2.2: Mail Transfer Layer (MTA/IMAP)

Status: IN PROGRESS (2 of 5 tasks complete)

Tasks:

- [x] Task 2.2.1: Install and Configure Postfix MTA

  - Estimate: 60 minutes
  - Dependencies: 2.1.4
  - Automation: task_2.2.1.yml → install_postfix.yml
  - Deliverables:
    - Postfix installed with PostgreSQL integration
    - Virtual domain support configured
    - SMTP (port 25) and Submission (port 587) active
    - Database queries validated
  - Completed on: 2026-01-22

- [x] Task 2.2.2: Install and Configure Dovecot IMAP

  - Estimate: 60 minutes
  - Dependencies: 2.2.1
  - Automation: task_2.2.2.yml → install_dovecot.yml
  - Deliverables:
    - Dovecot 2.4 installed with dovecot-pgsql package (Debian 13 requirement)
    - Inline SQL authentication configured (Dovecot 2.4 style)
    - IMAP (port 143) and IMAPS (port 993) active
    - LMTP service configured for Postfix integration
    - Authentication tested and working
  - Completed on: 2026-01-22

- [ ] Task 2.2.3: Configure OpenDKIM for Email Authentication

  - Estimate: 45 minutes
  - Dependencies: 2.2.2
  - Automation: task_2.2.3.yml → install_opendkim.yml
  - Deliverables:
    - OpenDKIM installed and configured
    - DKIM keys generated for phalkons.com
    - Postfix integrated with OpenDKIM
    - DNS records provided (DKIM, SPF, DMARC)

- [ ] Task 2.2.4: Generate Let's Encrypt SSL Certificates

  - Estimate: 30 minutes
  - Dependencies: 2.2.3
  - Automation: task_2.2.4.yml → install_letsencrypt.yml
  - Deliverables:
    - Certbot installed
    - SSL certificates generated for:
      - cucho1.phalkons.com (primary hostname)
      - mail.phalkons.com (mail server alias)
    - Postfix updated with Let's Encrypt certificates
    - Dovecot updated with Let's Encrypt certificates
    - Auto-renewal configured (certbot systemd timer)
    - all.yml updated with production certificate paths
  - Notes:
    - Replaces self-signed certificates (ssl-cert-snakeoil)
    - Eliminates "untrusted certificate" warnings
    - Required for production email client connections

- [ ] Task 2.2.5: End-to-End Mail Flow Testing
  - Estimate: 45 minutes
  - Dependencies: 2.2.4
  - Automation: task_2.2.5.yml → test_mail_flow.yml (previously task_2.2.4.yml)
  - Deliverables:
    - Send test email via SMTP
    - Receive test email via IMAP
    - Verify DKIM signatures
    - Test authentication (PLAIN, LOGIN)
    - Verify TLS/SSL connections
    - Complete mail flow validation report

---

## Task Status Summary

**Milestone 1 - Environment Setup:** ✅ 100% Complete (17/17 tasks)
**Milestone 2 - Mail Server Core:** 🔄 40% Complete (6/15 tasks)

- Task Group 2.1 - PostgreSQL: ✅ 100% (4/4 tasks)
- Task Group 2.2 - Mail Transfer: 🔄 40% (2/5 tasks)

**Next Up:** Task 2.2.3 - Configure OpenDKIM

**Legend:**

- [x] Complete
- [ ] Not Started
- [~] In Progress
- [!] Blocked
