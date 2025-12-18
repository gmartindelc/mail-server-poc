#!/bin/bash

# Script to extract Terraform outputs and save credentials
# Creates a .secret file with format: ip,password
# Usage: ./save_credentials.sh

set -e

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

echo "=================================================="
echo "  Extracting Terraform Credentials"
echo "=================================================="
echo ""

# Check if terraform state exists
if [ ! -f "terraform.tfstate" ]; then
    print_error "No terraform.tfstate file found"
    print_info "Run 'terraform apply' first to create resources"
    exit 1
fi

# Extract outputs
print_info "Extracting outputs from Terraform state..."

HOSTNAME=$(terraform output -raw instance_label 2>/dev/null)
MAIN_IP=$(terraform output -raw main_ip 2>/dev/null)
PASSWORD=$(terraform output -raw default_password 2>/dev/null)

# Validate extracted data
if [ -z "$HOSTNAME" ]; then
    print_error "Failed to extract hostname"
    exit 1
fi

if [ -z "$MAIN_IP" ]; then
    print_error "Failed to extract IP address"
    exit 1
fi

if [ -z "$PASSWORD" ]; then
    print_error "Failed to extract password"
    exit 1
fi

# Create filename (hostname.secret)
SECRET_FILE="../${HOSTNAME}.secret"

# Create the secret file in parent directory
print_info "Creating credentials file: ${SECRET_FILE}"

# Write credentials in format: ip,password
echo "${MAIN_IP},${PASSWORD}" > "$SECRET_FILE"

# Set restrictive permissions (only owner can read/write)
chmod 600 "$SECRET_FILE"

print_success "Credentials saved successfully!"
echo ""
echo "=================================================="
echo "  Summary"
echo "=================================================="
echo "File created : ${SECRET_FILE}"
echo "Format       : ip,password"
echo "Permissions  : 600 (owner read/write only)"
echo ""
echo "=================================================="
echo ""

print_warning "SECURITY REMINDER:"
echo "  • This file contains sensitive credentials"
echo "  • Keep it secure and do not commit to version control"
echo "  • Delete after use or store in a secure location"
echo ""

print_success "To connect to your server, use the credentials from the file"
echo ""

exit 0
