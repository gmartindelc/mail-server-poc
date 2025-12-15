# Mail Server Cluster PoC - Project Planning Document

## **1. Project Overview**

### **1.1 Project Status**

- **Phase:** Proof of Concept (Phase 1)
- **Start Date:** [To be determined]
- **Target Completion:** 2-3 weeks from start
- **Current Status:** Planning Phase

### **1.2 Core Objectives**

- Build production-ready mail server on Vultr VPS (2CPU/4GB/80GB SSD)
- Integrate with existing WireGuard VPN (10.100.0.0/24)
- Establish foundation for future 3-node high-availability cluster
- Replace unreliable containerized mail solutions

## **2. Technology Stack**

### **2.1 Operating System & Infrastructure**

- **OS:** Debian 13 (Bookworm)
- **Virtualization:** Vultr VPS
- **Specifications:** 2 vCPU, 4GB RAM, 80GB SSD
- **Network:** Dual-stack (IPv4 + IPv6) with WireGuard VPN integration

### **2.2 Core Mail Services**

| Component      | Version | Purpose                                 | Deployment Method |
| -------------- | ------- | --------------------------------------- | ----------------- |
| **Postfix**    | 3.8+    | Mail Transfer Agent (MTA)               | Native package    |
| **Dovecot**    | 2.3+    | IMAP/POP3 Server                        | Native package    |
| **Rspamd**     | 3.6+    | Spam Filtering                          | Native package    |
| **SOGo**       | 5.x     | Groupware (Webmail, Calendar, Contacts) | Native package    |
| **Nginx**      | 1.24+   | Reverse Proxy & SSL Termination         | Native package    |
| **PostgreSQL** | 17      | Centralized Authentication & Storage    | Docker container  |

### **2.3 Supporting Services**

- **Let's Encrypt:** SSL/TLS certificate management
- **Fail2ban:** Intrusion prevention
- **Wazuh Agent:** Security monitoring
- **Cron:** Automated backups and maintenance
- **Systemd:** Service management

### **2.4 Database Layer**

- **Container Image:** `postgres:17-alpine`
- **Network Mode:** Host networking (VPN-only binding)
- **Storage:** Persistent volume at `/opt/postgres/data/`
- **Backup:** WAL archiving to `/opt/postgres/wal_archive/`

## **3. System Architecture**

### **3.1 Network Architecture Diagram**

```
Internet
    │
    ├── SMTP (25) ─────────────┐
    ├── Submission (587) ───────┤
    ├── SMTPS (465) ────────────┤
    └── HTTP/HTTPS (80/443) ────┤
                                 ↓
                      [Vultr VPS - Mail Server]
                                 │
                      WireGuard VPN (10.100.0.0/24)
                                 │
    ┌─────────────────────────────────────────────┐
    │                                             │
    ▼                                             ▼
[Admin Bastion]                            [Wazuh Server]
10.100.0.30                                10.100.0.31
```

### **3.2 Service Binding Strategy**

| Service             | Port      | Network Binding | Access Control       |
| ------------------- | --------- | --------------- | -------------------- |
| **SMTP (inbound)**  | 25        | Public IP       | All internet         |
| **SMTP Submission** | 587       | Public IP       | VPN + Authentication |
| **IMAPS**           | 993       | VPN only        | VPN clients only     |
| **PostgreSQL**      | 5432      | VPN only        | Local services only  |
| **SOGo Web**        | 443 (VPN) | VPN only        | VPN clients only     |
| **SSH**             | 22        | VPN only        | Bastion server only  |

### **3.3 Data Flow**

1. **Inbound Mail:** Internet → Postfix → Rspamd → Dovecot Maildir
2. **Outbound Mail:** Client → Postfix (auth) → Rspamd → Internet
3. **Client Access:** VPN → IMAP/POP3 or SOGo → PostgreSQL auth
4. **Administration:** Bastion → SSH → Configuration management

## **4. Development Approach**

### **4.1 Phase-Based Implementation**

**Week 1: Foundation & Core Services**

1. System hardening and base configuration
2. PostgreSQL container setup and schema creation
3. Postfix installation and basic configuration
4. Dovecot installation and Maildir structure

**Week 2: Integration & Security**

