# Vultr Resource Information Retriever

This repository contains scripts to retrieve and save resource codes, regions, and operating systems from Vultr.com via their API.

## Overview

These scripts fetch the following information from Vultr:
- **Plans** (resource codes): Available server plans with pricing, specifications, and plan IDs
- **Regions**: Available data center locations with region codes
- **Operating Systems**: Available OS templates with IDs and names

## Files Included

1. **vultr_resource_retriever.py** - Python script with full functionality
2. **vultr_resource_retriever.sh** - Bash script alternative
3. **README.md** - This documentation file

## Requirements

### Python Script
- Python 3.6 or higher
- `requests` library: `pip install requests`

### Bash Script
- `curl` (required)
- `jq` (optional, for CSV conversion and prettier output)

## Installation

### Python Dependencies
```bash
pip install requests
```

### Bash Dependencies (Linux/Mac)
```bash
# Debian/Ubuntu
sudo apt-get install curl jq

# macOS
brew install curl jq

# RHEL/CentOS
sudo yum install curl jq
```

## Usage

### Python Script

#### Basic Usage (No API Key Required)
```bash
python3 vultr_resource_retriever.py
```

#### With API Key
```bash
python3 vultr_resource_retriever.py --api-key YOUR_API_KEY
```

#### Specify Output Directory
```bash
python3 vultr_resource_retriever.py --output-dir ./vultr_data
```

#### Full Options
```bash
python3 vultr_resource_retriever.py \
    --api-key YOUR_API_KEY \
    --output-dir ./output \
    --format both
```

### Bash Script

#### Make the script executable first
```bash
chmod +x vultr_resource_retriever.sh
```

#### Basic Usage
```bash
./vultr_resource_retriever.sh
```

#### With Options
```bash
./vultr_resource_retriever.sh \
    --api-key YOUR_API_KEY \
    --output-dir ./vultr_data \
    --format both
```

#### Environment Variable for Output Directory
```bash
OUTPUT_DIR=./data ./vultr_resource_retriever.sh
```

## Command Line Options

Both scripts support the following options:

| Option | Description | Default |
|--------|-------------|---------|
| `--api-key` / `-k` | Vultr API key (optional) | None |
| `--output-dir` / `-o` | Directory to save files | Current directory |
| `--format` / `-f` | Output format: `json`, `csv`, or `both` | `both` |
| `--help` / `-h` | Display help message | - |

## Output Files

The scripts generate timestamped files with the following naming convention. **All CSV and JSON outputs are organized with the `id` field as the first column/key for easy reference.**

### JSON Files
- `vultr_resources_YYYYMMDD_HHMMSS.json` - Combined data file
- `vultr_plans_YYYYMMDD_HHMMSS.json` - Plans only
- `vultr_regions_YYYYMMDD_HHMMSS.json` - Regions only
- `vultr_os_YYYYMMDD_HHMMSS.json` - Operating systems only

### CSV Files
- `vultr_plans_YYYYMMDD_HHMMSS.csv` - Plans in CSV format
- `vultr_regions_YYYYMMDD_HHMMSS.csv` - Regions in CSV format
- `vultr_os_YYYYMMDD_HHMMSS.csv` - Operating systems in CSV format

## Output Data Structure

### Plans (Resource Codes)
Each plan includes:
- `id` - Plan identifier (e.g., "vc2-1c-1gb")
- `vcpu_count` - Number of virtual CPUs
- `ram` - RAM in MB
- `disk` - Disk space in GB
- `bandwidth` - Monthly bandwidth in GB
- `monthly_cost` - Price in USD
- `type` - Plan type (vc2, vhf, vhp, etc.)
- `locations` - Available regions for this plan

### Regions
Each region includes:
- `id` - Region code (e.g., "ewr", "lax", "ams")
- `country` - Country code
- `city` - City name
- `continent` - Continent
- `options` - Available features (ddos_protection, block_storage, etc.)

### Operating Systems
Each OS includes:
- `id` - OS identifier
- `name` - Operating system name
- `arch` - Architecture (x64, i386)
- `family` - OS family (ubuntu, centos, windows, etc.)

## API Key Information

### Do I need an API key?
No, the Vultr API endpoints for plans, regions, and operating systems are **public** and don't require authentication. However, having an API key may provide:
- Higher rate limits
- Access to additional information
- Ability to query account-specific data

### How to get an API key
1. Log in to your Vultr account at https://my.vultr.com/
2. Navigate to Account → API
3. Generate a new API key
4. Use it with the `--api-key` option

## Examples

### Example 1: Quick Retrieval
```bash
# Python
python3 vultr_resource_retriever.py

# Bash
./vultr_resource_retriever.sh
```

### Example 2: Save to Specific Directory
```bash
# Create output directory
mkdir -p ~/vultr_data

# Python
python3 vultr_resource_retriever.py --output-dir ~/vultr_data

# Bash
./vultr_resource_retriever.sh --output-dir ~/vultr_data
```

### Example 3: JSON Only
```bash
# Python
python3 vultr_resource_retriever.py --format json

# Bash
./vultr_resource_retriever.sh --format json
```

### Example 4: With API Key
```bash
# Python
python3 vultr_resource_retriever.py --api-key YOUR_API_KEY_HERE

# Bash
./vultr_resource_retriever.sh --api-key YOUR_API_KEY_HERE
```

## Sample Output

```
[INFO] Starting Vultr resource retrieval...
[INFO] Output directory: ./vultr_data
[INFO] Output format: both
Fetching Vultr plans...
Retrieved 45 plans
Fetching Vultr regions...
Retrieved 32 regions
Fetching Vultr operating systems...
Retrieved 67 operating systems
Data saved to vultr_data/vultr_resources_20231218_143022.json
Data saved to vultr_data/vultr_plans_20231218_143022.csv
Data saved to vultr_data/vultr_regions_20231218_143022.csv
Data saved to vultr_data/vultr_os_20231218_143022.csv

=== Summary ===
Plans: 45
Regions: 32
Operating Systems: 67

All data saved to vultr_data/
```

## Troubleshooting

### Python: "ModuleNotFoundError: No module named 'requests'"
```bash
pip install requests
```

### Bash: "curl: command not found"
```bash
# Ubuntu/Debian
sudo apt-get install curl

# macOS
brew install curl
```

### Bash: CSV files not generated
Install `jq`:
```bash
# Ubuntu/Debian
sudo apt-get install jq

# macOS
brew install jq
```

### API Rate Limiting
If you encounter rate limiting:
1. Use an API key with `--api-key`
2. Add delays between requests
3. Contact Vultr support for increased limits

## API Documentation

For more information about the Vultr API:
- Official API Documentation: https://www.vultr.com/api/
- API v2 Reference: https://www.vultr.com/api/v2/

## License

These scripts are provided as-is for educational and practical purposes. Feel free to modify and use them according to your needs.

## Contributing

Suggestions and improvements are welcome! Feel free to:
- Report issues
- Submit pull requests
- Suggest new features

## Disclaimer

These scripts use the public Vultr API. Always ensure you comply with Vultr's Terms of Service and API usage policies.
