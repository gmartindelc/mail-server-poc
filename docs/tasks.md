# Mail Server Cluster PoC - Task Tracking

## **Milestone 1: Environment Setup & Foundation**

**Target Completion:** Week 1, Day 3  
**Status:** [ ]

### **Task Group 1.1: VPS Provisioning & Base Configuration**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 1.1.1:** Provision Vultr VPS (2CPU/4GB/80GB SSD) with Debian 13
      Use file `Vultr_specs.md` for server details Using Terraform

  - _Estimate:_ 30 minutes
  - _Dependencies:_ None
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.1.2:** Configure basic system hardening (SSH, firewall, updates)

  - _Estimate:_ 1 hour
  - _Dependencies:_ 1.1.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.1.3:** Integrate VPS into WireGuard VPN (10.100.0.0/24)

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 1.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.1.4:** Configure network interfaces and DNS resolution
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.1.3
  - _Assigned to:_
  - _Completed on:_

### **Task Group 1.2: Directory Structure & Storage**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 1.2.1:** Create mail system directory structure

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 1.1.1

  ```
  /var/mail/vmail/
  /var/mail/queue/
  /var/mail/backups/
  /opt/postgres/data/
  /opt/postgres/wal_archive/
  ```

  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.2.2:** Set proper permissions and ownership for directories

  - _Estimate:_ 15 minutes
  - _Dependencies:_ 1.2.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 1.2.3:** Configure disk quotas for /var/mail/vmail/
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.2.2
  - _Assigned to:_
  - _Completed on:_

---

## **Milestone 2: Database Layer Implementation**

**Target Completion:** Week 1, Day 5  
**Status:** [ ]

### **Task Group 2.1: PostgreSQL Container Deployment**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 2.1.1:** Install Docker and configure for PostgreSQL

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 2.1.2:** Deploy PostgreSQL 17 alpine container

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 2.1.1, 1.2.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 2.1.3:** Configure VPN-only binding (5432 on VPN interface only)

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 2.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 2.1.4:** Set up persistent storage mapping
  - _Estimate:_ 15 minutes
  - _Dependencies:_ 2.1.2
  - _Assigned to:_
  - _Completed on:_

### **Task Group 2.2: Database Schema & Users**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 2.2.1:** Create initial database and schema

  - _Estimate:_ 1 hour
  - _Dependencies:_ 2.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 2.2.2:** Implement tables from planning.md Section 6.1

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 2.2.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 2.2.3:** Create service-specific database users with least privilege

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 2.2.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 2.2.4:** Set up initial test domains and users
  - _Estimate:_ 20 minutes
  - _Dependencies:_ 2.2.3
  - _Assigned to:_
  - _Completed on:_

---

## **Milestone 3: Mail Services Core**

**Target Completion:** Week 2, Day 2  
**Status:** [ ]

### **Task Group 3.1: Postfix Installation & Configuration**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 3.1.1:** Install Postfix 3.8+ and dependencies

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 2.2.3
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 3.1.2:** Configure Postfix for PostgreSQL authentication

  - _Estimate:_ 1 hour
  - _Dependencies:_ 3.1.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 3.1.3:** Set up public-facing SMTP services (ports 25, 587, 465)

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 3.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 3.1.4:** Configure transport maps and virtual domains
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 3.1.3
  - _Assigned to:_
  - _Completed on:_

### **Task Group 3.2: Dovecot Installation & Configuration**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 3.2.1:** Install Dovecot 2.3+ and IMAP/POP3 components

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 3.1.4
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 3.2.2:** Configure Dovecot for PostgreSQL authentication

  - _Estimate:_ 1 hour
  - _Dependencies:_ 3.2.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 3.2.3:** Set up Maildir storage and quota management

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 3.2.2, 1.2.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 3.2.4:** Configure VPN-only service binding (ports 143, 993)
  - _Estimate:_ 20 minutes
  - _Dependencies:_ 3.2.3
  - _Assigned to:_
  - _Completed on:_

---

## **Milestone 4: Security & Filtering**

**Target Completion:** Week 2, Day 5  
**Status:** [ ]

