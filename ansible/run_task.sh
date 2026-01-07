#!/bin/bash
# ansible/run_task.sh
# Script to run specific Ansible tasks

set -e

TASK_NUMBER=$1
PLAYBOOK_DIR="playbooks"
INVENTORY_FILE="inventory.yml"
CREDENTIAL_FILE="../cucho1.phalkons.com.secret"

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

# Check if credential file exists
if [ ! -f "${CREDENTIAL_FILE}" ]; then
    echo "Error: Credential file not found: ${CREDENTIAL_FILE}"
    echo "Please deploy VPS first:"
    echo "  cd ../terraform"
    echo "  ./deploy.sh"
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
echo "Target server from: ${CREDENTIAL_FILE}"

# Extract credentials and export as environment variables
export MAIL_SERVER_IP=$(head -n 1 "${CREDENTIAL_FILE}" | cut -d',' -f1)
export MAIL_SERVER_PASS=$(head -n 1 "${CREDENTIAL_FILE}" | cut -d',' -f2)

# Set default SSH port if not already set (supports Task 1.3.1+ on port 2288)
if [ -z "$ANSIBLE_SSH_PORT" ]; then
    export ANSIBLE_SSH_PORT=22
fi

echo "Server IP: ${MAIL_SERVER_IP}"
echo "SSH Port: ${ANSIBLE_SSH_PORT}"

# Run the playbook with environment variables set
ansible-playbook -i "${INVENTORY_FILE}" "${PLAYBOOK}" "${@:2}"
