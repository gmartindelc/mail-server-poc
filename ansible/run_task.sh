# ansible/run_task.sh
#!/bin/bash
# Script to run specific Ansible tasks

set -e

TASK_NUMBER=$1
PLAYBOOK_DIR="playbooks"
INVENTORY_FILE="inventory.yml"

# Check if task number is provided
if [ -z "$TASK_NUMBER" ]; then
    echo "Usage: $0 <task_number>"
    echo "Example: $0 1.2.1"
    echo "Available tasks:"
    ls ${PLAYBOOK_DIR}/task_*.yml 2>/dev/null | sed 's/.*task_\(.*\)\.yml/\1/' | sort || echo "No task playbooks found"
    echo ""
    echo "Available reusable playbooks:"
    ls ${PLAYBOOK_DIR}/*.yml 2>/dev/null | grep -v "^${PLAYBOOK_DIR}/task_" | sed 's/.*\///' | sort || echo "No reusable playbooks found"
    exit 1
fi

# Find the playbook
PLAYBOOK="${PLAYBOOK_DIR}/task_${TASK_NUMBER}.yml"

if [ ! -f "${PLAYBOOK}" ]; then
    echo "Error: Playbook for task ${TASK_NUMBER} not found: ${PLAYBOOK}"
    echo "Available task playbooks:"
    ls ${PLAYBOOK_DIR}/task_*.yml 2>/dev/null | sed 's/.*\///' | sort || echo "No task playbooks found"
    exit 1
fi

echo "Running task ${TASK_NUMBER}: ${PLAYBOOK}"
echo "Target server from: ../cucho1.phalkons.com.secret"

# Extract IP from credentials file for display
if [ -f "../cucho1.phalkons.com.secret" ]; then
    SERVER_IP=$(cut -d',' -f1 "../cucho1.phalkons.com.secret")
    echo "Server IP: ${SERVER_IP}"
fi

# Run the playbook
ansible-playbook -i "${INVENTORY_FILE}" "${PLAYBOOK}" "${@:2}"
