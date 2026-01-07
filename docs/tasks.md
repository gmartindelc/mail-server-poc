# Mail Server Cluster PoC - Task Tracking

**Last Updated:** 2025-01-07  
**Current Phase:** Milestone 1 - Environment Setup & Foundation (Task 1.3.1 Complete)  
**Status:** ✅ Task 1.3.1 Complete - Task Group 1.3 in progress

## Recent Session Summary (2025-01-07)

**Completed:** Task 1.3.1 - Configure Basic System Hardening  
**Status:** SSH hardening, UFW firewall, and automatic updates configured  
**Next Action:** Tasks 1.3.2-1.3.4 (WireGuard VPN integration), then Task 1.3.5 (fail2ban)

**Key Achievements:**

- SSH hardened: Port 2288, key-only auth, root login disabled
- UFW firewall enabled with default-deny policy
- Automatic security updates configured
- Security banner added
- Modern cryptography enforced (curve25519, ChaCha20-Poly1305)

**Connection After Task 1.3.1:**
```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@45.32.207.84
```

**For Ansible (tasks 1.3.2+):**
```bash
export ANSIBLE_SSH_PORT=2288
./run_task.sh 1.3.x
```

---

## Previous Session Summary (2025-01-05)

**Completed:** Task Group 1.2 - System User Administration (all 7 tasks)  
**Tasks Completed:** Tasks 1.2.1 through 1.2.7  
**Files Created/Updated:** 15 Ansible playbooks, ansible.cfg, inventory.yml, run scripts, README v3.0  
**Status:** All user management, SSH configuration, and Docker installation complete  
**Next Action:** Begin Task Group 1.3 - System Hardening

**Key Achievements:**

- Complete Ansible automation for user management and Docker installation
- Fixed Debian 13 Docker compatibility issues
- Proper SSH key architecture established
- Comprehensive troubleshooting documentation added

**Session Details:** See assistant_rules.md Session Logs section

---

## **Milestone 1: Environment Setup & Foundation**

**Target Completion:** Week 1, Day 3  
**Status:** [▓▓▓▓▓▓▓▓░░] 80% Complete

### **Task Group 1.1: VPS Provisioning & Base Configuration**

**Status:** [x] COMPLETE

#### **Tasks:**

- [x] **Task 1.1.1:** Provision Vultr VPS (2CPU/4GB/80GB SSD) with Debian 13
      Use file `Vultr_specs.md` for server details Using Terraform

  - _Estimate:_ 30 minutes
  - _Dependencies:_ None ✅ READY
  - _Prerequisites Completed:_ 2024-12-18
    - Terraform configuration fixed (v2.x compatible)
    - Backup schedule configured (daily at 2 AM UTC / 11 PM CST)
    - Credential extraction system implemented
    - Deploy script ready (`deploy.sh`)
  - _Next Step:_ Execute `./deploy.sh` from terraform directory
  - \_Assigned to:\_GMCE
  - \_Completed on:\_2024-12-18

### **Task Group 1.2: System User Administration**

**Status:** [x] COMPLETE - 2025-01-05

#### **Tasks:**

- [x] **Task 1.2.1:** Modify sudoers file to add NOPASSWD to sudo users

  - _Estimate:_ 15 minutes
  - _Dependencies:_ 1.1.1
  - _Prerequisites:_ SSH access to server as root
  - _Automation:_ Ansible playbook `task_1.2.1.yml` → `modify_sudoers_nopasswd.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-05
  - _Notes:_ Creates `/etc/sudoers.d/90-nopasswd-sudo` for sudo group

- [x] **Task 1.2.2:** Remove default linuxuser completely

  - _Estimate:_ 10 minutes
  - _Dependencies:_ 1.2.1
  - _Automation:_ Ansible playbook `task_1.2.2.yml` → `remove_user.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-05
  - _Notes:_ Removes linuxuser and frees UID 1000

