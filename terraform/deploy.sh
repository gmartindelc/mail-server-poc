#!/bin/bash
# terraform/deploy.sh - Minimal version

echo "=== Mail Server PoC - Deployment ==="

# Check prerequisites
[ -f "main.tf" ] || { echo "Error: Run from terraform directory"; exit 1; }
[ -f "terraform.tfvars" ] || { echo "Error: terraform.tfvars not found"; exit 1; }
[ -f "../.env" ] || { echo "Error: ../.env not found"; exit 1; }

# Load .env
source ../.env

# Show configuration
echo ""
echo "Configuration:"
echo "--------------"
cat terraform.tfvars
echo ""
echo "Using credentials from .env"
echo ""

# Confirm
read -p "Deploy instance? (yes/no): " confirm
[ "$confirm" = "yes" ] || { echo "Cancelled"; exit 0; }

# Deploy
echo ""
echo "Deploying..."
terraform apply -auto-approve \
  -var-file="terraform.tfvars" \
  -var="vultr_api_key=$VULTR_API_KEY" \
  -var="ssh_public_key=$VULTR_SSH_PUBLIC_KEY"

echo ""
echo "✅ Deployment complete!"
echo "Check outputs with: terraform output"
