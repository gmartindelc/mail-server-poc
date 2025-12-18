#!/bin/bash

# Test Script to Save Terraform Outputs
# This script saves all Terraform outputs to a readable text file for testing
# Usage: ./test_save_outputs.sh [output_filename]

OUTPUT_FILE="${1:-terraform_outputs_test.txt}"
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

echo "=========================================="
echo "Terraform Outputs Test Script"
echo "=========================================="
echo ""

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    echo "❌ Error: Terraform is not installed or not in PATH"
    exit 1
fi

# Check if terraform is initialized
if [ ! -d ".terraform" ]; then
    echo "❌ Error: Terraform not initialized. Run 'terraform init' first."
    exit 1
fi

# Check if state file exists
if [ ! -f "terraform.tfstate" ]; then
    echo "⚠️  Warning: No terraform.tfstate file found."
    echo "   You need to run 'terraform apply' first to create resources."
    exit 1
fi

echo "📝 Saving Terraform outputs to: ${OUTPUT_FILE}"
echo ""

# Create the output file with header
cat > "$OUTPUT_FILE" << EOF
================================================================================
                        TERRAFORM OUTPUTS - TEST FILE
================================================================================
Generated: ${TIMESTAMP}
Project: Vultr VPS Instance
================================================================================

EOF

# Save all outputs in a readable format
echo "INSTANCE INFORMATION" >> "$OUTPUT_FILE"
echo "-------------------" >> "$OUTPUT_FILE"

# Instance ID
if terraform output instance_id &> /dev/null; then
    echo "Instance ID       : $(terraform output -raw instance_id 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

# Instance Label
if terraform output instance_label &> /dev/null; then
    echo "Instance Label    : $(terraform output -raw instance_label 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

# Main IP
if terraform output main_ip &> /dev/null; then
    echo "Main IP Address   : $(terraform output -raw main_ip 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

# Region
if terraform output region &> /dev/null; then
    echo "Region            : $(terraform output -raw region 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

# OS
if terraform output os &> /dev/null; then
    echo "Operating System  : $(terraform output -raw os 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

# Status
if terraform output status &> /dev/null; then
    echo "Status            : $(terraform output -raw status 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "HARDWARE SPECIFICATIONS" >> "$OUTPUT_FILE"
echo "----------------------" >> "$OUTPUT_FILE"

# vCPU Count
if terraform output vcpu_count &> /dev/null; then
    echo "vCPU Count        : $(terraform output -raw vcpu_count 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

# RAM
if terraform output ram &> /dev/null; then
    echo "RAM (MB)          : $(terraform output -raw ram 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

# Disk
if terraform output disk &> /dev/null; then
    echo "Disk (GB)         : $(terraform output -raw disk 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "CREDENTIALS (SENSITIVE)" >> "$OUTPUT_FILE"
echo "----------------------" >> "$OUTPUT_FILE"

# Default Password (marked as sensitive)
if terraform output default_password &> /dev/null; then
    echo "Default Password  : $(terraform output -raw default_password 2>/dev/null || echo 'N/A')" >> "$OUTPUT_FILE"
    echo "⚠️  KEEP THIS FILE SECURE - Contains sensitive credentials!" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "SSH CONNECTION" >> "$OUTPUT_FILE"
echo "--------------" >> "$OUTPUT_FILE"

if terraform output main_ip &> /dev/null; then
    MAIN_IP=$(terraform output -raw main_ip 2>/dev/null)
    echo "SSH Command       : ssh root@${MAIN_IP}" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "JSON OUTPUT (for scripts/automation)" >> "$OUTPUT_FILE"
echo "------------------------------------" >> "$OUTPUT_FILE"

# Try to get vault_secret_json if it exists
if terraform output vault_secret_json &> /dev/null; then
    terraform output -raw vault_secret_json 2>/dev/null >> "$OUTPUT_FILE"
else
    echo "{" >> "$OUTPUT_FILE"
    echo "  \"instance_id\": \"$(terraform output -raw instance_id 2>/dev/null || echo 'N/A')\"," >> "$OUTPUT_FILE"
    echo "  \"main_ip\": \"$(terraform output -raw main_ip 2>/dev/null || echo 'N/A')\"," >> "$OUTPUT_FILE"
    echo "  \"default_password\": \"$(terraform output -raw default_password 2>/dev/null || echo 'N/A')\"," >> "$OUTPUT_FILE"
    echo "  \"hostname\": \"$(terraform output -raw instance_label 2>/dev/null || echo 'N/A')\"" >> "$OUTPUT_FILE"
    echo "}" >> "$OUTPUT_FILE"
fi

echo "" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"
echo "End of Terraform Outputs" >> "$OUTPUT_FILE"
echo "================================================================================" >> "$OUTPUT_FILE"

# Success message
echo "✅ Outputs saved successfully to: ${OUTPUT_FILE}"
echo ""
echo "📋 Summary:"
echo "   File location: $(pwd)/${OUTPUT_FILE}"
echo "   File size: $(du -h "${OUTPUT_FILE}" | cut -f1)"
echo ""

# Display non-sensitive information to console
echo "📊 Instance Information (non-sensitive):"
echo "   Instance ID: $(terraform output -raw instance_id 2>/dev/null || echo 'N/A')"
echo "   Label: $(terraform output -raw instance_label 2>/dev/null || echo 'N/A')"
echo "   IP Address: $(terraform output -raw main_ip 2>/dev/null || echo 'N/A')"
echo "   Region: $(terraform output -raw region 2>/dev/null || echo 'N/A')"
echo "   Status: $(terraform output -raw status 2>/dev/null || echo 'N/A')"
echo ""

# Check if main_ip exists for SSH command
if terraform output main_ip &> /dev/null; then
    MAIN_IP=$(terraform output -raw main_ip 2>/dev/null)
    echo "🔐 SSH Connection:"
    echo "   ssh root@${MAIN_IP}"
    echo ""
fi

echo "⚠️  IMPORTANT: This file contains sensitive credentials!"
echo "   • Do not commit to version control"
echo "   • Store securely"
echo "   • Delete after use or upload to vault"
echo ""
echo "💾 To view the full output:"
echo "   cat ${OUTPUT_FILE}"
echo ""
echo "🗑️  To delete the file:"
echo "   rm ${OUTPUT_FILE}"
echo ""

exit 0
