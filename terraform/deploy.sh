#!/bin/bash
# terraform/deploy.sh

echo "=== Mail Server PoC - Terraform Deployment ==="
echo ""

# Check if in correct directory
if [ ! -f "main.tf" ]; then
    echo "Error: Please run this script from the terraform directory"
    exit 1
fi

# Check for required files
if [ ! -f "terraform.tfvars" ]; then
    echo "Error: terraform.tfvars not found!"
    exit 1
fi

# Load credentials from .env
ENV_FILE="../.env"
if [ -f "$ENV_FILE" ]; then
    VULTR_API_KEY=$(grep ^VULTR_API_KEY= "$ENV_FILE" | cut -d= -f2- | tr -d '"'"'")
    VULTR_SSH_PUBLIC_KEY=$(grep ^VULTR_SSH_PUBLIC_KEY= "$ENV_FILE" | cut -d= -f2- | tr -d '"'"'")
else
    echo "Error: .env file not found!"
    exit 1
fi

# Validate credentials
if [ -z "$VULTR_API_KEY" ] || [ -z "$VULTR_SSH_PUBLIC_KEY" ]; then
    echo "Error: Missing credentials in .env file"
    exit 1
fi

echo "Deployment Configuration:"
echo "-------------------------"
echo "Server specs (from terraform.tfvars):"
cat terraform.tfvars
echo ""
echo "Credentials: [loaded from .env]"
echo ""

# Read server specs from terraform.tfvars for display
SERVER_PLAN=$(grep ^server_plan= terraform.tfvars | cut -d= -f2- | tr -d ' "')
HOSTNAME=$(grep ^hostname= terraform.tfvars | cut -d= -f2- | tr -d ' "')
REGION=$(grep ^region= terraform.tfvars | cut -d= -f2- | tr -d ' "')

echo "Creating instance:"
echo "  Plan: $SERVER_PLAN"
echo "  Hostname: $HOSTNAME"
echo "  Region: $REGION"
echo ""

read -p "Proceed with deployment? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    exit 0
fi

# Apply Terraform configuration
echo ""
echo "Applying Terraform configuration..."
terraform apply -auto-approve \
  -var-file="terraform.tfvars" \
  -var="vultr_api_key=$VULTR_API_KEY" \
  -var="ssh_public_key=$VULTR_SSH_PUBLIC_KEY"

echo ""
echo "=============================================================="
echo "✅  DEPLOYMENT COMPLETE"
echo "=============================================================="
echo ""
echo "Instance details saved to:"
echo "- ../instance_outputs.json"
echo "- ../connection_info.txt"
echo "- ../quick_reference.md"
echo ""
echo "To view outputs: terraform output"
echo ""
echo "=============================================================="
