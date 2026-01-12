# Task 2.1.1 - Deploy PostgreSQL Container

## Overview

This task deploys PostgreSQL 17 database in a Docker container with VPN-only access. This database serves as the centralized authentication and storage backend for all mail services (Postfix, Dovecot, SOGo).

## What This Task Does

### 1. Creates Project Structure
```
/opt/mail_server/postgres/
├── docker-compose.yml       # Container definition
├── .env                     # Credentials (gitignored)
├── .env.example            # Template
├── postgresql.conf         # PostgreSQL configuration
└── scripts/
    ├── manage.sh           # Container management
    ├── test_connection.sh  # Connection testing
    └── get_password.sh     # Password retrieval
```

### 2. Deploys PostgreSQL Container

**Container Configuration:**
- **Image:** postgres:17-alpine
- **Name:** mailserver-postgres
- **Network:** Host mode (binds to 10.100.0.25:5432)
- **User:** postgres (UID 999)
- **Restart Policy:** unless-stopped
- **Resources:** 2GB RAM limit, 1.5 CPU

**Volume Mounts:**
- `/opt/postgres/data` → `/var/lib/postgresql/data` (database files)
- `/opt/postgres/wal_archive` → `/var/lib/postgresql/wal_archive` (WAL files)

### 3. Configures Security

- ✅ VPN-only access (10.100.0.25)
- ✅ Strong random password (32 characters)
- ✅ UFW firewall rule (allow from 10.100.0.0/24 only)
- ✅ SCRAM-SHA-256 authentication
- ✅ Secure credential storage

### 4. Sets Up Management

- Container management scripts
- Connection testing utilities
- Password retrieval tools
- Health monitoring

## Prerequisites

- **Completed Tasks:**
  - Task 1.4.1 (Directories created)
  - Task 1.4.2 (postgres user with UID 999)
  - Task 1.2.6 (Docker installed)
- **Access:** VPN connection, SSH as phalkonadmin
- **Environment Variables Set:**
  ```bash
  export ANSIBLE_HOST=10.100.0.25
  export ANSIBLE_REMOTE_PORT=2288
  export ANSIBLE_REMOTE_USER=phalkonadmin
  export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common
  ```

## Files Included

1. **task_2.1.1.yml** - Task wrapper playbook
2. **deploy_postgresql_container.yml** - PostgreSQL deployment playbook

## Usage

### Standard Execution

```bash
./run_task.sh 2.1.1
```

### Check Mode

```bash
# Check mode has limitations (can't pull images or start containers)
./run_task.sh 2.1.1 --check
```

**Note:** Check mode will show what would be created but won't actually deploy the container.

## Expected Output

```yaml
PLAY [Task 2.1.1 - Deploy PostgreSQL Container] ***************************

TASK [Create PostgreSQL project directory] ********************************
changed: [mail_server]

TASK [Generate secure PostgreSQL password] ********************************
ok: [mail_server]

TASK [Create .env file with database credentials] *************************
changed: [mail_server]

TASK [Create docker-compose.yml for PostgreSQL] ***************************
changed: [mail_server]

TASK [Pull PostgreSQL Docker image] ***************************************
changed: [mail_server]

TASK [Start PostgreSQL container] *****************************************
changed: [mail_server]

TASK [Wait for PostgreSQL to be healthy] **********************************
ok: [mail_server]

TASK [Test PostgreSQL connection from VPN IP] *****************************
ok: [mail_server]

TASK [Display task completion summary] ************************************
ok: [mail_server] => {
    "msg": [
        "==========================================",
        "Task 2.1.1 - PostgreSQL Container Deployed",
        "==========================================",
        "Container Status: ✅ Running and Healthy",
        ...
    ]
}

PLAY RECAP ****************************************************************
mail_server                : ok=25   changed=15   unreachable=0   failed=0
```

## Post-Execution Verification

### Verify Container is Running

```bash
ssh -p 2288 -o IdentitiesOnly=yes -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@10.100.0.25

# Check container status
docker ps | grep mailserver-postgres
# Should show: Up X minutes (healthy)

# Check health status
docker inspect mailserver-postgres --format='{{.State.Health.Status}}'
# Should show: healthy

# View container logs
docker logs mailserver-postgres --tail 50
```

### Test Database Connection

```bash
# Using the test script (recommended)
sudo /opt/mail_server/postgres/scripts/test_connection.sh

# Manual test from container
docker exec mailserver-postgres psql -h 10.100.0.25 -U postgres -d mailserver -c "SELECT version();"

# Expected output:
# PostgreSQL 17.x on x86_64-pc-linux-musl, compiled by gcc...
```

### Verify VPN-Only Access

```bash
# From VPN (should work)
docker exec mailserver-postgres psql -h 10.100.0.25 -U postgres -d mailserver -c "SELECT 1;"
# Should return: 1

# From public IP (should fail/timeout)
# This test can't be done from the server itself, but when you try to connect
# from outside the VPN, it should fail
```

### Get Database Credentials

