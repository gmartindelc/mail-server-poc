#!/bin/bash
# ansible/run_all_tasks_1.4.sh
# 
# Sequential execution of all Task Group 1.4 playbooks
# 
# This script runs all Directory Structure & Storage tasks in order:
# 1.4.1 - Create mail system directory structure
# 1.4.2 - Set proper permissions and ownership
# 1.4.3 - Configure disk quotas
#
# Prerequisites:
# - Task Group 1.3 (System Hardening) completed
# - VPN connection active to 10.100.0.25
# - SSH access on port 2288
# - Environment variables set for VPN access
#
# Usage: ./run_all_tasks_1.4.sh [ansible_options]
# Example: ./run_all_tasks_1.4.sh -v
# Example: ./run_all_tasks_1.4.sh --check (dry-run - will fail on verification)

set -e  # Exit on any error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Tasks to run in order
TASKS=(
    "1.4.1"
    "1.4.2"
    "1.4.3"
)

TASK_NAMES=(
    "Create mail system directory structure"
    "Set proper permissions and ownership"
    "Configure disk quotas for /var/mail/vmail/"
)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Mail Server PoC - Task Group 1.4${NC}"
echo -e "${BLUE}Directory Structure & Storage${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check environment variables
if [ -z "$ANSIBLE_HOST" ] || [ -z "$ANSIBLE_REMOTE_PORT" ] || [ -z "$ANSIBLE_REMOTE_USER" ] || [ -z "$ANSIBLE_PRIVATE_KEY_FILE" ]; then
    echo -e "${RED}ERROR: Required environment variables not set!${NC}"
    echo ""
    echo "After Task Group 1.3, SSH is VPN-only. Please set:"
    echo ""
    echo -e "${YELLOW}export ANSIBLE_HOST=10.100.0.25${NC}"
    echo -e "${YELLOW}export ANSIBLE_REMOTE_PORT=2288${NC}"
    echo -e "${YELLOW}export ANSIBLE_REMOTE_USER=phalkonadmin${NC}"
    echo -e "${YELLOW}export ANSIBLE_PRIVATE_KEY_FILE=~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common${NC}"
    echo ""
    exit 1
fi

# Display server information
echo -e "${GREEN}Target Server (VPN):${NC} $ANSIBLE_HOST"
echo -e "${GREEN}SSH Port:${NC} $ANSIBLE_REMOTE_PORT"
echo -e "${GREEN}SSH User:${NC} $ANSIBLE_REMOTE_USER"
echo -e "${GREEN}Total Tasks:${NC} ${#TASKS[@]}"
echo ""

# Test VPN connectivity
echo -e "${BLUE}Testing VPN connectivity...${NC}"
if ping -c 1 -W 2 $ANSIBLE_HOST >/dev/null 2>&1; then
    echo -e "${GREEN}✓ VPN connection active${NC}"
else
    echo -e "${RED}✗ Cannot reach $ANSIBLE_HOST${NC}"
    echo "Please verify VPN is active:"
    echo "  sudo systemctl status wg-quick@wg0"
    exit 1
fi
echo ""

# Test SSH connectivity
echo -e "${BLUE}Testing SSH connectivity...${NC}"
if ssh -p $ANSIBLE_REMOTE_PORT -o ConnectTimeout=5 -o StrictHostKeyChecking=no -o IdentitiesOnly=yes -i $ANSIBLE_PRIVATE_KEY_FILE $ANSIBLE_REMOTE_USER@$ANSIBLE_HOST "echo 'SSH OK'" >/dev/null 2>&1; then
    echo -e "${GREEN}✓ SSH connection successful${NC}"
else
    echo -e "${RED}✗ Cannot SSH to $ANSIBLE_REMOTE_USER@$ANSIBLE_HOST${NC}"
    echo "Please verify SSH access manually"
    exit 1
fi
echo ""

# Confirmation prompt (skip if --yes flag provided)
if [[ ! "$*" =~ "--yes" ]]; then
    echo -e "${YELLOW}This will configure:${NC}"
    echo "  ✓ Create mail directories (/var/mail/vmail, queue, backups)"
    echo "  ✓ Create PostgreSQL directories (/opt/postgres/data, wal_archive, backups)"
    echo "  ✓ Create vmail user (UID 5000)"
    echo "  ✓ Create postgres user (UID 999)"
    echo "  ✓ Set ownership and permissions"
    echo "  ✓ Configure disk quotas"
    echo ""
    read -p "Proceed with all tasks? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted."
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}Starting task execution...${NC}"
echo ""

