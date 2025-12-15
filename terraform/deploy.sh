#!/bin/bash
# terraform/deploy.sh

echo "=== Mail Server PoC - Terraform Deployment ==="
echo ""

# Check if in correct directory
if [ ! -f "main.tf" ]; then
    echo "Error: Please run this script from the terraform directory"
    exit 1
fi

# Check if initialized
if [ ! -d ".terraform" ]; then
    echo "Error: Terraform not initialized. Run ./init.sh first."
    exit 1
fi

# Create plan
echo "Creating deployment plan..."
terraform plan -out=tfplan

echo ""
read -p "Do you want to apply this plan? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    echo "You can review the plan with: terraform show tfplan"
    exit 0
fi

# Apply the plan
echo ""
echo "Applying Terraform configuration..."
terraform apply tfplan

# Clean up plan file
rm -f tfplan

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "Important: Check your email for the root password from Vultr!"
echo ""
echo "Files created:"
echo "- ../instance_outputs.json (machine-readable)"
echo "- ../connection_info.txt (human-readable)"
echo ""
echo "Next steps:"
echo "1. Check email for Vultr welcome message with root password"
echo "2. SSH into server: ssh root@[IP_ADDRESS]"
echo "3. Change root password immediately"
echo "4. Proceed with Ansible configuration"
echo ""
echo "To destroy the infrastructure:"
echo "terraform destroy"