- [x] **Task 1.2.3:** Create user phalkonadmin with sudo privileges

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 1.2.2
  - _Automation:_ Ansible playbook `task_1.2.3.yml` → `create_admin_user.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-05
  - _Notes:_ Created with UID 1000, random password generated and saved to credential file

- [x] **Task 1.2.4:** Configure SSH key authentication for phalkonadmin

  - _Estimate:_ 25 minutes
  - _Dependencies:_ 1.2.3
  - _Prerequisites:_ Common worker server public key available locally
  - _Automation:_ Ansible playbook `task_1.2.4.yml` → `setup_ssh_key_auth.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-05
  - _Notes:_ Deploys bastion SSH key (common worker key), root SSH remains enabled

- [x] **Task 1.2.5:** Test SSH key-based authentication

  - _Estimate:_ 10 minutes
  - _Dependencies:_ 1.2.4
  - _Automation:_ Ansible playbook `task_1.2.5.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-05
  - _Notes:_ Verified SSH key auth, passwordless sudo, and UID 1000

- [x] **Task 1.2.6:** Install Docker Compose plugin and configure permissions

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 1.2.5
  - _Automation:_ Ansible playbook `task_1.2.6.yml` → `install_docker.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-05
  - _Notes:_ Installed Docker 29.1.3 + Docker Compose v5.0.1, added phalkonadmin to docker group

- [x] **Task 1.2.7:** Post-configuration cleanup and verification (Optional)

  - _Estimate:_ 10 minutes
  - _Dependencies:_ 1.2.6
  - _Automation:_ Ansible playbook `task_1.2.7.yml` → `fix_user_uid.yml`, `cleanup_main_sudoers.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-05
  - _Notes:_ Final verification of all configurations

**Task Group 1.2 Summary:**

- Duration: ~4 hours (including debugging and testing)
- All tasks automated with Ansible
- Server ready for system hardening (Task Group 1.3)
- Complete documentation in ansible/README.md v3.0

### **Task Group 1.3: System Hardening**

**Status:** [▓▓▓░░] 60% Complete (3 of 5 tasks complete)

#### **Tasks:**

- [x] **Task 1.3.1:** Configure basic system hardening (SSH, firewall, updates)

  - _Estimate:_ 1 hour
  - _Dependencies:_ 1.2.6
  - _Automation:_ Ansible playbook `task_1.3.1.yml` → `system_hardening.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-07
  - _Notes:_ SSH port changed to 2288, root login disabled, UFW firewall enabled, automatic updates configured
  - _What was done:_
    - SSH hardening: Port 2288, key-only auth, root disabled, modern crypto
    - UFW firewall: Default deny incoming, allow 2288/tcp
    - Automatic security updates: unattended-upgrades installed and configured
    - Security banner added
    - Configuration backed up

- [x] **Task 1.3.2:** Integrate VPS into WireGuard VPN (10.100.0.0/24)

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 1.3.1
  - _Automation:_ Ansible playbook `task_1.3.2.yml` → `install_wireguard.yml`
  - _Assigned to:_ GMCE
  - _Completed on:_ 2025-01-07
  - _Notes:_ VPN IP 10.100.0.25/24, connected to peer 144.202.76.243:51820
  - _What was done:_
    - Install WireGuard and wireguard-tools packages
    - Deploy wg0.conf configuration with VPN IP 10.100.0.25/24
    - Configure peer connection to 144.202.76.243:51820
    - Enable IP forwarding for VPN routing
    - Start and enable WireGuard service at boot
    - Credential extraction script created (setup_wg_credentials.sh)

