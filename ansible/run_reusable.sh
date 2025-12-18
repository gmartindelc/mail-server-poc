# ansible/run_reusable.sh
#!/bin/bash
# Script to run reusable Ansible playbooks with custom variables

set -e

PLAYBOOK_NAME=$1
PLAYBOOK_DIR="playbooks"
INVENTORY_FILE="inventory.yml"

# Check if playbook name is provided
if [ -z "$PLAYBOOK_NAME" ]; then
    echo "Usage: $0 <playbook_name> [ansible_options]"
    echo "Example: $0 create_admin_user.yml -e 'admin_username=myadmin'"
    echo ""
    echo "Available reusable playbooks:"
    ls ${PLAYBOOK_DIR}/*.yml 2>/dev/null | grep -v "^${PLAYBOOK_DIR}/task_" | sed 's/.*\///' | sort || echo "No reusable playbooks found"
    exit 1
fi

PLAYBOOK="${PLAYBOOK_DIR}/${PLAYBOOK_NAME}"

if [ ! -f "${PLAYBOOK}" ]; then
    echo "Error: Playbook not found: ${PLAYBOOK}"
    echo "Available playbooks:"
    ls ${PLAYBOOK_DIR}/*.yml 2>/dev/null | sed 's/.*\///' | sort || echo "No playbooks found"
    exit 1
fi

echo "Running reusable playbook: ${PLAYBOOK_NAME}"
echo "Target server from: ../cucho1.phalkons.com.secret"

# Extract IP from credentials file for display
if [ -f "../cucho1.phalkons.com.secret" ]; then
    SERVER_IP=$(cut -d',' -f1 "../cucho1.phalkons.com.secret")
    echo "Server IP: ${SERVER_IP}"
fi

# Run the playbook
ansible-playbook -i "${INVENTORY_FILE}" "${PLAYBOOK}" "${@:2}"