### **Task Group 4.1: Rspamd Spam Filtering**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 4.1.1:** Install Rspamd 3.6+ and controller

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 3.1.4
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 4.1.2:** Integrate Rspamd with Postfix

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 4.1.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 4.1.3:** Configure Rspamd with PostgreSQL for user settings

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 4.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 4.1.4:** Set up basic spam filtering rules and thresholds
  - _Estimate:_ 1 hour
  - _Dependencies:_ 4.1.3
  - _Assigned to:_
  - _Completed on:_

### **Task Group 4.2: SSL/TLS & Security Hardening**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 4.2.1:** Install and configure Certbot for Let's Encrypt

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 3.1.3
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 4.2.2:** Obtain SSL certificates for public domains

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 4.2.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 4.2.3:** Configure TLS for all services (Postfix, Dovecot)

  - _Estimate:_ 1 hour
  - _Dependencies:_ 4.2.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 4.2.4:** Install and configure Fail2ban with VPN-aware rules
  - _Estimate:_ 45 minutes
  - _Dependencies:_ 3.1.3, 3.2.4
  - _Assigned to:_
  - _Completed on:_

---

## **Milestone 5: Groupware & Web Services**

**Target Completion:** Week 3, Day 1  
**Status:** [ ]

### **Task Group 5.1: SOGo Installation & Configuration**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 5.1.1:** Install SOGo 5.x and dependencies

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 2.2.3
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 5.1.2:** Configure SOGo for PostgreSQL backend

  - _Estimate:_ 1 hour
  - _Dependencies:_ 5.1.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 5.1.3:** Set up CalDAV and CardDAV services

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 5.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 5.1.4:** Configure ActiveSync for mobile devices
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 5.1.3
  - _Assigned to:_
  - _Completed on:_

### **Task Group 5.2: Nginx Reverse Proxy**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 5.2.1:** Install Nginx 1.24+

  - _Estimate:_ 20 minutes
  - _Dependencies:_ 4.2.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 5.2.2:** Configure reverse proxy for SOGo (VPN-only)

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 5.2.1, 5.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 5.2.3:** Set up SSL termination for web services

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 5.2.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 5.2.4:** Configure ACME challenge for certificate renewal
  - _Estimate:_ 20 minutes
  - _Dependencies:_ 5.2.3
  - _Assigned to:_
  - _Completed on:_

---

## **Milestone 6: Monitoring & Backup**

**Target Completion:** Week 3, Day 3  
**Status:** [ ]

### **Task Group 6.1: Wazuh Integration**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 6.1.1:** Install and register Wazuh agent

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 1.1.3
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 6.1.2:** Configure custom decoders for mail services

  - _Estimate:_ 1 hour
  - _Dependencies:_ 6.1.1, 3.1.4, 3.2.4
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 6.1.3:** Set up alert thresholds from PRD Section 4.6

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 6.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 6.1.4:** Configure health check monitoring
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 6.1.3
  - _Assigned to:_
  - _Completed on:_

### **Task Group 6.2: Backup System Implementation**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 6.2.1:** Create PostgreSQL backup scripts

  - _Estimate:_ 1 hour
  - _Dependencies:_ 2.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 6.2.2:** Set up configuration backup procedures

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 6.2.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 6.2.3:** Implement mail data backup strategy

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 6.2.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 6.2.4:** Configure cron jobs for backup schedule
  - _Estimate:_ 20 minutes
  - _Dependencies:_ 6.2.3
  - _Assigned to:_
  - _Completed on:_

---

## **Milestone 7: Testing & Validation**

**Target Completion:** Week 3, Day 5  
**Status:** [ ]

### **Task Group 7.1: Functional Testing**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 7.1.1:** Test inbound email delivery

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 4.1.4
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 7.1.2:** Test outbound email delivery with authentication

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 7.1.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 7.1.3:** Test IMAP/POP3 access via VPN

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 7.1.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 7.1.4:** Test webmail interface and calendar sync
  - _Estimate:_ 45 minutes
  - _Dependencies:_ 5.2.3
  - _Assigned to:_
  - _Completed on:_

