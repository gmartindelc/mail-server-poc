#!/bin/bash
#
# Update Vultr Documentation from CSV Files
# This script reads vultr_*.csv files and updates the markdown documentation
#

set -e

# Configuration
SCRIPTS_DIR="${SCRIPTS_DIR:-./scripts}"
DOCS_DIR="${DOCS_DIR:-.}"
KEEP_CSV=false
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Colors
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

print_header() {
    echo -e "${BLUE}$1${NC}"
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Update Vultr documentation markdown files from CSV data.

OPTIONS:
    -k, --keep-csv          Keep CSV files after generating documentation
    -s, --scripts-dir DIR   Directory containing CSV files (default: ./scripts)
    -d, --docs-dir DIR      Directory for markdown files (default: .)
    -h, --help              Display this help message

EXAMPLES:
    # Standard usage (deletes CSV files)
    $0

    # Keep CSV files
    $0 --keep-csv

    # Custom directories
    $0 --scripts-dir ./data --docs-dir ./docs

EOF
    exit 0
}

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -k|--keep-csv)
            KEEP_CSV=true
            shift
            ;;
        -s|--scripts-dir)
            SCRIPTS_DIR="$2"
            shift 2
            ;;
        -d|--docs-dir)
            DOCS_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            print_error "Unknown option: $1"
            usage
            ;;
    esac
done


# Function to find latest CSV file
find_latest_csv() {
    local pattern=$1
    local latest_file=$(ls -t "${SCRIPTS_DIR}"/${pattern} 2>/dev/null | head -1)
    
    if [ -z "$latest_file" ]; then
        print_error "No CSV file found matching: ${pattern}"
        return 1
    fi
    
    echo "$latest_file"
}

# Function to count CSV rows
count_csv_rows() {
    local csv_file=$1
    local count=$(tail -n +2 "$csv_file" | wc -l | tr -d ' ')
    echo "$count"
}

# Function to generate plans markdown
generate_plans_markdown() {
    local csv_file=$1
    local output_file="${DOCS_DIR}/PLAN_IDS.md"
    
    print_info "Generating PLAN_IDS.md..."
    
    cat > "$output_file" << 'HEADER'
# Vultr Plan IDs (Resource Codes)

*Last updated: TIMESTAMP_PLACEHOLDER*

This document contains all available Vultr plan IDs and their specifications.

## Summary

- **Total Plans:** COUNT_PLACEHOLDER

## All Plans

| ID | Type | vCPUs | RAM (GB) | Disk (GB) | Bandwidth (GB) | Monthly Cost |
|---|---|---|---|---|---|---|
HEADER

    # Replace placeholders
    sed -i "s/TIMESTAMP_PLACEHOLDER/${TIMESTAMP}/" "$output_file"
    local count=$(count_csv_rows "$csv_file")
    sed -i "s/COUNT_PLACEHOLDER/${count}/" "$output_file"
    
    # Add table rows (skip header, convert RAM to GB)
    tail -n +2 "$csv_file" | while IFS=',' read -r id vcpu_count ram disk bandwidth monthly_cost type locations disk_count; do
        # Convert RAM from MB to GB
        ram_gb=$(echo "scale=1; $ram / 1024" | bc 2>/dev/null || echo "0")
        echo "| \`${id}\` | ${type} | ${vcpu_count} | ${ram_gb} | ${disk} | ${bandwidth} | \$${monthly_cost} |" >> "$output_file"
    done
    
    # Add usage section
    cat >> "$output_file" << 'FOOTER'

## Usage in Terraform

```hcl
resource "vultr_instance" "example" {
  plan    = "vc2-1c-1gb"  # Choose from the IDs above
  region  = "ewr"
  os_id   = 387
}
```

## Notes

- RAM is shown in GB (converted from MB)
- Bandwidth is monthly transfer limit
- Costs are in USD per month
- Use the plan ID exactly as shown in the `ID` column

For the most up-to-date information, visit: https://www.vultr.com/pricing/
FOOTER

    print_success "Created PLAN_IDS.md (${count} plans)"
}

# Function to generate regions markdown
generate_regions_markdown() {
    local csv_file=$1
    local output_file="${DOCS_DIR}/REGION_CODES.md"
    
    print_info "Generating REGION_CODES.md..."
    
    cat > "$output_file" << 'HEADER'
# Vultr Region Codes

*Last updated: TIMESTAMP_PLACEHOLDER*

This document contains all available Vultr region codes and locations.

## Summary

- **Total Regions:** COUNT_PLACEHOLDER

## All Regions

| Region Code | City | Country | Continent |
|---|---|---|---|
HEADER

    # Replace placeholders
    sed -i "s/TIMESTAMP_PLACEHOLDER/${TIMESTAMP}/" "$output_file"
    local count=$(count_csv_rows "$csv_file")
    sed -i "s/COUNT_PLACEHOLDER/${count}/" "$output_file"
    
    # Add table rows
    tail -n +2 "$csv_file" | while IFS=',' read -r id country city state continent options; do
        # Remove quotes if present
        city=$(echo "$city" | tr -d '"')
        country=$(echo "$country" | tr -d '"')
        continent=$(echo "$continent" | tr -d '"')
        echo "| \`${id}\` | ${city} | ${country} | ${continent} |" >> "$output_file"
    done
    
    # Add usage section
    cat >> "$output_file" << 'FOOTER'

## Usage in Terraform

```hcl
resource "vultr_instance" "example" {
  plan    = "vc2-1c-1gb"
  region  = "ewr"  # Choose from the codes above
  os_id   = 387
}
```

## Common Regions

### North America
- `ewr` - New Jersey (US East)
- `ord` - Chicago (US Central)
- `dfw` - Dallas (US Central)
- `sea` - Seattle (US West)
- `lax` - Los Angeles (US West)
- `atl` - Atlanta (US Southeast)
- `yto` - Toronto (Canada)

### Europe
- `ams` - Amsterdam (Netherlands)
- `lhr` - London (United Kingdom)
- `fra` - Frankfurt (Germany)
- `par` - Paris (France)

### Asia Pacific
- `sgp` - Singapore
- `nrt` - Tokyo (Japan)
- `syd` - Sydney (Australia)

For the complete list with features and options, see the table above.
FOOTER

    print_success "Created REGION_CODES.md (${count} regions)"
}

