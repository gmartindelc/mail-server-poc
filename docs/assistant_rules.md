# Assistant Rules — Mail Server Cluster PoC

Purpose
- Define project-wide rules and conventions. This file must not contain task status, session summaries, or delivery notes.

Documentation & Logging Standards
- Tasks tracker (docs/tasks.md): Only milestones, task groups, and tasks with status/progress and minimal metadata (estimate, dependencies, automation). No narrative summaries.
- Session summaries: Store every working session as a separate file under docs/sessions/ using the exact pattern session_yyyy_mm_dd.md (e.g., session_2026_01_12.md). Do not include session summaries in this file or in docs/tasks.md.
- Readmes and guides: Keep technical documentation, quick references, and operational guides separate from tasks and session logs.

Security & Access Principles
- VPN-only administration and data-plane access. WireGuard mandatory; SSH restricted to VPN interface only.
- UFW default-deny inbound. Public services allowed: 25 (SMTP), 587 (Submission), 80/443 (HTTP/HTTPS). VPN-only services: 993 (IMAPS), 5432 (PostgreSQL), 2288 (SSH) for 10.100.0.0/24.
- Secrets must never be committed to the repository. Use example templates and environment files; actual credentials are written on-target with restrictive permissions.

Database Canonical Schema (Authoritative)
- Tables: domain, mailbox, alias (Dovecot 2.4 compatible)
  - domain(domain PK, description, aliases, mailboxes, maxquota, quota, transport, backupmx, active, created, modified)
  - mailbox(username PK, password, name, maildir, quota, local_part, domain FK→domain(domain) ON DELETE CASCADE, active, created, modified)
  - alias(address PK, goto, domain FK→domain(domain) ON DELETE CASCADE, active, created, modified)
- Indexes: idx_mailbox_domain, idx_mailbox_active, idx_alias_domain, idx_alias_active, idx_domain_active.
- Service users and permissions:
  - postfix: SELECT on domain, mailbox, alias
  - dovecot: SELECT on mailbox
  - sogo: SELECT/INSERT/UPDATE/DELETE on domain, mailbox, alias
- Any templates, playbooks, or docs must reflect this schema (no virtual_* tables).

PostgreSQL Container Policy
- Image: postgres:17-alpine; container name: mailserver-postgres.
- Bind to VPN interface/IP only (e.g., 10.100.0.25:5432). No public exposure.
- Volumes/paths: /opt/postgres/data, /opt/postgres/wal_archive, /opt/postgres/backups.
- UID/GID alignment: host postgres user UID 999 must match container for volume access.
- Backups: daily full dump + WAL archiving; 7-day retention; verification scripts present and executable.

Ansible Conventions
- Playbooks: Wrapper tasks named task_X.Y.Z.yml or task_X_Y_Z.yml include reusable playbooks with actual logic. Place templates under ansible/playbooks/templates/.
- Idempotency: All playbooks must be idempotent. Use include_tasks/import_tasks appropriately. Avoid forcing changes unless strictly required.
- No hardcoded secrets: Generate credentials at runtime and store on-target with restrictive permissions.
- Verification: Each significant task must perform non-destructive verification steps and produce clear output.

Configuration & Files (on target)
- PostgreSQL per-service connection env files: /opt/mail_server/postgres/connection_strings/*.env
- Admin credentials: /root/postgres_service_users.txt and /opt/mail_server/postgres/.env (0600/0640 as applicable)
- Management and backup scripts live under /opt/mail_server/postgres/scripts/ and must be executable.

Change Control
- When changing schema- or security-affecting components, update:
  - Ansible playbooks
  - Templates
  - Documentation (quick references/readmes)
  - Verification/diagnostic playbooks
- Keep commit messages concise and reference the affected task IDs when applicable.

Prohibited Content in This File
- Task completion details, session narratives, infra state dumps, or delivery summaries. Those belong in docs/sessions/ (per-session files) or the relevant documentation files.
