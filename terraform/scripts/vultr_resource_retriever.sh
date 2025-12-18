#!/bin/bash
#
# Vultr Resource Information Retriever (Bash version)
# This script retrieves and saves resource codes, regions, and OS information from Vultr API.
#

set -e

# Configuration
API_BASE_URL="https://api.vultr.com/v2"
OUTPUT_DIR="${OUTPUT_DIR:-.}"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to make API request
make_request() {
    local endpoint=$1
    local output_file=$2
    local api_key=$3
    
    print_info "Fetching data from: ${endpoint}"
    
    if [ -n "$api_key" ]; then
        curl -s -H "Authorization: Bearer ${api_key}" \
             "${API_BASE_URL}/${endpoint}" > "$output_file"
    else
        curl -s "${API_BASE_URL}/${endpoint}" > "$output_file"
    fi
    
    if [ $? -eq 0 ]; then
        print_info "Successfully retrieved: ${endpoint}"
        return 0
    else
        print_error "Failed to retrieve: ${endpoint}"
        return 1
    fi
}

# Function to reorder JSON objects to have 'id' as first key
reorder_json_with_id_first() {
    local input_file=$1
    local output_file=$2
    local json_key=$3
    
    if ! command -v jq &> /dev/null; then
        cp "$input_file" "$output_file"
        return 0
    fi
    
    jq ".${json_key} |= map(
        if has(\"id\") then
            {id: .id} + (del(.id))
        else
            .
        end
    )" "$input_file" > "$output_file"
}

# Function to convert JSON to CSV using jq
json_to_csv() {
    local json_file=$1
    local csv_file=$2
    local json_key=$3
    
    if ! command -v jq &> /dev/null; then
        print_warning "jq not installed. Skipping CSV conversion."
        return 1
    fi
    
    print_info "Converting ${json_file} to CSV..."
    
    # Extract the array and convert to CSV with 'id' as first column
    jq -r ".${json_key} // [] | 
           if length > 0 then
               (.[0] | keys_unsorted | 
                if index(\"id\") then 
                    [\"id\"] + (map(select(. != \"id\")) | sort)
                else 
                    sort 
                end) as \$keys | 
               \$keys, 
               map([.[ \$keys[] ]]) | 
               @csv
           else
               empty
           end" "$json_file" > "$csv_file" 2>/dev/null
    
    if [ $? -eq 0 ] && [ -s "$csv_file" ]; then
        print_info "CSV created: ${csv_file}"
        return 0
    else
        print_warning "Could not create CSV for ${json_file}"
        rm -f "$csv_file"
        return 1
    fi
}

# Function to display usage
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Retrieve and save Vultr resource information (plans, regions, OS).

OPTIONS:
    -k, --api-key KEY       Vultr API key (optional for public endpoints)
    -o, --output-dir DIR    Output directory (default: current directory)
    -f, --format FORMAT     Output format: json, csv, or both (default: both)
    -h, --help              Display this help message

EXAMPLES:
    # Retrieve all resources with default settings
    $0

    # Use API key and specify output directory
    $0 --api-key YOUR_API_KEY --output-dir ./vultr_data

    # Only save JSON format
    $0 --format json

REQUIREMENTS:
    - curl (required)
    - jq (optional, for CSV conversion)

EOF
    exit 0
}

# Parse command line arguments
API_KEY=""
OUTPUT_FORMAT="both"

while [[ $# -gt 0 ]]; do
    case $1 in
        -k|--api-key)
            API_KEY="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -f|--format)
            OUTPUT_FORMAT="$2"
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

# Check if curl is installed
if ! command -v curl &> /dev/null; then
    print_error "curl is required but not installed. Please install curl."
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

print_info "Starting Vultr resource retrieval..."
print_info "Output directory: ${OUTPUT_DIR}"
print_info "Output format: ${OUTPUT_FORMAT}"

# Temporary files for JSON responses
PLANS_JSON="${OUTPUT_DIR}/vultr_plans_${TIMESTAMP}.json"
REGIONS_JSON="${OUTPUT_DIR}/vultr_regions_${TIMESTAMP}.json"
OS_JSON="${OUTPUT_DIR}/vultr_os_${TIMESTAMP}.json"
COMBINED_JSON="${OUTPUT_DIR}/vultr_resources_${TIMESTAMP}.json"

# Retrieve data from API
make_request "plans" "$PLANS_JSON" "$API_KEY"
PLANS_SUCCESS=$?

make_request "regions" "$REGIONS_JSON" "$API_KEY"
REGIONS_SUCCESS=$?

make_request "os" "$OS_JSON" "$API_KEY"
OS_SUCCESS=$?

# Reorder JSON data to have 'id' as first key
if command -v jq &> /dev/null; then
    print_info "Reordering JSON data with 'id' as first key..."
    reorder_json_with_id_first "$PLANS_JSON" "${PLANS_JSON}.tmp" "plans" && mv "${PLANS_JSON}.tmp" "$PLANS_JSON"
    reorder_json_with_id_first "$REGIONS_JSON" "${REGIONS_JSON}.tmp" "regions" && mv "${REGIONS_JSON}.tmp" "$REGIONS_JSON"
    reorder_json_with_id_first "$OS_JSON" "${OS_JSON}.tmp" "os" && mv "${OS_JSON}.tmp" "$OS_JSON"
fi

# Count retrieved items
if command -v jq &> /dev/null; then
    PLANS_COUNT=$(jq '.plans | length' "$PLANS_JSON" 2>/dev/null || echo "0")
    REGIONS_COUNT=$(jq '.regions | length' "$REGIONS_JSON" 2>/dev/null || echo "0")
    OS_COUNT=$(jq '.os | length' "$OS_JSON" 2>/dev/null || echo "0")
else
    PLANS_COUNT="N/A"
    REGIONS_COUNT="N/A"
    OS_COUNT="N/A"
fi

# Create combined JSON file
if [ "$OUTPUT_FORMAT" = "json" ] || [ "$OUTPUT_FORMAT" = "both" ]; then
    print_info "Creating combined JSON file..."
    
    if command -v jq &> /dev/null; then
        jq -n \
            --arg timestamp "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
            --slurpfile plans "$PLANS_JSON" \
            --slurpfile regions "$REGIONS_JSON" \
            --slurpfile os "$OS_JSON" \
            '{
                timestamp: $timestamp,
                plans: ($plans[0].plans // [] | map(
                    if has("id") then {id: .id} + (del(.id)) else . end
                )),
                regions: ($regions[0].regions // [] | map(
                    if has("id") then {id: .id} + (del(.id)) else . end
                )),
                operating_systems: ($os[0].os // [] | map(
                    if has("id") then {id: .id} + (del(.id)) else . end
                ))
            }' > "$COMBINED_JSON"
        
        print_info "Combined JSON saved: ${COMBINED_JSON}"
    else
        print_warning "jq not available. Combined JSON not created."
    fi
