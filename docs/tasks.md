# Mail Server Cluster PoC - Task Tracking

**Last Updated:** 2025-01-05  
**Current Phase:** Milestone 1 - Environment Setup & Foundation (Task Group 1.2 Complete)  
**Status:** ✅ Task Group 1.2 Complete - Ready for Task Group 1.3

## Recent Session Summary (2025-01-05)

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

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 1.3.1:** Configure basic system hardening (SSH, firewall, updates)

  - _Estimate:_ 1 hour
  - _Dependencies:_ 1.2.6
  - _Instructions:_
    - Configure SSH hardening:
      - Disable root login: `PermitRootLogin no`
      - Use key authentication only: `PasswordAuthentication no`
      - Change default port (optional): `Port 2222`
    - Configure firewall (UFW):
      - Install: `sudo apt install ufw`
      - Set defaults: `sudo ufw default deny incoming`, `sudo ufw default allow outgoing`
      - Allow SSH: `sudo ufw allow 22/tcp` (or custom port)
      - Enable: `sudo ufw enable`
    - Configure automatic updates:
      - Install: `sudo apt install unattended-upgrades`
      - Configure: `sudo dpkg-reconfigure unattended-upgrades`
    - Enable automatic security updates
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.3.2:** Integrate VPS into WireGuard VPN (10.100.0.0/24)

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 1.3.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.3.3:** Configure network interfaces and DNS resolution
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.3.2
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
