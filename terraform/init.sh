#!/bin/bash
# terraform/init.sh

echo "=== Mail Server PoC - Terraform Initialization ==="
echo ""

# Check if in correct directory
if [ ! -f "main.tf" ]; then
    echo "Error: Please run this script from the terraform directory"
    exit 1
fi

# Load environment variables from project root
if [ -f "../.env" ]; then
    echo "Loading environment variables from ../.env"
    source ../.env
elif [ -f ".env" ]; then
    echo "Loading environment variables from .env"
    source .env
else
    echo "Warning: No .env file found. Please create one."
fi

# Check if terraform.tfvars exists, if not create from .env
if [ ! -f "terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from environment variables..."
    
    if [ -z "$VULTR_API_KEY" ] || [ -z "$VULTR_SSH_PUBLIC_KEY" ]; then
        echo "Error: VULTR_API_KEY and VULTR_SSH_PUBLIC_KEY must be set in .env file"
        echo ""
        echo "Example .env file:"
        echo "VULTR_API_KEY=\"your_api_key\""
        echo "VULTR_SSH_PUBLIC_KEY=\"ssh-rsa AAAAB3...\""
        exit 1
    fi
    
    cat > terraform.tfvars << EOF
vultr_api_key = "${VULTR_API_KEY}"
ssh_public_key = "${VULTR_SSH_PUBLIC_KEY}"
EOF
    echo "Created terraform.tfvars"
else
    echo "Using existing terraform.tfvars"
fi

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

# Validate configuration
echo ""
echo "Validating Terraform configuration..."
terraform validate

echo ""
echo "=== Initialization Complete ==="
echo ""
echo "Next steps:"
echo "1. Review the configuration:"
echo "   cat terraform.tfvars"
echo "   cat variables.tf"
echo ""
echo "2. Plan the deployment:"
echo "   terraform plan"
echo ""
echo "3. Apply the configuration:"
echo "   terraform apply"
echo ""
echo "Or run ./deploy.sh for automated deployment"