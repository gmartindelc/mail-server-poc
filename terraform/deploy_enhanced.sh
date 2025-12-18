#!/bin/bash
# terraform/deploy.sh - Enhanced version with credential extraction

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_header() {
    echo ""
    echo "=================================================="
    echo "  $1"
    echo "=================================================="
}

# Main deployment
print_header "Mail Server PoC - Deployment"

# Check prerequisites
print_info "Checking prerequisites..."

if [ ! -f "main.tf" ]; then
    print_error "main.tf not found"
    print_info "Please run this script from the terraform directory"
    exit 1
fi

if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars not found"
    print_info "Copy terraform.tfvars.example and configure it"
    exit 1
fi

if [ ! -f "../.env" ]; then
    print_error "../.env not found"
    print_info "Copy .env.example and configure it"
    exit 1
fi

print_success "All prerequisites found"

# Load environment variables
print_info "Loading environment variables from .env..."
source ../.env

if [ -z "$TF_VAR_vultr_api_key" ]; then
    print_error "TF_VAR_vultr_api_key not set in .env"
    exit 1
fi

print_success "Environment variables loaded"

# Show configuration
print_header "Configuration Review"
cat terraform.tfvars
echo ""
print_info "API key loaded from .env (hidden)"

# Confirmation
echo ""
print_warning "This will create resources on Vultr and incur charges"
read -p "Deploy instance? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    print_info "Deployment cancelled"
    exit 0
fi

# Terraform init (if needed)
if [ ! -d ".terraform" ]; then
    print_header "Initializing Terraform"
    terraform init
fi

# Deploy
print_header "Deploying Infrastructure"
echo ""

terraform apply -auto-approve \
  -var-file="terraform.tfvars" \
  -var="vultr_api_key=$TF_VAR_vultr_api_key"

DEPLOY_STATUS=${PIPESTATUS[0]}

if [ $DEPLOY_STATUS -ne 0 ]; then
    print_error "Deployment failed!"
    print_info "Check deploy.log for details"
    exit 1
fi

# Extract and save credentials
print_header "Extracting Credentials"

# Get outputs
HOSTNAME=$(terraform output -raw instance_label 2>/dev/null || echo "")
MAIN_IP=$(terraform output -raw main_ip 2>/dev/null || echo "")
PASSWORD=$(terraform output -raw default_password 2>/dev/null || echo "")

# Validate
if [ -z "$HOSTNAME" ] || [ -z "$MAIN_IP" ] || [ -z "$PASSWORD" ]; then
    print_error "Could not extract credentials from Terraform outputs"
    print_info "Run 'terraform output' to view them manually"
    exit 1
fi

# Create secret file in parent directory
SECRET_FILE="../${HOSTNAME}.secret"

print_info "Creating credentials file: ${SECRET_FILE}"
echo "${MAIN_IP},${PASSWORD}" > "$SECRET_FILE"
chmod 600 "$SECRET_FILE"

print_success "Credentials saved successfully!"

# Display summary
print_header "Deployment Summary"
echo ""
echo "Hostname       : ${HOSTNAME}"
echo "Credentials    : ${SECRET_FILE}"
echo "Format         : ip,password"
echo "Permissions    : 600 (secure)"
echo ""

print_success "Deployment Complete!"
echo ""

print_header "Next Steps"
echo ""
echo "1. View credentials file:"
echo "   cat ${SECRET_FILE}"
echo ""
echo "2. Connect to your server:"
echo "   ssh root@\$(cut -d',' -f1 ${SECRET_FILE})"
echo ""
echo "3. Change the root password immediately:"
echo "   passwd"
echo ""
echo "4. View all outputs:"
echo "   terraform output"
echo ""

print_warning "SECURITY REMINDERS:"
echo "  • Credentials are in ${HOSTNAME}.secret"
echo "  • Change the root password on first login"
echo "  • Do not commit .secret files to version control"
echo "  • Consider using SSH keys instead of password authentication"
echo ""

# Save deployment info
DEPLOY_INFO="../deployment_info.txt"
cat > "$DEPLOY_INFO" << EOF
================================================================================
                        DEPLOYMENT INFORMATION
================================================================================
Deployed: $(date)
Hostname: ${HOSTNAME}
Region: $(terraform output -raw region 2>/dev/null || echo "N/A")
OS: $(terraform output -raw os 2>/dev/null || echo "N/A")

Credentials File: ${SECRET_FILE}
Format: ip,password
Permissions: 600 (owner read/write only)

To connect:
1. View credentials: cat ${SECRET_FILE}
2. SSH: ssh root@\$(cut -d',' -f1 ${SECRET_FILE})

================================================================================
IMPORTANT: Change root password immediately after first login!
================================================================================
EOF

print_success "Deployment information saved to: ${DEPLOY_INFO}"
echo ""

exit 0
