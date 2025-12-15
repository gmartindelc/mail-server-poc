# **Mail Server Cluster Proof of Concept - Project Requirements Document**

## **1. Executive Summary**

**Project Name:** Experimental Mail Cluster PoC (Phase 1)
**Purpose:** Establish a production-ready mail server architecture with cluster capabilities for eventual high-availability deployment.
**Environment:** Vultr VPS (2CPU/4GB/80GB SSD) running Debian 13, integrated into existing WireGuard VPN infrastructure (10.100.0.0/24).
**Timeline:** 2-3 weeks for PoC completion

## **2. Business Requirements**

### **2.1 Primary Objectives**

- Replace unreliable containerized mail solutions with stable, maintainable infrastructure
- Create scalable foundation for future 3-node mail cluster
- Maintain security isolation via existing VPN architecture
- Ensure business continuity with proper backup/restore capabilities

### **2.2 Success Criteria**

- **Stability:** 99.5% uptime during PoC phase (30 days)
- **Performance:** <2 second email delivery within VPN, <5 seconds external
- **Security:** Zero critical vulnerabilities in initial security audit
- **Recoverability:** Full restore from backup within 30 minutes

## **3. User Stories**

### **3.1 System Administrator Stories**

**As a** System Administrator
**I want to** deploy individual mail service components manually
**So that** I can understand the architecture for future Ansible automation

**As a** System Administrator
**I want to** access all administrative interfaces only through the VPN
**So that** attack surface is minimized

**As a** System Administrator
**I want to** monitor mail server metrics in Wazuh dashboard
**So that** I can proactively identify issues

### **3.2 End User Stories**

**As a** Company Employee
**I want to** access email, calendar, and contacts securely
**So that** I can communicate and organize work effectively

**As a** Company Employee
**I want to** use my preferred email client (Thunderbird, Outlook, mobile)
**So that** I can work with familiar tools

### **3.3 Security Stories**

**As a** Security Officer
**I want to** ensure all internal services are VPN-only accessible
**So that** unauthorized external access is prevented

**As a** Security Officer
**I want to** implement proper SPF, DKIM, and DMARC
**So that** email deliverability and authenticity are ensured

## **4. Technical Requirements**

### **4.1 Network Architecture**

#### **Public-Facing Services (Internet)**

- **SMTP (Port 25):** Inbound mail reception
- **SMTP Submission (Port 587):** Authenticated outbound mail
- **SMTPS (Port 465):** Alternative secure submission
- **HTTP/HTTPS (Ports 80/443):** Certificate renewal only

#### **VPN-Only Services (10.100.0.0/24)**

- **IMAP (143), IMAPS (993):** Email access
- **POP3 (110), POP3S (995):** Legacy email access
- **SOGo Web Interface (443):** Webmail, Calendar, Contacts
- **PostgreSQL (5432):** Database access
- **SSH (22):** Administrative access (restricted to bastion)

#### **Network Security Requirements**

- All VPN services reject connections from public IPs
- Bastion server (10.100.0.30) is only SSH gateway
- Wazuh agent communication to 10.100.0.31
- Internet access required for: NTP, package updates, Let's Encrypt

### **4.2 Component Stack Requirements**

#### **Core Components**

1. **Postfix 3.8+:** MTA with PostgreSQL backend
2. **Dovecot 2.3+:** IMAP/POP3 with PostgreSQL backend
3. **PostgreSQL 17:** Containerized database (alpine)
4. **SOGo 5.x:** Groupware (CalDAV, CardDAV, ActiveSync)
5. **Rspamd 3.6+:** Spam filtering
6. **Nginx 1.24+:** Reverse proxy for web services

#### **Integration Requirements**

- All components authenticate against PostgreSQL database
- Database schema supports multi-domain, multi-tenant structure
- Failover considerations designed into schema
- All configurations stored in version control

### **4.3 Database Cluster Requirements**

#### **PostgreSQL Container Specifications**

- **Image:** postgres:17-alpine
- **Network:** Host network, VPN-only binding
- **Storage:** Persistent volume for data directory
- **Backup:** Daily WAL archiving to persistent storage
- **Schema:** Cluster-ready with proper sequences and constraints

#### **Database Tables Required**

- Virtual domains and users
- Aliases and forwards
- SOGo user profiles and sessions
- Quota management
- Audit logging

### **4.4 Storage Requirements**

#### **Directory Structure**

```
/var/mail/
├── vmail/              # User mailboxes (Maildir)
├── queue/              # Postfix queue
└── backups/           # Local backups

/opt/postgres/
├── data/              # PostgreSQL data
└── wal_archive/       # WAL files
```

#### **Quota Management**

- Default: 1GB per mailbox
- Configurable per user
- Soft/hard quota enforcement
- Quota warnings at 80%, 90%

### **4.5 Security Requirements**

#### **Authentication & Authorization**

- PostgreSQL authentication for all services
- SHA512-CRYPT password hashing
- Two-factor authentication readiness
- Service-specific database users with least privilege

#### **Certificate Management**

- Let's Encrypt certificates for public domains
- Internal CA for VPN services (optional)
- Auto-renewal with post-hook service restarts
- Certificate monitoring and alerting

#### **Access Controls**

- VPN-only access for all administrative interfaces
- Bastion host required for SSH access
- Fail2ban with VPN-aware configurations
- Rate limiting on authentication attempts