1. Rspamd integration with Postfix and Dovecot
2. SOGo installation and PostgreSQL integration
3. SSL/TLS certificate setup (Let's Encrypt)
4. VPN-only service binding and firewall rules

**Week 3: Monitoring & Optimization**

1. Wazuh agent integration and custom rules
2. Backup system implementation
3. Performance tuning and load testing
4. Documentation and runbook creation

### **4.2 Configuration Management Strategy**

- **Manual Initial Setup:** All components deployed manually for understanding
- **Documentation Focus:** Detailed step-by-step guides created
- **Version Control:** All configurations stored in git repository
- **Ansible Preparation:** Manual process designed with future automation in mind

### **4.3 Testing Methodology**

| Test Type               | Frequency              | Tools/Methods                            |
| ----------------------- | ---------------------- | ---------------------------------------- |
| **Unit Testing**        | After each component   | Manual validation of individual services |
| **Integration Testing** | After major milestones | End-to-end mail flow testing             |
| **Security Testing**    | Weekly                 | Wazuh alerts, vulnerability scans        |
| **Performance Testing** | End of PoC             | Simulated load with multiple clients     |
| **Recovery Testing**    | Monthly                | Backup restore procedures                |

## **5. Directory Structure**

### **5.1 Planned Filesystem Layout**

```
/
├── etc/
│   ├── postfix/                    # Postfix configuration
│   ├── dovecot/                    # Dovecot configuration
│   ├── rspamd/                     # Rspamd configuration
│   ├── nginx/                      # Nginx configuration
│   └── sogo/                       # SOGo configuration
├── var/
│   └── mail/
│       ├── vmail/                  # User mailboxes (Maildir)
│       │   ├── domain1.com/
│       │   └── domain2.com/
│       ├── queue/                  # Postfix queue
│       └── backups/                # Local backups
├── opt/
│   └── postgres/
│       ├── data/                   # PostgreSQL database
│       └── wal_archive/            # WAL files for recovery
└── home/
    └── mailadmin/                  # Administrative home
        ├── scripts/                # Maintenance scripts
        └── docs/                   # Project documentation
```

## **6. Database Schema Design**

### **6.1 Core Tables**

```sql
-- Virtual domains
CREATE TABLE virtual_domains (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    enabled BOOLEAN DEFAULT true
);

-- Virtual users
CREATE TABLE virtual_users (
    id SERIAL PRIMARY KEY,
    domain_id INTEGER REFERENCES virtual_domains(id),
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    quota_mb INTEGER DEFAULT 1024,
    enabled BOOLEAN DEFAULT true
);

-- Aliases
CREATE TABLE virtual_aliases (
    id SERIAL PRIMARY KEY,
    domain_id INTEGER REFERENCES virtual_domains(id),
    source VARCHAR(255) NOT NULL,
    destination VARCHAR(255) NOT NULL
);

-- SOGo user profiles
CREATE TABLE sogo_user_profile (
    c_uid VARCHAR(255) PRIMARY KEY,
    c_name VARCHAR(255),
    c_password VARCHAR(255),
    c_cn VARCHAR(255)
);
```

## **7. Security Implementation Plan**

### **7.1 Authentication Strategy**

1. **Password Storage:** SHA512-CRYPT in PostgreSQL
2. **Service Accounts:** Least privilege principle
3. **VPN Dependency:** All internal services VPN-only
4. **Fail2ban Rules:** VPN-aware blocking patterns

### **7.2 Certificate Management**

- **Public Facing:** Let's Encrypt wildcard certificates
- **Internal Services:** Self-signed or internal CA
- **Renewal Process:** Automated with post-hook service reloads
- **Monitoring:** Certificate expiration alerts via Wazuh

## **8. Backup & Recovery Strategy**

### **8.1 Backup Schedule**

```
Daily (2:00 AM):
  - PostgreSQL base backup + incremental WAL
  - Configuration files archive
  - New/changed mail data

Weekly (Friday 2:00 AM):
  - Full PostgreSQL dump
  - Complete configuration state
  - Full mail data snapshot

Monthly (Last Friday):
  - Archive to long-term storage
  - Verification and integrity checks
```

### **8.2 Recovery Procedures**

1. **Database Recovery:** Point-in-time recovery from WAL archives
2. **Mailbox Recovery:** Maildir restoration from backups
3. **Configuration Recovery:** Git-based restoration
4. **Full System Recovery:** Step-by-step documented procedure

## **9. Monitoring & Alerting**

### **9.1 Wazuh Integration Points**

- **Postfix:** Queue length, rejected messages, authentication failures
- **Dovecot:** Failed logins, connection counts, disk usage
- **PostgreSQL:** Connection count, replication status, disk space
- **System:** CPU, memory, disk I/O, network traffic

### **9.2 Health Check Endpoints**

- `/health/smtp` - SMTP service availability
- `/health/imap` - IMAP service functionality
- `/health/database` - PostgreSQL connectivity
- `/health/webmail` - SOGo web interface

## **10. Success Validation Plan**

### **10.1 Technical Validation**

- [ ] All services start correctly after reboot
- [ ] Email delivery < 5 seconds 95th percentile
- [ ] IMAP login < 2 seconds 95th percentile
- [ ] Backup completes successfully
- [ ] Restore test completed within 30 minutes

### **10.2 Security Validation**

- [ ] No services accessible from public IP (except required)
- [ ] SPF, DKIM, DMARC properly configured
- [ ] Wazuh alerts configured and functional
- [ ] VPN-only access enforced for internal services

### **10.3 User Experience Validation**

- [ ] Thunderbird configuration works
- [ ] Outlook configuration works
- [ ] iOS/Android mobile access functional
- [ ] Calendar/Contacts sync working

## **11. Risk Mitigation**

### **11.1 Identified Risks**

1. **Single Point of Failure:** Single VPS during PoC
   - _Mitigation:_ Documented migration path to cluster
2. **Database Performance:** Containerized PostgreSQL I/O limits
   - _Mitigation:_ Performance monitoring, plan for dedicated server
3. **Email Deliverability:** Reputation issues with new IP
   - _Mitigation:_ Warm-up plan, monitoring deliverability rates

### **11.2 Rollback Strategy**

- **Stage 1:** Configuration backups before each major change
- **Stage 2:** Database snapshots before schema changes
- **Stage 3:** Documented rollback procedures for each component

## **12. Phase 2 Considerations**

### **12.1 Cluster Architecture Planning**

- **Database Layer:** PostgreSQL streaming replication (1 master, 2 replicas)
- **Application Layer:** 3-node load balanced Postfix/Dovecot
- **Storage Layer:** Distributed storage solution investigation
- **Load Balancing:** HAProxy with health checks

### **12.2 Migration Path**

1. PoC validation (30-day stability period)
2. Schema enhancement for clustering
3. Ansible playbook creation for automation
4. Staged domain-by-domain migration

## **13. Documentation Requirements**

### **13.1 Required Documentation**

- [ ] Component installation guides
- [ ] Configuration reference manual
- [ ] Troubleshooting guide
- [ ] Backup/restore procedures
- [ ] Security hardening guide
- [ ] Monitoring setup guide

### **13.2 Maintenance Runbooks**

- Daily health checks
- Weekly maintenance tasks
- Monthly security updates
- Quarterly disaster recovery drills

---

## **Next Actions**

### **Immediate Next Steps (Week 1):**

1. [ ] Set up Vultr VPS with Debian 13
2. [ ] Configure WireGuard VPN integration
3. [ ] Install and harden base system
4. [ ] Deploy PostgreSQL container with initial schema
5. [ ] Begin Postfix configuration

### **Decision Log**

| Date | Decision                            | Rationale                                                          |
| ---- | ----------------------------------- | ------------------------------------------------------------------ |
| TBD  | Use Docker for PostgreSQL only      | Simplifies deployment while maintaining control over mail services |
| TBD  | Manual deployment before automation | Ensures understanding of architecture for future Ansible setup     |
| TBD  | VPN-only for all internal services  | Maximum security isolation from public internet                    |

---

**Document Version:** 1.0  
**Last Updated:** 2025-12-15  
**Next Review:** Start of implementation  
**Related Documents:**

- `Mail_Server_POC_PRD.md` - Requirements
- `tasks.md` - Task tracking
- `assistant_rules.md` - Project guidelines
