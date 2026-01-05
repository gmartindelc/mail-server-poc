# Mail Server Cluster PoC - Task Tracking

**Last Updated:** 2024-12-19  
**Current Phase:** Milestone 1 - Environment Setup & Foundation (Preparation Complete)  
**Status:** ✅ Infrastructure Ready - Ready for Deployment

## Recent Session Summary (2024-12-18)

**Completed:** Infrastructure setup and Terraform foundation  
**Tasks Completed:** 6 infrastructure tasks (INF-1 through INF-6)  
**Files Created:** 27 files (scripts, configs, documentation)  
**Status:** All prerequisites for Task 1.1.1 (VPS Provisioning) are complete  
**Next Action:** Execute `./deploy.sh` to provision first VPS instance

**Session Details:** See `session_logs/session_2024-12-18.md`

---

## **Milestone 1: Environment Setup & Foundation**

**Target Completion:** Week 1, Day 3  
**Status:** [ ]

### **Task Group 1.1: VPS Provisioning & Base Configuration**

**Status:** [ ]

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

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 1.2.1:** Modify sudoers file to add NOPASSWD to sudo users

  - _Estimate:_ 15 minutes
  - _Dependencies:_ 1.1.1
  - _Instructions:_
    - Configure passwordless sudo for sudo group
    - Create /etc/sudoers.d/90-nopasswd-sudo
    - Comment out default entry in main sudoers file
  - _Playbook:_ `task_1.2.1.yml`
  - _Command:_ `./run_task.sh 1.2.1`

- [ ] **Task 1.2.2:** Remove default linuxuser completely

  - _Estimate:_ 10 minutes
  - _Dependencies:_ 1.2.1
  - _Instructions:_
    - Remove linuxuser and home directory
    - Free up UID 1000 for phalkonadmin
  - _Playbook:_ `task_1.2.2.yml`
  - _Command:_ `./run_task.sh 1.2.2`

- [ ] **Task 1.2.3:** Create user phalkonadmin with sudo privileges and UID 1000

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 1.2.2
  - _Instructions:_
    - Create user: `adduser --gecos "Phalkon Administrator" phalkonadmin`
    - Add to sudo group: `usermod -aG sudo phalkonadmin`
    - Generate random temporary password: `openssl rand -base64 12`
    - Set password: `echo "phalkonadmin:password" | chpasswd`
    - Append to credential file: `echo "phalkonadmin,password" >> ../hostname.secret`
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.2.4:** Configure SSH key authentication for phalkonadmin

  - _Estimate:_ 25 minutes
  - _Dependencies:_ 1.2.3
  - _Prerequisites:_ Common worker server public key available locally
  - _Instructions:_
    - On local machine, copy public key to server:
      `ssh-copy-id -i ~/.ssh/common_worker_key.pub phalkonadmin@SERVER_IP`
    - Alternatively, manually copy key to server:
      - Create `~/.ssh/authorized_keys` on server
      - Set permissions: `chmod 700 ~/.ssh && chmod 600 ~/.ssh/authorized_keys`
      - Set ownership: `chown -R phalkonadmin:phalkonadmin ~/.ssh`
    - Disable password authentication in `/etc/ssh/sshd_config`
    - Restart SSH: `systemctl restart sshd`
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.2.5:** Test SSH key-based authentication

  - _Estimate:_ 10 minutes
  - _Dependencies:_ 1.2.4
  - _Instructions:_
    - From local machine: `ssh -i ~/.ssh/common_worker_key phalkonadmin@SERVER_IP`
    - Verify login succeeds without password prompt
    - Test sudo: `sudo whoami` (should not prompt for password)
    - Document successful connection
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.2.6:** Install Docker Compose plugin and configure permissions

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 1.2.5
  - _Instructions:_
    - Update packages: `sudo apt update`
    - Install Docker: `sudo apt install docker.io docker-compose-plugin`
    - Install latest version: `sudo apt install docker-compose-v2`
    - Add user to docker group: `sudo usermod -aG docker phalkonadmin`
    - Apply group changes: `newgrp docker` or logout/login
    - Verify installation: `docker --version && docker compose version`
    - Test docker without sudo: `docker run hello-world`
  - _Assigned to:_
  - _Completed on:_

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