### **Task Group 7.2: Performance & Security Validation**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 7.2.1:** Validate VPN-only access restrictions

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 4.2.4
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 7.2.2:** Test backup restoration procedure

  - _Estimate:_ 1 hour
  - _Dependencies:_ 6.2.4
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 7.2.3:** Measure performance against PRD targets

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 7.1.4
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 7.2.4:** Conduct security scan and vulnerability assessment
  - _Estimate:_ 1 hour
  - _Dependencies:_ 7.2.3
  - _Assigned to:_
  - _Completed on:_

---

## **Milestone 8: Documentation & Handover**

**Target Completion:** Week 3, Day 5  
**Status:** [ ]

### **Task Group 8.1: Documentation Completion**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 8.1.1:** Complete installation and configuration guides

  - _Estimate:_ 2 hours
  - _Dependencies:_ 7.2.4
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 8.1.2:** Create troubleshooting and maintenance runbooks

  - _Estimate:_ 1.5 hours
  - _Dependencies:_ 8.1.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 8.1.3:** Document backup and recovery procedures

  - _Estimate:_ 1 hour
  - _Dependencies:_ 7.2.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 8.1.4:** Create monitoring and alerting guide
  - _Estimate:_ 45 minutes
  - _Dependencies:_ 6.1.4
  - _Assigned to:_
  - _Completed on:_

### **Task Group 8.2: Success Criteria Validation**

**Status:** [ ]

#### **Tasks:**

- [ ] **Task 8.2.1:** Verify all PRD success metrics are met

  - _Estimate:_ 1 hour
  - _Dependencies:_ 8.1.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 8.2.2:** Conduct final security audit

  - _Estimate:_ 45 minutes
  - _Dependencies:_ 8.2.1
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 8.2.3:** Prepare handover documentation

  - _Estimate:_ 30 minutes
  - _Dependencies:_ 8.2.2
  - _Assigned to:_
  - _Completed on:_

- [ ] **Task 8.2.4:** Update project status and lessons learned
  - _Estimate:_ 30 minutes
  - _Dependencies:_ 8.2.3
  - _Assigned to:_
  - _Completed on:_

---

## **Discovered Tasks & Technical Debt**

**Status:** [ ]

### **Future Enhancements:**

- [ ] **Task FT-1:** Ansible playbook creation for automation

  - _Priority:_ P2
  - _Estimate:_ 4 hours
  - _Notes:_ Post-PoC automation

- [ ] **Task FT-2:** DNS record configuration (SPF, DKIM, DMARC)

  - _Priority:_ P1
  - _Estimate:_ 1 hour
  - _Notes:_ Required for email deliverability

- [ ] **Task FT-3:** Multi-domain support enhancements

  - _Priority:_ P2
  - _Estimate:_ 2 hours
  - _Notes:_ Based on business growth

- [ ] **Task FT-4:** Performance optimization tuning
  - _Priority:_ P3
  - _Estimate:_ 2 hours
  - _Notes:_ After load testing

### **Technical Debt:**

- [ ] **Task TD-1:** Refactor configuration file organization

  - _Priority:_ P3
  - _Estimate:_ 1.5 hours
  - _Notes:_ Improve maintainability

- [ ] **Task TD-2:** Implement configuration versioning
  - _Priority:_ P2
  - _Estimate:_ 1 hour
  - _Notes:_ Git-based configuration tracking

---

## **Task Status Legend**

- [ ] **To Do:** Task not started
- [ - ] **In Progress:** Task currently being worked on
- [ X ] **Completed:** Task finished and verified
- [ ~ ] **Blocked:** Task cannot proceed due to dependency or issue
- [ > ] **Deferred:** Task postponed to later phase

## **Priority Levels**

- **P0:** Critical path, must complete for PoC success
- **P1:** Important, required for core functionality
- **P2:** Nice to have, improves quality or usability
- **P3:** Future enhancement, can be postponed

---

**Last Updated:** 2025-12-15  
**Next Review:** Daily during implementation  
**Total Estimated Effort:** ~40-50 hours  
**Critical Path:** Milestones 1 → 2 → 3 → 4 → 5 → 7
