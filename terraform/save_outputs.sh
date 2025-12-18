#!/bin/bash

# Script to save Terraform outputs to a file for HashiCorp Vault
# Usage: ./save_outputs.sh [output_filename]

OUTPUT_FILE="${1:-vultr_instance_secrets.json}"

echo "Saving Terraform outputs to ${OUTPUT_FILE}..."

# Get the vault_secret_json output
terraform output -raw vault_secret_json > "$OUTPUT_FILE"

if [ $? -eq 0 ]; then
    echo "✓ Outputs saved successfully to: ${OUTPUT_FILE}"
    echo ""
    echo "To upload to HashiCorp Vault, use:"
    echo "  vault kv put secret/vultr/instances/\$(jq -r '.instance_id' ${OUTPUT_FILE}) @${OUTPUT_FILE}"
    echo ""
    echo "Or manually:"
    echo "  vault kv put secret/vultr/instances/<instance-name> \\"
    echo "    instance_id=\$(jq -r '.instance_id' ${OUTPUT_FILE}) \\"
    echo "    main_ip=\$(jq -r '.main_ip' ${OUTPUT_FILE}) \\"
    echo "    default_password=\$(jq -r '.default_password' ${OUTPUT_FILE})"
else
    echo "✗ Failed to save outputs"
    exit 1
fi

# Display non-sensitive information
echo ""
echo "Instance Information:"
echo "-------------------"
jq -r 'to_entries | map(select(.key != "default_password")) | from_entries' "$OUTPUT_FILE"