# Function to generate OS markdown
generate_os_markdown() {
    local csv_file=$1
    local output_file="${DOCS_DIR}/OS_IDS.md"
    
    print_info "Generating OS_IDS.md..."
    
    cat > "$output_file" << 'HEADER'
# Vultr Operating System IDs

*Last updated: TIMESTAMP_PLACEHOLDER*

This document contains all available Vultr operating system IDs.

## Summary

- **Total Operating Systems:** COUNT_PLACEHOLDER

## All Operating Systems

| OS ID | Name | Family | Architecture |
|---|---|---|---|
HEADER

    # Replace placeholders
    sed -i "s/TIMESTAMP_PLACEHOLDER/${TIMESTAMP}/" "$output_file"
    local count=$(count_csv_rows "$csv_file")
    sed -i "s/COUNT_PLACEHOLDER/${count}/" "$output_file"
    
    # Add table rows
    tail -n +2 "$csv_file" | while IFS=',' read -r id name arch family; do
        # Remove quotes and handle special characters
        name=$(echo "$name" | tr -d '"' | sed 's/&/\&amp;/g')
        family=$(echo "$family" | tr -d '"')
        arch=$(echo "$arch" | tr -d '"')
        echo "| \`${id}\` | ${name} | ${family} | ${arch} |" >> "$output_file"
    done
    
    # Add usage section
    cat >> "$output_file" << 'FOOTER'

## Usage in Terraform

```hcl
resource "vultr_instance" "example" {
  plan    = "vc2-1c-1gb"
  region  = "ewr"
  os_id   = 387  # Choose from the IDs above
}
```

## Popular Choices

| Operating System | ID | Use Case |
|---|---|---|
| Ubuntu 22.04 LTS | `387` | General purpose, LTS support |
| Ubuntu 24.04 LTS | `2284` | Latest LTS, modern features |
| Debian 12 | `2136` | Stable, enterprise-ready |
| CentOS Stream 9 | `542` | RHEL-compatible |
| Rocky Linux 9 | `1869` | CentOS replacement |
| AlmaLinux 9 | `1743` | RHEL alternative |

## Notes

- LTS versions are recommended for production use
- Check OS family for package management (apt, yum, dnf)
- Architecture (x64, i386, arm) must match your plan
- Some operating systems may have additional licensing costs

For the most current OS images, always fetch the latest data using the Vultr API.
FOOTER

    print_success "Created OS_IDS.md (${count} operating systems)"
}

# Main execution
main() {
    echo ""
    print_header "============================================================"
    print_header "  Vultr Documentation Updater"
    print_header "============================================================"
    echo ""
    
    # Check if scripts directory exists
    if [ ! -d "$SCRIPTS_DIR" ]; then
        print_error "Scripts directory not found: $SCRIPTS_DIR"
        exit 1
    fi
    
    # Check if bc is available for calculations
    if ! command -v bc &> /dev/null; then
        print_info "bc not installed. RAM will be shown in MB instead of GB"
    fi
    
    # Find CSV files
    print_info "Looking for CSV files in: $SCRIPTS_DIR"
    echo ""
    
    PLANS_CSV=$(find_latest_csv "vultr_plans_*.csv")
    print_success "Found plans: $(basename "$PLANS_CSV")"
    
    REGIONS_CSV=$(find_latest_csv "vultr_regions_*.csv")
    print_success "Found regions: $(basename "$REGIONS_CSV")"
    
    OS_CSV=$(find_latest_csv "vultr_os_*.csv")
    print_success "Found OS: $(basename "$OS_CSV")"
    
    echo ""
    print_header "Generating markdown files..."
    echo ""
    
    # Generate markdown files
    generate_plans_markdown "$PLANS_CSV"
    generate_regions_markdown "$REGIONS_CSV"
    generate_os_markdown "$OS_CSV"
    
    echo ""
    print_header "============================================================"
    print_success "All documentation files updated successfully!"
    print_header "============================================================"
    echo ""
    
    echo "Updated files in ${DOCS_DIR}:"
    echo "  • PLAN_IDS.md"
    echo "  • REGION_CODES.md"
    echo "  • OS_IDS.md"
    echo ""
    
    # Clean up CSV files unless --keep-csv is specified
    if [ "$KEEP_CSV" = false ]; then
        print_info "Cleaning up CSV files..."
        
        if [ -f "$PLANS_CSV" ]; then
            rm -f "$PLANS_CSV"
            print_success "Deleted: $(basename "$PLANS_CSV")"
        fi
        
        if [ -f "$REGIONS_CSV" ]; then
            rm -f "$REGIONS_CSV"
            print_success "Deleted: $(basename "$REGIONS_CSV")"
        fi
        
        if [ -f "$OS_CSV" ]; then
            rm -f "$OS_CSV"
            print_success "Deleted: $(basename "$OS_CSV")"
        fi
        
        echo ""
    else
        print_info "Keeping CSV files as requested"
        echo ""
    fi
}

# Run main function
main

exit 0
