#!/bin/bash
# terraform/init.sh

echo "=== Mail Server PoC - Terraform Initialization ==="
echo ""

# Check if in correct directory
if [ ! -f "main.tf" ]; then
    echo "Error: Please run this script from the terraform directory"
    exit 1
fi

# Check for required files
if [ ! -f "terraform.tfvars" ]; then
    echo "Error: terraform.tfvars not found!"
    echo "Please create terraform.tfvars with server configuration:"
    echo "  server_plan, hostname, region, os_name, label, tags"
    exit 1
fi

if [ ! -f "../.env" ] && [ ! -f ".env" ]; then
    echo "Error: .env file not found in project root!"
    echo "Please create .env file with:"
    echo "  VULTR_API_KEY"
    echo "  VULTR_SSH_PUBLIC_KEY"
    exit 1
fi

# Load sensitive credentials from .env
ENV_FILE="../.env"
if [ -f "$ENV_FILE" ]; then
    echo "Loading credentials from $ENV_FILE"
    
    # Extract values safely
    VULTR_API_KEY=$(grep ^VULTR_API_KEY= "$ENV_FILE" | cut -d= -f2- | tr -d '"'"'")
    VULTR_SSH_PUBLIC_KEY=$(grep ^VULTR_SSH_PUBLIC_KEY= "$ENV_FILE" | cut -d= -f2- | tr -d '"'"'")
    
    # Validate
    if [ -z "$VULTR_API_KEY" ]; then
        echo "Error: VULTR_API_KEY not found in .env"
        exit 1
    fi
    
    if [ -z "$VULTR_SSH_PUBLIC_KEY" ]; then
        echo "Error: VULTR_SSH_PUBLIC_KEY not found in .env"
        exit 1
    fi
    
    echo "✓ Credentials loaded successfully"
else
    echo "Error: .env file not found at $ENV_FILE"
    exit 1
fi

echo ""
echo "Configuration Summary:"
echo "----------------------"
echo "From terraform.tfvars:"
grep -v "^#" terraform.tfvars | grep -v "^$"
echo ""
echo "From .env:"
echo "  VULTR_API_KEY: [set]"
echo "  VULTR_SSH_PUBLIC_KEY: [set]"
echo ""

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Validate configuration
echo ""
echo "Validating Terraform configuration..."
terraform validate

echo ""
echo "=== Initialization Complete ==="
echo ""
echo "To deploy with this configuration, run:"
echo "terraform apply -var=\"vultr_api_key=$VULTR_API_KEY\" -var=\"ssh_public_key=$VULTR_SSH_PUBLIC_KEY\""
echo ""
echo "Or use: ./deploy.sh"
