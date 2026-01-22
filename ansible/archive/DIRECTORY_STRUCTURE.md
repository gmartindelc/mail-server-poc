# Task 1.4.1 - Directory Structure Diagram

## Overview

This document provides a visual representation of the directory structure created by Task 1.4.1.

## Before Task 1.4.1

```
/
├── var/
│   └── (standard system directories)
└── opt/
    └── (standard system directories)
```

## After Task 1.4.1

```
/
├── var/
│   ├── ... (other system directories)
│   └── mail/                           ← NEW
│       ├── vmail/                      ← NEW (Mail storage)
│       │   └── (empty - ready for mailboxes)
│       ├── queue/                      ← NEW (Mail queue)
│       │   └── (empty - ready for Postfix)
│       └── backups/                    ← NEW (Backup storage)
│           └── (empty - ready for backups)
└── opt/
    ├── ... (other system directories)
    └── postgres/                       ← NEW
        ├── data/                       ← NEW (DB volume mount)
        │   └── (empty - ready for PostgreSQL)
        ├── wal_archive/                ← NEW (WAL archives)
        │   └── (empty - ready for WAL files)
        └── backups/                    ← NEW (DB backups)
            └── (empty - ready for pg_dump)
```

## After Task 1.4.2 (Preview)

```
/
├── var/
│   └── mail/                           
│       ├── vmail/                      [vmail:vmail, 0750]
│       │   └── (ready for domain directories)
│       ├── queue/                      [vmail:vmail, 0750]
│       │   └── (ready for Postfix queue)
│       └── backups/                    [vmail:vmail, 0750]
│           └── (ready for mail backups)
└── opt/
    └── postgres/                       
        ├── data/                       [postgres:postgres, 0700]
        │   └── (ready for DB initialization)
        ├── wal_archive/                [postgres:postgres, 0750]
        │   └── (ready for WAL archiving)
        └── backups/                    [postgres:postgres, 0750]
            └── (ready for pg_dump scripts)
```

## Directory Purpose Details

### Mail System Directories

#### `/var/mail/vmail/`
```
Purpose: Virtual mail storage in Maildir format
Used by: Dovecot (IMAP/POP3 server)
Structure (future):
/var/mail/vmail/
├── example.com/
│   ├── user1/
│   │   ├── cur/         # Current mail
│   │   ├── new/         # New mail
│   │   └── tmp/         # Temporary
│   └── user2/
│       ├── cur/
│       ├── new/
│       └── tmp/
└── another-domain.com/
    └── ... (similar structure)
```

#### `/var/mail/queue/`
```
Purpose: Postfix mail queue
Used by: Postfix (MTA)
Structure (future):
/var/mail/queue/
├── active/              # Messages being delivered
├── bounce/              # Bounce messages
├── corrupt/             # Corrupted messages
├── defer/               # Deferred messages
├── deferred/            # Deferred queue
├── flush/               # Fast flush queue
├── hold/                # Messages on hold
├── incoming/            # New messages
├── maildrop/            # Mail drop directory
└── pid/                 # Process ID files
```

#### `/var/mail/backups/`
```
Purpose: Local backups of mail data
Used by: Backup scripts
Structure (future):
/var/mail/backups/
├── daily/
│   ├── 2025-01-12_vmail.tar.gz
│   ├── 2025-01-13_vmail.tar.gz
│   └── ...
├── weekly/
│   ├── 2025-W02_vmail.tar.gz
│   └── ...
└── monthly/
    ├── 2025-01_vmail.tar.gz
    └── ...
```

### PostgreSQL Container Directories

#### `/opt/postgres/data/`
```
Purpose: PostgreSQL database files (Docker volume mount)
Used by: PostgreSQL container
Mount: /opt/postgres/data:/var/lib/postgresql/data
Structure (after initialization):
/opt/postgres/data/
├── base/                # Database files
├── global/              # Cluster-wide tables
├── pg_wal/              # Write-Ahead Log
├── pg_xact/             # Transaction commit status
├── postgresql.conf      # Main configuration
├── pg_hba.conf          # Host-based authentication
└── ... (other PostgreSQL files)
```

#### `/opt/postgres/wal_archive/`
```
Purpose: Write-Ahead Log archives for point-in-time recovery
Used by: PostgreSQL archiving process
Structure (future):
/opt/postgres/wal_archive/
├── 000000010000000000000001
├── 000000010000000000000002
├── 000000010000000000000003
└── ... (WAL segment files)
```