fi

# Convert to CSV if requested
if [ "$OUTPUT_FORMAT" = "csv" ] || [ "$OUTPUT_FORMAT" = "both" ]; then
    if command -v jq &> /dev/null; then
        print_info "Converting to CSV format..."
        
        json_to_csv "$PLANS_JSON" "${OUTPUT_DIR}/vultr_plans_${TIMESTAMP}.csv" "plans"
        json_to_csv "$REGIONS_JSON" "${OUTPUT_DIR}/vultr_regions_${TIMESTAMP}.csv" "regions"
        json_to_csv "$OS_JSON" "${OUTPUT_DIR}/vultr_os_${TIMESTAMP}.csv" "os"
    else
        print_warning "jq not installed. Cannot create CSV files."
        print_warning "Install jq to enable CSV conversion: apt-get install jq (Debian/Ubuntu) or brew install jq (macOS)"
    fi
fi

# Clean up individual JSON files if only CSV is requested
if [ "$OUTPUT_FORMAT" = "csv" ]; then
    rm -f "$PLANS_JSON" "$REGIONS_JSON" "$OS_JSON"
fi

# Print summary
echo ""
print_info "=== Summary ==="
echo "Plans: ${PLANS_COUNT}"
echo "Regions: ${REGIONS_COUNT}"
echo "Operating Systems: ${OS_COUNT}"
echo ""
print_info "All data saved to: ${OUTPUT_DIR}/"

# List created files
echo ""
print_info "Created files:"
ls -lh "${OUTPUT_DIR}"/*"${TIMESTAMP}"* 2>/dev/null || print_warning "No files created"

exit 0
