#!/bin/bash
# setup_wg_credentials.sh
# 
# Extract WireGuard credentials from wg0.conf and create secure credential files
# This script ensures secrets are never committed to git
#
# Usage: ./setup_wg_credentials.sh [path/to/wg0.conf]
# Example: ./setup_wg_credentials.sh wg0.conf

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WG_CONF_FILE="${1:-wg0.conf}"
CRED_DIR="../wg_credentials"
GITIGNORE_FILE="../.gitignore"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}WireGuard Credentials Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check if wg0.conf exists
if [ ! -f "$WG_CONF_FILE" ]; then
    echo -e "${RED}ERROR: WireGuard config file not found: $WG_CONF_FILE${NC}"
    echo ""
    echo "Usage: $0 [path/to/wg0.conf]"
    echo "Example: $0 wg0.conf"
    echo "Example: $0 ../wg0.conf"
    exit 1
fi

echo -e "${GREEN}✓ Found WireGuard config: $WG_CONF_FILE${NC}"
echo ""

# Extract values from wg0.conf
echo -e "${BLUE}Extracting credentials from $WG_CONF_FILE...${NC}"

PRIVATE_KEY=$(grep -E "^PrivateKey\s*=" "$WG_CONF_FILE" | sed -E 's/^PrivateKey\s*=\s*//' | tr -d ' \r\n')
ADDRESS=$(grep -E "^Address\s*=" "$WG_CONF_FILE" | sed -E 's/^Address\s*=\s*//' | tr -d ' \r\n')
PUBLIC_KEY=$(grep -E "^PublicKey\s*=" "$WG_CONF_FILE" | sed -E 's/^PublicKey\s*=\s*//' | tr -d ' \r\n')
ENDPOINT=$(grep -E "^Endpoint\s*=" "$WG_CONF_FILE" | sed -E 's/^Endpoint\s*=\s*//' | tr -d ' \r\n')
ALLOWED_IPS=$(grep -E "^AllowedIPs\s*=" "$WG_CONF_FILE" | sed -E 's/^AllowedIPs\s*=\s*//' | tr -d ' \r\n')
KEEPALIVE=$(grep -E "^PersistentKeepalive\s*=" "$WG_CONF_FILE" | sed -E 's/^PersistentKeepalive\s*=\s*//' | tr -d ' \r\n')

# Validate extracted values
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}ERROR: Could not extract PrivateKey from $WG_CONF_FILE${NC}"
    exit 1
fi

if [ -z "$ADDRESS" ]; then
    echo -e "${RED}ERROR: Could not extract Address from $WG_CONF_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Private Key: ${PRIVATE_KEY:0:10}...${PRIVATE_KEY: -10}${NC}"
echo -e "${GREEN}✓ Address: $ADDRESS${NC}"
echo -e "${GREEN}✓ Peer Public Key: ${PUBLIC_KEY:0:10}...${PUBLIC_KEY: -10}${NC}"
echo -e "${GREEN}✓ Endpoint: $ENDPOINT${NC}"
echo -e "${GREEN}✓ Allowed IPs: $ALLOWED_IPS${NC}"
echo -e "${GREEN}✓ Keepalive: ${KEEPALIVE}s${NC}"
echo ""

# Create credentials directory
echo -e "${BLUE}Creating credentials directory...${NC}"

if [ -d "$CRED_DIR" ]; then
    echo -e "${YELLOW}⚠ Directory already exists: $CRED_DIR${NC}"
    read -p "Overwrite existing credentials? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}Aborted.${NC}"
        exit 0
    fi
else
    mkdir -p "$CRED_DIR"
    echo -e "${GREEN}✓ Created: $CRED_DIR${NC}"
fi

# Set secure permissions on directory
chmod 700 "$CRED_DIR"
echo -e "${GREEN}✓ Set permissions: 700 (rwx------) on $CRED_DIR${NC}"
echo ""

# Create credential files
echo -e "${BLUE}Creating credential files...${NC}"

# Private Key
echo -n "$PRIVATE_KEY" > "$CRED_DIR/private_key"
chmod 600 "$CRED_DIR/private_key"
echo -e "${GREEN}✓ Created: $CRED_DIR/private_key (600)${NC}"

# Address
echo -n "$ADDRESS" > "$CRED_DIR/address"
chmod 600 "$CRED_DIR/address"
echo -e "${GREEN}✓ Created: $CRED_DIR/address (600)${NC}"

