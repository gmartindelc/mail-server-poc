#!/bin/bash
# ansible/run_all_tasks.sh
# 
# Sequential execution of all Task Group 1.2 playbooks
# 
# This script runs all System User Administration tasks in order:
# 1.2.1 - Configure passwordless sudo
# 1.2.2 - Remove linuxuser
# 1.2.3 - Create phalkonadmin user
# 1.2.4 - Configure SSH key authentication
# 1.2.5 - Test SSH connection
# 1.2.6 - Install Docker Compose
# 1.2.7 - Post-configuration cleanup (NEW)
#
# Usage: ./run_all_tasks.sh [ansible_options]
# Example: ./run_all_tasks.sh -v
# Example: ./run_all_tasks.sh --check (dry-run)

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
    "1.2.1"
    "1.2.2"
    "1.2.3"
    "1.2.4"
    "1.2.5"
    "1.2.6"
    "1.2.7"
)

TASK_NAMES=(
    "Configure passwordless sudo"
    "Remove linuxuser"
    "Create phalkonadmin user (UID 1000)"
    "Configure SSH key authentication (disable root)"
    "Test SSH connection and verify config"
    "Install Docker Compose"
    "Post-configuration cleanup and verification"
)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Mail Server PoC - Task Group 1.2${NC}"
echo -e "${BLUE}System User Administration${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if credential file exists
if [ ! -f "../cucho1.phalkons.com.secret" ]; then
    echo -e "${RED}ERROR: Credential file not found!${NC}"
    echo "Expected location: ../cucho1.phalkons.com.secret"
    echo ""
    echo "Please ensure VPS is deployed first:"
    echo "  cd ../terraform"
    echo "  ./deploy.sh"
    exit 1
fi

# Display server information
export MAIL_SERVER_IP=$(head -n 1 ../cucho1.phalkons.com.secret | cut -d',' -f1)
export MAIL_SERVER_PASS=$(head -n 1 ../cucho1.phalkons.com.secret | cut -d',' -f2)
SERVER_IP=$MAIL_SERVER_IP  # For display purposes
echo -e "${GREEN}Target Server:${NC} $SERVER_IP"
echo -e "${GREEN}Total Tasks:${NC} ${#TASKS[@]}"
echo ""

# Confirmation prompt (skip if --yes flag provided)
if [[ ! "$*" =~ "--yes" ]]; then
    echo -e "${YELLOW}IMPORTANT: This will configure:${NC}"
    echo "  ✓ Disable root SSH access"
    echo "  ✓ Disable password authentication"
    echo "  ✓ Set phalkonadmin UID to 1000"
    echo "  ✓ Configure passwordless sudo for sudo group"
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
    
    # Create task_1.2.7.yml if it doesn't exist
    if [ "$TASK" = "1.2.7" ] && [ ! -f "playbooks/task_1.2.7.yml" ]; then
        echo -e "${BLUE}Creating task_1.2.7.yml...${NC}"
        cat > "playbooks/task_1.2.7.yml" << 'EOF'
---
# Task 1.2.7 - Post-configuration cleanup and verification
#
# This task should be run after all previous tasks to:
# 1. Fix UID assignment if needed
# 2. Clean up main sudoers file
# 3. Verify complete configuration
# 4. Remove any leftover artifacts
#
# Dependencies: Task 1.2.6 (Docker installation)
# Execution: ./run_task.sh 1.2.7

- name: Task 1.2.7 - Post-configuration cleanup and verification
  hosts: mail_server
  gather_facts: false
  
  tasks:
    - name: Import UID fix playbook
      import_playbook: fix_user_uid.yml
      vars:
        fix_username: "phalkonadmin"
        fix_uid: 1000
    
    - name: Import sudoers cleanup playbook
      import_playbook: cleanup_main_sudoers.yml
    
    - name: Final verification check
      ansible.builtin.command:
        cmd: |
          echo "=== System Verification ==="
          id phalkonadmin
          echo "--- Sudoers check ---"
          grep -r "NOPASSWD" /etc/sudoers*
          echo "--- SSH config check ---"
          grep -E "^(PermitRootLogin|PasswordAuthentication)" /etc/ssh/sshd_config
          echo "--- Docker group check ---"
          groups phalkonadmin
      register: final_check
      changed_when: false
    
    - name: Display final status
      ansible.builtin.debug:
        msg:
          - "=========================================="
          - "Task Group 1.2 - COMPLETE VERIFICATION"
          - "=========================================="
          - "System User Administration tasks completed."
          - ""
          - "Expected state:"
          - "√ phalkonadmin uid=1000"
          - "√ %sudo ALL=(ALL:ALL) NOPASSWD: ALL (in /etc/sudoers.d/)"
          - "√ PermitRootLogin no"
          - "√ PasswordAuthentication no"
          - "√ phalkonadmin in sudo,docker groups"
          - "√ Root SSH access disabled"
          - "√ Password auth disabled"
          - "√ Only phalkonadmin can SSH with common worker key"
          - "=========================================="
EOF
        echo -e "${GREEN}Created task_1.2.7.yml${NC}"
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
    echo "  ✓ phalkonadmin has UID 1000"
    echo "  ✓ Passwordless sudo configured for sudo group"
    echo "  ✓ Root SSH access disabled"
    echo "  ✓ Password authentication disabled"
    echo "  ✓ Only phalkonadmin can SSH with common worker key"
    echo ""
    echo -e "${GREEN}Next steps:${NC}"
    echo "  1. Reconnect as phalkonadmin:"
    echo "     ssh -i ~/SSH_KEYS_CAPITAN_TO_WORKERS/id_ed25519_common phalkonadmin@$SERVER_IP"
    echo ""
    echo "  2. Verify Docker installation:"
    echo "     docker --version"
    echo "     docker compose version"
    echo ""
    echo "  3. Test root SSH (should fail):"
    echo "     ssh -i ~/.ssh/id_ed25519_lc02_vultr root@$SERVER_IP"
    echo ""
    echo "  4. Proceed to Task Group 1.3 (System Hardening)"
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