#### `/opt/postgres/backups/`
```
Purpose: PostgreSQL database dumps and backup scripts
Used by: Backup scripts (pg_dump)
Structure (future):
/opt/postgres/backups/
├── scripts/
│   ├── backup_daily.sh
│   ├── backup_weekly.sh
│   └── restore.sh
├── daily/
│   ├── 2025-01-12_maildb.sql.gz
│   ├── 2025-01-13_maildb.sql.gz
│   └── ...
├── weekly/
│   ├── 2025-W02_maildb.sql.gz
│   └── ...
└── monthly/
    ├── 2025-01_maildb.sql.gz
    └── ...
```

## Permissions Summary

### Current State (After Task 1.4.1)
```
Directory                     Owner        Group      Permissions
─────────────────────────────────────────────────────────────────
/var/mail/vmail              root         root       drwxr-xr-x (755)
/var/mail/queue              root         root       drwxr-xr-x (755)
/var/mail/backups            root         root       drwxr-xr-x (755)
/opt/postgres/data           root         root       drwxr-xr-x (755)
/opt/postgres/wal_archive    root         root       drwxr-xr-x (755)
/opt/postgres/backups        root         root       drwxr-xr-x (755)
```

### Target State (After Task 1.4.2)
```
Directory                     Owner        Group      Permissions
─────────────────────────────────────────────────────────────────
/var/mail/vmail              vmail        vmail      drwxr-x--- (750)
/var/mail/queue              vmail        vmail      drwxr-x--- (750)
/var/mail/backups            vmail        vmail      drwxr-x--- (750)
/opt/postgres/data           postgres     postgres   drwx------ (700)
/opt/postgres/wal_archive    postgres     postgres   drwxr-x--- (750)
/opt/postgres/backups        postgres     postgres   drwxr-x--- (750)
```

## User/Group Mapping

### System Users (Created in Task 1.4.2)

```
User: vmail
├── UID: 5000
├── GID: 5000
├── Purpose: Virtual mail storage owner
├── Home: /var/mail/vmail
├── Shell: /usr/sbin/nologin
└── Owns: /var/mail/* directories

User: postgres
├── UID: 999 (standard PostgreSQL container UID)
├── GID: 999
├── Purpose: PostgreSQL container file access
├── Home: /opt/postgres
├── Shell: /usr/sbin/nologin
└── Owns: /opt/postgres/* directories
```

## Disk Space Considerations

### Initial Sizes
```
$ du -sh /var/mail/* /opt/postgres/*
4.0K    /var/mail/vmail
4.0K    /var/mail/queue
4.0K    /var/mail/backups
4.0K    /opt/postgres/data
4.0K    /opt/postgres/wal_archive
4.0K    /opt/postgres/backups
```

### Expected Growth (Rough Estimates)

For a server with 100 users, 1GB quota each:

```
/var/mail/vmail/         → Up to 100GB (user mailboxes)
/var/mail/queue/         → 10-100MB (temporary queue)
/var/mail/backups/       → 20-50GB (compressed backups)
/opt/postgres/data/      → 500MB-2GB (database)
/opt/postgres/wal_archive/ → 5-10GB (WAL archives)
/opt/postgres/backups/   → 500MB-1GB (DB dumps)
```

## Integration with Docker Compose

### PostgreSQL Container Configuration (Preview - Task 2.1.1)

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:17-alpine
    container_name: mailserver-postgres
    restart: unless-stopped
    volumes:
      - /opt/postgres/data:/var/lib/postgresql/data        ← Volume mount
      - /opt/postgres/wal_archive:/var/lib/postgresql/wal_archive  ← Volume mount
    network_mode: host
    environment:
      POSTGRES_DB: mailserver
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
```

The directories created in this task will be mounted directly into the PostgreSQL container.

## Security Notes

1. **Root Ownership (Current):**
   - All directories initially owned by root
   - Prevents unauthorized access before users created
   - Safe default state

2. **Service Users (Task 1.4.2):**
   - vmail user: Isolates mail storage
   - postgres user: Matches container UID for volume access
   - Both non-login users for security

3. **Permissions (Task 1.4.2):**
   - 750 for most directories (owner + group read/execute)
   - 700 for postgres data (owner only - security requirement)
   - Follows principle of least privilege

## Verification Commands

```bash
# Check directory existence
for dir in /var/mail/vmail /var/mail/queue /var/mail/backups \
           /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups; do
    [ -d "$dir" ] && echo "✓ $dir" || echo "✗ $dir MISSING"
done

# Check current permissions
ls -ld /var/mail/vmail /var/mail/queue /var/mail/backups
ls -ld /opt/postgres/data /opt/postgres/wal_archive /opt/postgres/backups

# Check disk usage
du -sh /var/mail /opt/postgres
df -h /var /opt
```

---

**Document Version:** 1.0  
**Created:** 2025-01-12  
**Task:** 1.4.1 - Create Mail System Directory Structure  
**Status:** Completed ✅