# Peer Public Key
echo -n "$PUBLIC_KEY" > "$CRED_DIR/peer_public_key"
chmod 600 "$CRED_DIR/peer_public_key"
echo -e "${GREEN}✓ Created: $CRED_DIR/peer_public_key (600)${NC}"

# Endpoint
echo -n "$ENDPOINT" > "$CRED_DIR/endpoint"
chmod 600 "$CRED_DIR/endpoint"
echo -e "${GREEN}✓ Created: $CRED_DIR/endpoint (600)${NC}"

# Create a README in credentials directory
cat > "$CRED_DIR/README.md" << 'EOF'
# WireGuard Credentials

**⚠️ SECURITY WARNING: Never commit these files to git!**

This directory contains sensitive WireGuard VPN credentials extracted from wg0.conf.

## Files:
- `private_key` - WireGuard private key
- `address` - VPN IP address (e.g., 10.100.0.19/24)
- `peer_public_key` - Peer's public key
- `endpoint` - Peer's endpoint (IP:port)

## Permissions:
- Directory: 700 (rwx------)
- Files: 600 (rw-------)

## Usage:
These files are automatically read by Ansible playbooks.

## Regeneration:
To regenerate these credentials from wg0.conf:
```bash
cd ansible
./setup_wg_credentials.sh path/to/wg0.conf
```

## Security:
These files are protected by .gitignore and should never be committed to version control.
EOF

chmod 600 "$CRED_DIR/README.md"
echo -e "${GREEN}✓ Created: $CRED_DIR/README.md (600)${NC}"
echo ""

# Update .gitignore
echo -e "${BLUE}Updating .gitignore...${NC}"

# Create .gitignore if it doesn't exist
if [ ! -f "$GITIGNORE_FILE" ]; then
    touch "$GITIGNORE_FILE"
    echo -e "${GREEN}✓ Created: $GITIGNORE_FILE${NC}"
fi

# Check and add entries to .gitignore
GITIGNORE_ENTRIES=(
    "# WireGuard Configuration and Credentials"
    "wg0.conf"
    "wg_credentials/"
    ""
    "# Ansible Credentials"
    "*.secret"
    ""
    "# Ansible Runtime Files"
    "*.retry"
    "retry/"
    "ansible.log"
    ""
    "# Ansible Facts Cache"
    "/tmp/ansible_facts/"
    ""
    "# Backup Files"
    "*.backup.*"
)

UPDATED=false
for entry in "${GITIGNORE_ENTRIES[@]}"; do
    # Skip empty lines and comments for checking
    if [ -z "$entry" ] || [[ "$entry" =~ ^#.* ]]; then
        if ! grep -qF "$entry" "$GITIGNORE_FILE" 2>/dev/null; then
            echo "$entry" >> "$GITIGNORE_FILE"
        fi
        continue
    fi
    
    # Check if entry exists (exact match)
    if ! grep -qF "$entry" "$GITIGNORE_FILE" 2>/dev/null; then
        echo "$entry" >> "$GITIGNORE_FILE"
        echo -e "${GREEN}✓ Added to .gitignore: $entry${NC}"
        UPDATED=true
    fi
done

if [ "$UPDATED" = false ]; then
    echo -e "${GREEN}✓ .gitignore already up to date${NC}"
fi

echo ""

# Display summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Credentials stored in: $CRED_DIR${NC}"
echo -e "${GREEN}Protected by: $GITIGNORE_FILE${NC}"
echo ""
echo -e "${YELLOW}SECURITY REMINDERS:${NC}"
echo -e "  ${YELLOW}✓${NC} Credentials directory: 700 (rwx------)"
echo -e "  ${YELLOW}✓${NC} Credential files: 600 (rw-------)"
echo -e "  ${YELLOW}✓${NC} Files added to .gitignore"
echo -e "  ${YELLOW}✓${NC} Original wg0.conf protected"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Run Task 1.3.2: ${GREEN}./run_task.sh 1.3.2${NC}"
echo -e "  2. Verify .gitignore: ${GREEN}git status${NC}"
echo -e "  3. ${RED}NEVER commit wg0.conf or wg_credentials/${NC}"
echo ""
echo -e "${GREEN}✓ Safe to run Ansible playbooks!${NC}"
echo ""
