#!/bin/bash
# terraform/init.sh - Minimal version

echo "=== Mail Server PoC - Terraform Initialization ==="

# Check prerequisites
[ -f "main.tf" ] || { echo "Error: Run from terraform directory"; exit 1; }
[ -f "terraform.tfvars" ] || { echo "Error: terraform.tfvars not found"; exit 1; }
[ -f "../.env" ] || { echo "Error: ../.env not found"; exit 1; }

# Load .env
source ../.env

# Validate
[ -n "$VULTR_API_KEY" ] || { echo "Error: VULTR_API_KEY not set"; exit 1; }
[ -n "$VULTR_SSH_PUBLIC_KEY" ] || { echo "Error: VULTR_SSH_PUBLIC_KEY not set"; exit 1; }

echo "✓ Files and credentials validated"

# Initialize
terraform init
terraform validate

echo ""
echo "✓ Initialization complete"
echo "Run: ./deploy.sh to deploy the instance"