```bash
# Retrieve password securely
sudo /opt/mail_server/postgres/scripts/get_password.sh

# Or view credentials file
sudo cat /root/postgres_credentials.txt
```

## Managing the Container

### Container Management

```bash
# Start container
sudo /opt/mail_server/postgres/scripts/manage.sh start

# Stop container
sudo /opt/mail_server/postgres/scripts/manage.sh stop

# Restart container
sudo /opt/mail_server/postgres/scripts/manage.sh restart

# View status
sudo /opt/mail_server/postgres/scripts/manage.sh status

# View logs (follows)
sudo /opt/mail_server/postgres/scripts/manage.sh logs
```

### Direct Docker Commands

```bash
# View logs
docker logs mailserver-postgres

# Follow logs
docker logs -f mailserver-postgres

# Execute SQL command
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT current_database();"

# Interactive psql session
docker exec -it mailserver-postgres psql -U postgres -d mailserver

# Restart container
docker restart mailserver-postgres

# Stop container
docker stop mailserver-postgres

# Start container
docker start mailserver-postgres
```

### Database Connection

```bash
# Connection string format:
postgresql://postgres:<password>@10.100.0.25:5432/mailserver

# Get connection details
sudo /opt/mail_server/postgres/scripts/get_password.sh
```

## State Transition

### Before Task 2.1.1
```
PostgreSQL: ❌ Not installed
Container: ❌ Doesn't exist
Database: ❌ Not accessible
Credentials: ❌ Not generated
```

### After Task 2.1.1
```
PostgreSQL: ✅ Version 17-alpine running
Container: ✅ mailserver-postgres (healthy)
Database: ✅ mailserver (accessible via VPN)
Credentials: ✅ Generated and stored securely
Network: ✅ Bound to 10.100.0.25:5432
Firewall: ✅ VPN-only access configured
Volumes: ✅ Persistent storage mounted
```

## Network Configuration

### VPN-Only Binding

The PostgreSQL container binds to the VPN IP only:

```
Listen Address: 10.100.0.25
Port: 5432
Access: 10.100.0.0/24 (VPN network only)
```

**UFW Firewall Rule:**
```bash
sudo ufw status | grep 5432
# Output: 5432/tcp ALLOW 10.100.0.0/24  # PostgreSQL - VPN access only
```

**Why This Is Secure:**
1. Database not accessible from public IP (45.32.207.84)
2. Only VPN clients can connect
3. Requires authentication even from VPN
4. UFW enforces network-level access control

### Testing Access Control

```bash
# From VPN (should work)
psql -h 10.100.0.25 -U postgres -d mailserver
# ✅ Should connect

# From public IP (if you could test it)
psql -h 45.32.207.84 -U postgres -d mailserver
# ❌ Should timeout or connection refused
```

## File Permissions and Ownership

### Created Files and Directories

```bash
/opt/mail_server/postgres/       # root:root, 0755
├── docker-compose.yml           # root:root, 0644
├── .env                         # root:root, 0600 (sensitive!)
├── .env.example                 # root:root, 0644
├── postgresql.conf              # postgres:postgres, 0644
└── scripts/                     # root:root, 0755
    ├── manage.sh                # root:root, 0755
    ├── test_connection.sh       # root:root, 0755
    └── get_password.sh          # root:root, 0700 (sensitive!)

/root/postgres_credentials.txt   # root:root, 0600 (backup)
```

### Volume Mount Ownership

```bash
/opt/postgres/data/              # postgres:postgres, 0700
/opt/postgres/wal_archive/       # postgres:postgres, 0750
```

The container runs as UID 999 (postgres), which matches the host postgres user created in Task 1.4.2.

## Container Configuration Details

### docker-compose.yml Highlights

```yaml
services:
  postgres:
    image: postgres:17-alpine
    container_name: mailserver-postgres
    user: "999:999"                    # Matches host postgres user
    network_mode: host                 # For VPN IP binding
    env_file: .env                     # Credentials
    
    volumes:
      - /opt/postgres/data:/var/lib/postgresql/data
      - /opt/postgres/wal_archive:/var/lib/postgresql/wal_archive
    
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -h 10.100.0.25 -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    
    deploy:
      resources:
        limits:
          cpus: '1.5'
          memory: 2G
```

### PostgreSQL Configuration

Key settings in `postgresql.conf`:
- `listen_addresses = '10.100.0.25'` - VPN IP only
- `max_connections = 100` - Sufficient for mail services
- `shared_buffers = 256MB` - Memory for caching
- `wal_level = replica` - Prepared for replication
- Authentication: SCRAM-SHA-256 (secure)

## Integration Points

### With Previous Tasks

**Task 1.4.1 (Directories):**
- Uses `/opt/postgres/data` for database
- Uses `/opt/postgres/wal_archive` for WAL files

**Task 1.4.2 (Permissions):**
- Requires postgres user with UID 999
- Container runs as this user for file access

**Task 1.3.4 (VPN-Only):**
- Database accessible only via VPN
- Consistent with SSH VPN-only security