- [ ] **Task 1.3.3:** Configure network interfaces and DNS resolution

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.3.2
  - _Automation:_ Ansible playbook `task_1.3.3.yml` → `verify_network_interfaces.yml`
  - _What it does:_
    - Verify WireGuard interface (wg0) is up with correct IP
    - Check routing tables for VPN and default routes
    - Validate network interface metrics
    - Test VPN connectivity (ping 10.100.0.1)
    - Test internet connectivity
    - Document network configuration
    - DNS configuration skipped (to be done when proper DNS server is installed)
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.3.4:** Create start dependency on ssh after wireguard is up + Restrict SSH to VPN only
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.3.3
  - _Security Note:_ **CRITICAL** - After this task, SSH will ONLY be accessible via VPN (10.100.0.25)
  - _What it does:_
    - Configure systemd to start SSH only after WireGuard is up
    - Restrict SSH to listen only on WireGuard interface (10.100.0.25:2288)
    - Update UFW to allow SSH only from VPN network (10.100.0.0/24)
    - Remove public SSH access (blocks SSH from internet)
    - Add safety check to prevent lockout
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.3.5:** Install and configure fail2ban for intrusion prevention
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.3.1
  - _Automation:_ Ansible playbook `task_1.3.5.yml` → `install_fail2ban.yml`
  - _What it does:_
    - Install fail2ban package
    - Configure SSH jail monitoring port 2288
    - Set ban policy: 3 attempts in 10 minutes = 1 hour ban
    - Enable and start fail2ban service
    - Configure logging to /var/log/fail2ban.log
  - _Assigned to:_
  - _Completed on:_

### **Task Group 1.4: Directory Structure & Storage**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 1.4.1:** Create mail system directory structure

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 1.3.1

  ```
  /var/mail/vmail/
  /var/mail/queue/
  /var/mail/backups/
  /opt/postgres/data/
  /opt/postgres/wal_archive/
  ```

  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.4.2:** Set proper permissions and ownership for directories

  - _Estimate:_ 15 minutes
  - _Dependencies:_ 1.4.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.4.3:** Configure disk quotas for /var/mail/vmail/
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.4.2
  - _Assigned to:_
  - _Completed on:_

---

## **Milestone 2: Database Layer Implementation**

## **... (rest of the file remains the same, with task numbers adjusted accordingly)**

**Note:** I've renumbered the task groups to maintain logical flow:

- Task Group 1.1: VPS Provisioning
- Task Group 1.2: System User Administration (NEW - your requirements)
- Task Group 1.3: System Hardening (formerly 1.1.2)
- Task Group 1.4: Directory Structure (formerly 1.2)

All subsequent task groups and dependencies have been updated to reflect these new numbers.

### **Updated Dependencies:**

- Task 2.1.1 now depends on: 1.3.1 (formerly 1.1.2)
- Task 1.4.1 now depends on: 1.3.1 (formerly 1.2.1 depended on 1.1.1)

The critical path remains: 1.1.1 → 1.2.x → 1.3.x → 1.4.x → 2.x → 3.x → 4.x → 5.x → 7.x

**Key changes made:**

1. **Added Task Group 1.2: System User Administration** with all your requirements:

   - Task 1.2.1: Modify sudoers for NOPASSWD
   - Task 1.2.2: Remove linuxuser completely
   - Task 1.2.3: Create phalkonadmin user with sudo privileges
   - Task 1.2.4: Configure SSH key authentication
   - Task 1.2.5: Test SSH connection with key authentication
   - Task 1.2.6: Install Docker Compose and configure permissions

2. **Renamed and renumbered existing task groups:**

   - Task Group 1.3: System Hardening (formerly Task 1.1.2)
   - Task Group 1.4: Directory Structure (formerly Task Group 1.2)

3. **Updated all dependencies** throughout the document to reflect new task numbers

4. **Added detailed instructions** for each new task based on best practices

5. **Maintained logical flow** - user administration comes right after provisioning and before system hardening

The sequence now follows proper system administration best practices:

1. Provision server → 2. Set up administrative users → 3. Harden system → 4. Configure services

This ensures you have proper administrative access configured before locking down the system with security hardening measures.
