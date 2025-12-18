#!/bin/bash

# Simple Terraform Output Saver
# Saves all terraform outputs to a text file for easy viewing
# Usage: ./save_outputs_simple.sh [filename]

OUTPUT_FILE="${1:-outputs.txt}"

echo "Saving all Terraform outputs to ${OUTPUT_FILE}..."
echo ""

# Create header
cat > "$OUTPUT_FILE" << 'EOF'
================================================================================
                           TERRAFORM OUTPUTS
================================================================================
EOF

echo "Generated: $(date)" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get ALL outputs using terraform output (formatted)
echo "=== ALL OUTPUTS (Formatted) ===" >> "$OUTPUT_FILE"
terraform output >> "$OUTPUT_FILE" 2>&1

echo "" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Get individual outputs (raw values)
echo "=== INDIVIDUAL VALUES (Raw) ===" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# List of common outputs to try
OUTPUTS=(
    "instance_id"
    "instance_label"
    "main_ip"
    "region"
    "os"
    "status"
    "vcpu_count"
    "ram"
    "disk"
    "default_password"
)

for output in "${OUTPUTS[@]}"; do
    if terraform output "$output" &> /dev/null; then
        VALUE=$(terraform output -raw "$output" 2>/dev/null)
        echo "${output}: ${VALUE}" >> "$OUTPUT_FILE"
    fi
done

echo "" >> "$OUTPUT_FILE"
echo "=== JSON FORMAT ===" >> "$OUTPUT_FILE"
if terraform output -json &> /dev/null; then
    terraform output -json >> "$OUTPUT_FILE" 2>&1
fi

echo "" >> "$OUTPUT_FILE"
echo "=================================================================================" >> "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "✅ Success! Outputs saved to: ${OUTPUT_FILE}"
    echo ""
    echo "To view the file:"
    echo "  cat ${OUTPUT_FILE}"
    echo ""
    echo "To view specific value:"
    echo "  grep 'main_ip' ${OUTPUT_FILE}"
    echo ""
    
    # Show main IP if available
    if terraform output main_ip &> /dev/null; then
        MAIN_IP=$(terraform output -raw main_ip 2>/dev/null)
        echo "🌐 Main IP Address: ${MAIN_IP}"
        echo "🔐 SSH Command: ssh root@${MAIN_IP}"
        echo ""
    fi
    
    echo "⚠️  This file contains sensitive information (password)"
    echo "   Keep it secure and delete after use!"
else
    echo "❌ Failed to save outputs"
    exit 1
fi