### With Future Tasks

**Task 2.1.2 (Database Schema):**
- Will create mail-related tables
- Will create service users (postfix, dovecot, sogo)
- Will populate initial data

**Task 2.1.3 (Backups):**
- Will configure WAL archiving
- Will set up automated backups
- Will create backup scripts

**Task 3.x (Mail Services):**
- Postfix will query for virtual users/domains
- Dovecot will authenticate users
- SOGo will store calendars/contacts

## Troubleshooting

### Issue: Container won't start

**Symptom:**
```
docker ps shows nothing or container is restarting
```

**Solution:**
```bash
# Check logs
docker logs mailserver-postgres

# Common issues:
# 1. Port already in use
sudo lsof -i :5432

# 2. Permission issues with volumes
ls -ld /opt/postgres/data
# Should be: postgres:postgres (UID 999)

# 3. Invalid configuration
docker logs mailserver-postgres | grep -i error
```

### Issue: Container unhealthy

**Symptom:**
```
docker inspect shows Health: unhealthy
```

**Solution:**
```bash
# Check health check command
docker exec mailserver-postgres pg_isready -h 10.100.0.25 -U postgres

# Check PostgreSQL logs
docker logs mailserver-postgres

# Restart container
docker restart mailserver-postgres
```

### Issue: Can't connect to database

**Symptom:**
```
psql: could not connect to server
```

**Solution:**
```bash
# 1. Verify container is running
docker ps | grep mailserver-postgres

# 2. Check if listening on VPN IP
docker exec mailserver-postgres ss -tlnp | grep 5432
# Should show: 10.100.0.25:5432

# 3. Test from container
docker exec mailserver-postgres psql -h 10.100.0.25 -U postgres -d mailserver -c "SELECT 1;"

# 4. Check firewall
sudo ufw status | grep 5432

# 5. Verify VPN connection
ping 10.100.0.25
```

### Issue: Permission denied on volumes

**Symptom:**
```
initdb: could not change permissions of directory
```

**Solution:**
```bash
# Verify ownership
ls -ldn /opt/postgres/data
# Should show: 999 999 (postgres UID)

# Fix if needed
sudo chown -R 999:999 /opt/postgres/data
sudo chmod 700 /opt/postgres/data
```

### Issue: Lost database password

**Solution:**
```bash
# Retrieve from secure scripts
sudo /opt/mail_server/postgres/scripts/get_password.sh

# Or from .env file
sudo cat /opt/mail_server/postgres/.env | grep POSTGRES_PASSWORD

# Or from backup
sudo cat /root/postgres_credentials.txt
```

## Security Considerations

### Password Management

- **Generated:** 32-character random password
- **Stored:** `/opt/mail_server/postgres/.env` (0600 permissions)
- **Backed up:** `/root/postgres_credentials.txt` (0600 permissions)
- **Retrieval:** Only via root or get_password.sh script

### Network Security

- **VPN-Only:** Bound to 10.100.0.25 (not 0.0.0.0)
- **Firewall:** UFW allows only from 10.100.0.0/24
- **Authentication:** SCRAM-SHA-256 (strongest method)
- **No Public Access:** Cannot connect from internet

### Container Security

- **Non-Root:** Runs as postgres user (UID 999)
- **Resource Limits:** CPU and memory capped
- **Logging:** All activity logged
- **Health Checks:** Automatic monitoring

## Performance Considerations

### Resource Allocation

- **RAM:** 2GB limit (reasonable for ~100 users)
- **CPU:** 1.5 CPU limit
- **Storage:** 80GB SSD (shared with mail)

### Monitoring

```bash
# Container resource usage
docker stats mailserver-postgres

# Database connections
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT count(*) FROM pg_stat_activity;"

# Database size
docker exec mailserver-postgres psql -U postgres -d mailserver -c "SELECT pg_size_pretty(pg_database_size('mailserver'));"
```

## Backup Considerations

Currently, the container uses:
- Persistent volumes (data survives container restarts)
- WAL archive directory (prepared for Task 2.1.3)

**Task 2.1.3** will implement:
- Automated daily backups
- WAL archiving for point-in-time recovery
- Backup retention policies

## Next Steps

After completing Task 2.1.1, proceed to:

**Task 2.1.2: Configure PostgreSQL for mail server authentication**
- Create database schema
- Create tables (virtual_domains, virtual_users, virtual_aliases)
- Create service users (postfix, dovecot, sogo)
- Set up appropriate permissions
- Insert test data

## References

- **Planning Document:** Section 2.4 (Database Layer)
- **Tasks Document:** Task 2.1.1 specification
- **PostgreSQL Docs:** https://www.postgresql.org/docs/17/
- **Docker Compose Docs:** https://docs.docker.com/compose/

---

**Task Status:** ✅ Ready for Execution  
**Risk Level:** Medium (first live service deployment)  
**Reversible:** Yes (docker compose down)  
**Check Mode:** Limited (shows files, can't deploy container)