# Track execution time
START_TIME=$(date +%s)
FAILED_TASKS=()

# Run each task
for i in "${!TASKS[@]}"; do
    TASK="${TASKS[$i]}"
    TASK_NAME="${TASK_NAMES[$i]}"
    TASK_NUM=$((i + 1))
    
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}Task ${TASK_NUM}/${#TASKS[@]}: ${TASK} - ${TASK_NAME}${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    TASK_START=$(date +%s)
    
    # Check if task file exists
    if [ ! -f "playbooks/task_${TASK}.yml" ]; then
        echo -e "${RED}ERROR: Task file playbooks/task_${TASK}.yml not found${NC}"
        echo "Task ${TASK} has not been created yet."
        echo ""
        FAILED_TASKS+=("$TASK - $TASK_NAME (not implemented)")
        
        # Ask if we should continue
        if [[ ! "$*" =~ "--continue-on-error" ]]; then
            read -p "Continue with remaining tasks? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Stopping execution."
                break
            fi
        fi
        continue
    fi
    
    # Run the task
    if ./run_task.sh "$TASK" "$@"; then
        TASK_END=$(date +%s)
        TASK_DURATION=$((TASK_END - TASK_START))
        echo ""
        echo -e "${GREEN}✓ Task ${TASK} completed successfully${NC} (${TASK_DURATION}s)"
        echo ""
    else
        TASK_END=$(date +%s)
        TASK_DURATION=$((TASK_END - TASK_START))
        echo ""
        echo -e "${RED}✗ Task ${TASK} failed${NC} (${TASK_DURATION}s)"
        echo ""
        FAILED_TASKS+=("$TASK - $TASK_NAME")
        
        # Ask if we should continue
        if [[ ! "$*" =~ "--continue-on-error" ]]; then
            read -p "Continue with remaining tasks? (y/N) " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                echo "Stopping execution."
                break
            fi
        fi
    fi
done

# Calculate total execution time
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
MINUTES=$((TOTAL_DURATION / 60))
SECONDS=$((TOTAL_DURATION % 60))

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Execution Summary${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}Total execution time:${NC} ${MINUTES}m ${SECONDS}s"
echo ""

# Display results
if [ ${#FAILED_TASKS[@]} -eq 0 ]; then
    echo -e "${GREEN}✓ All tasks completed successfully!${NC}"
    echo ""
    echo -e "${GREEN}Final System State:${NC}"
    echo "  ✓ Mail directories created and owned by vmail:vmail"
    echo "  ✓ PostgreSQL directories created and owned by postgres:postgres"
    echo "  ✓ Proper permissions configured (750/700)"
    echo "  ✓ Disk quotas configured for mail storage"
    echo ""
    echo -e "${GREEN}Directory Structure:${NC}"
    echo "  /var/mail/vmail/      - Virtual mail storage"
    echo "  /var/mail/queue/      - Mail queue"
    echo "  /var/mail/backups/    - Mail backups"
    echo "  /opt/postgres/data/   - PostgreSQL data"
    echo "  /opt/postgres/wal_archive/ - WAL archives"
    echo "  /opt/postgres/backups/     - DB backups"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "  1. Verify directory structure:"
    echo "     ssh -p $ANSIBLE_REMOTE_PORT -i $ANSIBLE_PRIVATE_KEY_FILE $ANSIBLE_REMOTE_USER@$ANSIBLE_HOST"
    echo "     sudo ls -la /var/mail/"
    echo "     sudo ls -la /opt/postgres/"
    echo ""
    echo "  2. Check user creation:"
    echo "     id vmail"
    echo "     id postgres"
    echo ""
    echo "  3. Proceed to Milestone 2 (Database Layer Implementation)"
    echo "     Task 2.1.1: Create PostgreSQL Docker Compose configuration"
    echo ""
    exit 0
else
    echo -e "${RED}✗ ${#FAILED_TASKS[@]} task(s) failed:${NC}"
    for task in "${FAILED_TASKS[@]}"; do
        echo -e "  ${RED}•${NC} $task"
    done
    echo ""
    echo -e "${YELLOW}Check the output above for error details.${NC}"
    echo ""
    exit 1
fi