### **4.6 Monitoring Requirements**

#### **Wazuh Integration**

- Agent installation and registration
- Custom decoders for mail services
- Alert thresholds for:
  - Queue length > 100
  - Failed authentication > 5/minute
  - Disk usage > 80%
  - Service downtimes

#### **Health Checks**

- **SMTP:** HELO/EHLO, TLS, authentication
- **IMAP:** Login, folder listing, message retrieval
- **Database:** Connection, replication lag, disk space
- **Web:** SOGo login, calendar access

### **4.7 Backup & Recovery Requirements**

#### **Backup Strategy**

- **Frequency:** Daily incremental, weekly full
- **Retention:** 7 daily, 4 weekly, 12 monthly
- **Components:** Database, configurations, mail data
- **Verification:** Monthly test restore validation

#### **Backup Process**

```
Daily (2 AM):
1. PostgreSQL base backup + WAL
2. Configurations (tar.gz)
3. New/changed mailboxes

Weekly (Friday 2 AM):
1. Full PostgreSQL dump
2. Full configuration archive
3. Complete mail data snapshot

Monthly (Last Friday):
1. Archived to long-term storage
2. Checksum verification
3. Recovery procedure documentation update
```

#### **Recovery Objectives**

- **RTO (Recovery Time Objective):** < 30 minutes
- **RPO (Recovery Point Objective):** < 1 hour data loss
- **Verification:** Quarterly disaster recovery drills

### **4.8 Performance Requirements**

#### **Capacity Planning**

- **Initial:** 30 mailboxes, 2 domains
- **Growth:** Support 100 mailboxes within 6 months
- **Concurrent Connections:** 50+ IMAP, 20+ SMTP
- **Storage:** 80GB SSD with 70% usage threshold

#### **Performance Targets**

- **Email Delivery:** < 5 seconds 95th percentile
- **IMAP Login:** < 2 seconds 95th percentile
- **Search Operations:** < 3 seconds for 10k messages
- **Web Interface:** < 1 second page load

## **5. Success Metrics**

### **5.1 Technical Metrics**

- **Uptime:** 99.5% during PoC (monitored via Wazuh)
- **Delivery Rate:** > 98% successful delivery to major providers
- **Spam Accuracy:** < 0.1% false positives, > 95% spam catch rate
- **Backup Success:** 100% backup completion rate
- **Update Stability:** Zero service disruption during security updates

### **5.2 User Experience Metrics**

- **Email Client Compatibility:** 100% with Thunderbird, Outlook, iOS Mail, Android
- **Calendar Sync:** < 5 second sync latency
- **Mobile Access:** Full ActiveSync functionality
- **Webmail Performance:** < 2 second page loads

### **5.3 Security Metrics**

- **Vulnerability Scan:** Zero critical vulnerabilities
- **Penetration Test:** No successful external intrusions
- **Compliance:** SPF, DKIM, DMARC properly configured
- **Audit:** All authentication attempts logged and alertable

### **5.4 Operational Metrics**

- **Deployment Time:** < 4 hours for clean deployment
- **Recovery Time:** < 30 minutes from backup
- **Monitoring Coverage:** 100% of critical services
- **Documentation:** Complete runbook for all procedures

## **6. Dependencies and Assumptions**

### **6.1 Prerequisites**

- Functional WireGuard VPN infrastructure
- DNS records properly configured (MX, SPF, DKIM, DMARC)
- Vultr VPS with Debian 13 ready
- Bastion server access credentials
- Wazuh agent registration process

### **6.2 Assumptions**

- PostgreSQL container performance is adequate for PoC
- 4GB RAM is sufficient for initial 30 users
- Backup storage available on VPN network
- Team has SSH/VPN access for administration

### **6.3 Risks and Mitigations**

- **Risk:** PostgreSQL container I/O bottlenecks
  **Mitigation:** Monitor performance, plan for dedicated database server
- **Risk:** Single point of failure (single VPS)
  **Mitigation:** Document cluster migration path
- **Risk:** Email deliverability issues
  **Mitigation:** Warm-up plan, reputation monitoring
- **Risk:** Backup/restore complexity
  **Mitigation:** Regular restore testing, documented procedures

## **7. Phase 2 Considerations (Cluster Migration)**

### **7.1 Architectural Extensions**

- **Database:** PostgreSQL streaming replication (1 master, 2 replicas)
- **Application Layer:** 3-node load balanced Postfix/Dovecot
- **Storage:** Distributed storage (Ceph/GlusterFS) or object storage
- **Load Balancer:** HAProxy with health checks

### **7.2 Migration Path**

1. **PoC Validation:** 30-day stability period
2. **Schema Enhancement:** Add clustering fields
3. **Configuration Templates:** Ansible playbook creation
4. **Staged Migration:** Domain-by-domain transition

## **8. Approval & Sign-off**

**Required Approvals:**

- [ ] Security Architecture Review
- [ ] Network Configuration Review
- [ ] Backup/Recovery Procedure Approval
- [ ] Success Metrics Agreement
- [ ] Project Timeline Approval

**Next Steps upon Approval:**

1. Detailed implementation plan with day-by-day tasks
2. Specific command sets for each component
3. Validation checklist for each phase
4. Rollback procedures at each stage

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-15
**Stakeholders:** System Administrators, Security Team, Management  
**Review Cycle:** Weekly during implementation
