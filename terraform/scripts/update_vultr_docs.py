#!/usr/bin/env python3
"""
Update Vultr Documentation Markdown Files from CSV Data

This script reads vultr_*.csv files from the scripts directory and updates
the corresponding markdown documentation files in the parent directory.

Files updated:
- PLAN_IDS.md (from vultr_plans_*.csv)
- REGION_CODES.md (from vultr_regions_*.csv)
- OS_IDS.md (from vultr_os_*.csv)
"""

import csv
import os
import sys
from datetime import datetime
from pathlib import Path
from typing import List, Dict, Any
import glob


class VultrDocsUpdater:
    """Updates Vultr documentation markdown files from CSV data"""
    
    def __init__(self, scripts_dir: str = "./scripts", docs_dir: str = "."):
        """
        Initialize the updater.
        
        Args:
            scripts_dir: Directory containing CSV files
            docs_dir: Directory containing markdown files to update
        """
        self.scripts_dir = Path(scripts_dir)
        self.docs_dir = Path(docs_dir)
        
    def find_latest_csv(self, pattern: str) -> Path:
        """
        Find the most recent CSV file matching the pattern.
        
        Args:
            pattern: Glob pattern to match CSV files
            
        Returns:
            Path to the latest CSV file
        """
        csv_files = list(self.scripts_dir.glob(pattern))
        if not csv_files:
            raise FileNotFoundError(f"No CSV files found matching: {pattern}")
        
        # Sort by modification time, return the latest
        latest = max(csv_files, key=lambda p: p.stat().st_mtime)
        print(f"✓ Found latest file: {latest.name}")
        return latest
    
    def read_csv(self, csv_path: Path) -> List[Dict[str, Any]]:
        """
        Read CSV file and return list of dictionaries.
        
        Args:
            csv_path: Path to CSV file
            
        Returns:
            List of dictionaries representing rows
        """
        data = []
        with open(csv_path, 'r', encoding='utf-8') as f:
            reader = csv.DictReader(f)
            for row in reader:
                data.append(row)
        print(f"  Read {len(data)} rows from {csv_path.name}")
        return data
    
    def format_table_row(self, values: List[str], widths: List[int]) -> str:
        """
        Format a markdown table row with proper column widths.
        
        Args:
            values: List of cell values
            widths: List of column widths
            
        Returns:
            Formatted markdown table row
        """
        cells = []
        for value, width in zip(values, widths):
            # Truncate if too long
            if len(str(value)) > width:
                value = str(value)[:width-3] + "..."
            cells.append(f" {str(value):<{width}} ")
        return "|" + "|".join(cells) + "|"
    
    def generate_plans_markdown(self, plans_data: List[Dict[str, Any]]) -> str:
        """
        Generate markdown content for PLAN_IDS.md.
        
        Args:
            plans_data: List of plan dictionaries
            
        Returns:
            Markdown content as string
        """
        content = []
        content.append("# Vultr Plan IDs (Resource Codes)")
        content.append("")
        content.append(f"*Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*")
        content.append("")
        content.append("This document contains all available Vultr plan IDs and their specifications.")
        content.append("")
        
        # Sort plans by monthly cost (if available)
        sorted_plans = sorted(
            plans_data, 
            key=lambda x: float(x.get('monthly_cost', 0) or 0)
        )
        
        # Group by type
        plans_by_type = {}
        for plan in sorted_plans:
            plan_type = plan.get('type', 'unknown')
            if plan_type not in plans_by_type:
                plans_by_type[plan_type] = []
            plans_by_type[plan_type].append(plan)
        
        # Create summary
        content.append("## Summary")
        content.append("")
        content.append(f"- **Total Plans:** {len(plans_data)}")
        content.append(f"- **Plan Types:** {len(plans_by_type)}")
        content.append("")
        
        # Table of contents
        content.append("## Plan Types")
        content.append("")
        for plan_type in sorted(plans_by_type.keys()):
            count = len(plans_by_type[plan_type])
            content.append(f"- [{plan_type.upper()}](#{plan_type.lower()}-plans) ({count} plans)")
        content.append("")
        
        # All plans table
        content.append("## All Plans")
        content.append("")
        content.append("| ID | Type | vCPUs | RAM (GB) | Disk (GB) | Bandwidth (GB) | Monthly Cost |")
        content.append("|---|---|---|---|---|---|---|")
        
        for plan in sorted_plans:
            ram_gb = int(plan.get('ram', 0)) / 1024 if plan.get('ram') else 0
            content.append(
                f"| `{plan.get('id', 'N/A')}` "
                f"| {plan.get('type', 'N/A')} "
                f"| {plan.get('vcpu_count', 'N/A')} "
                f"| {ram_gb:.1f} "
                f"| {plan.get('disk', 'N/A')} "
                f"| {plan.get('bandwidth', 'N/A')} "
                f"| ${plan.get('monthly_cost', 'N/A')} |"
            )
        content.append("")
        
        # Detailed sections by type
        for plan_type in sorted(plans_by_type.keys()):
            content.append(f"## {plan_type.upper()} Plans")
            content.append("")
            
            type_plans = plans_by_type[plan_type]
            
            # Get all available keys for this type
            all_keys = set()
            for plan in type_plans:
                all_keys.update(plan.keys())
            
            # Define key columns
            key_columns = ['id', 'vcpu_count', 'ram', 'disk', 'bandwidth', 'monthly_cost']
            other_columns = sorted([k for k in all_keys if k not in key_columns])
            
            # Create detailed table
            headers = ['ID', 'vCPUs', 'RAM (MB)', 'Disk (GB)', 'Bandwidth (GB)', 'Cost/mo'] + [k.replace('_', ' ').title() for k in other_columns]
            content.append("| " + " | ".join(headers) + " |")
            content.append("|" + "|".join(["---"] * len(headers)) + "|")
            
            for plan in type_plans:
                row = [
                    f"`{plan.get('id', 'N/A')}`",
                    str(plan.get('vcpu_count', 'N/A')),
                    str(plan.get('ram', 'N/A')),
                    str(plan.get('disk', 'N/A')),
                    str(plan.get('bandwidth', 'N/A')),
                    f"${plan.get('monthly_cost', 'N/A')}"
                ]
                
                for col in other_columns:
                    value = plan.get(col, 'N/A')
                    # Truncate long values
                    if isinstance(value, str) and len(value) > 30:
                        value = value[:27] + "..."
                    row.append(str(value))
                
                content.append("| " + " | ".join(row) + " |")
            
            content.append("")
        
        # Usage section
        content.append("## Usage in Terraform")
        content.append("")
        content.append("```hcl")
        content.append("resource \"vultr_instance\" \"example\" {")
        content.append("  plan    = \"vc2-1c-1gb\"  # Choose from the IDs above")
        content.append("  region  = \"ewr\"")
        content.append("  os_id   = 387")
        content.append("}")
        content.append("```")
        content.append("")
        
        return "\n".join(content)
    
    def generate_regions_markdown(self, regions_data: List[Dict[str, Any]]) -> str:
        """
        Generate markdown content for REGION_CODES.md.
        
        Args:
            regions_data: List of region dictionaries
            
        Returns:
            Markdown content as string
        """
        content = []
        content.append("# Vultr Region Codes")
        content.append("")
        content.append(f"*Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*")
        content.append("")
        content.append("This document contains all available Vultr region codes and locations.")
        content.append("")
        
        # Sort by continent, then country, then city
        sorted_regions = sorted(
            regions_data,
            key=lambda x: (
                x.get('continent', ''),
                x.get('country', ''),
                x.get('city', '')
            )
        )
        
        # Group by continent
        regions_by_continent = {}
        for region in sorted_regions:
            continent = region.get('continent', 'Unknown')
            if continent not in regions_by_continent:
                regions_by_continent[continent] = []
            regions_by_continent[continent].append(region)
        
        # Summary
        content.append("## Summary")
        content.append("")
        content.append(f"- **Total Regions:** {len(regions_data)}")
        content.append(f"- **Continents:** {len(regions_by_continent)}")
        content.append("")
        
        # Quick reference table
        content.append("## Quick Reference")
        content.append("")
        content.append("| Region Code | City | Country | Continent |")
        content.append("|---|---|---|---|")
        
        for region in sorted_regions:
            content.append(
                f"| `{region.get('id', 'N/A')}` "
                f"| {region.get('city', 'N/A')} "
                f"| {region.get('country', 'N/A')} "
                f"| {region.get('continent', 'N/A')} |"
            )
        content.append("")
        
        # Detailed sections by continent
        for continent in sorted(regions_by_continent.keys()):
            content.append(f"## {continent}")
            content.append("")
            
            continent_regions = regions_by_continent[continent]
            
            # Get all keys
            all_keys = set()
            for region in continent_regions:
                all_keys.update(region.keys())
            
            # Define columns
            key_columns = ['id', 'city', 'country', 'options']
            other_columns = sorted([k for k in all_keys if k not in key_columns and k != 'continent'])
            
            headers = ['Code', 'City', 'Country', 'Features'] + [k.replace('_', ' ').title() for k in other_columns]
            content.append("| " + " | ".join(headers) + " |")
            content.append("|" + "|".join(["---"] * len(headers)) + "|")
            
            for region in continent_regions:
                # Format options/features
                options = region.get('options', '')
                if isinstance(options, str) and options.startswith('['):
                    # Parse list-like string
                    options = options.strip('[]').replace("'", "").replace('"', '')
                
                row = [
                    f"`{region.get('id', 'N/A')}`",
                    region.get('city', 'N/A'),
                    region.get('country', 'N/A'),
                    options if options else 'N/A'
                ]
                
                for col in other_columns:
                    value = region.get(col, 'N/A')
                    if isinstance(value, str) and len(value) > 40:
                        value = value[:37] + "..."
                    row.append(str(value))
                
                content.append("| " + " | ".join(row) + " |")
            
            content.append("")
        
        # Usage section
        content.append("## Usage in Terraform")
        content.append("")
        content.append("```hcl")
        content.append("resource \"vultr_instance\" \"example\" {")
        content.append("  plan    = \"vc2-1c-1gb\"")
        content.append("  region  = \"ewr\"  # Choose from the codes above")
        content.append("  os_id   = 387")
        content.append("}")
        content.append("```")
        content.append("")
        
        return "\n".join(content)
    
    def generate_os_markdown(self, os_data: List[Dict[str, Any]]) -> str:
        """
        Generate markdown content for OS_IDS.md.
        
        Args:
            os_data: List of OS dictionaries
            
        Returns:
            Markdown content as string
        """
        content = []
        content.append("# Vultr Operating System IDs")
        content.append("")
        content.append(f"*Last updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*")
        content.append("")
        content.append("This document contains all available Vultr operating system IDs.")
        content.append("")
        
        # Sort by family, then name
        sorted_os = sorted(
            os_data,
            key=lambda x: (
                x.get('family', ''),
                x.get('name', '')
            )
        )
        
        # Group by family
        os_by_family = {}
        for os in sorted_os:
            family = os.get('family', 'other')
            if family not in os_by_family:
                os_by_family[family] = []
            os_by_family[family].append(os)
        
        # Summary
        content.append("## Summary")
        content.append("")
        content.append(f"- **Total Operating Systems:** {len(os_data)}")
        content.append(f"- **OS Families:** {len(os_by_family)}")
        content.append("")
        
        # Table of contents
        content.append("## OS Families")
        content.append("")
        for family in sorted(os_by_family.keys()):
            count = len(os_by_family[family])
            content.append(f"- [{family.title()}](#{family.lower()}) ({count} versions)")
        content.append("")
        
        # Quick reference table
        content.append("## Quick Reference")
        content.append("")
        content.append("| OS ID | Name | Family | Architecture |")
        content.append("|---|---|---|---|")
        
        for os in sorted_os:
            content.append(
                f"| `{os.get('id', 'N/A')}` "
                f"| {os.get('name', 'N/A')} "
                f"| {os.get('family', 'N/A')} "
                f"| {os.get('arch', 'N/A')} |"
            )
        content.append("")
        
        # Detailed sections by family
        for family in sorted(os_by_family.keys()):
            content.append(f"## {family.title()}")
            content.append("")
            
            family_os = os_by_family[family]
            
            content.append("| OS ID | Name | Architecture |")
            content.append("|---|---|---|")
            
            for os in family_os:
                content.append(
                    f"| `{os.get('id', 'N/A')}` "
                    f"| {os.get('name', 'N/A')} "
                    f"| {os.get('arch', 'N/A')} |"
                )
            
            content.append("")
        
        # Usage section
        content.append("## Usage in Terraform")
        content.append("")
        content.append("```hcl")
        content.append("resource \"vultr_instance\" \"example\" {")
        content.append("  plan    = \"vc2-1c-1gb\"")
        content.append("  region  = \"ewr\"")
        content.append("  os_id   = 387  # Choose from the IDs above")
        content.append("}")
        content.append("```")
        content.append("")
        content.append("## Popular Choices")
        content.append("")
        content.append("Here are some commonly used operating systems:")
        content.append("")
        content.append("| OS | ID | Use Case |")
        content.append("|---|---|---|")
        content.append("| Ubuntu 22.04 LTS | `387` | General purpose, LTS support |")
        content.append("| Ubuntu 24.04 LTS | `2284` | Latest LTS, modern features |")
        content.append("| Debian 12 | `2136` | Stable, enterprise-ready |")
        content.append("| CentOS Stream 9 | `542` | RHEL-compatible |")
        content.append("| Rocky Linux 9 | `1869` | CentOS replacement |")
        content.append("")
        
        return "\n".join(content)
    
    def update_file(self, content: str, filepath: Path):
        """
        Write content to file.
        
        Args:
            content: Markdown content to write
            filepath: Path to the output file
        """
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"✓ Updated: {filepath}")
    
    def run(self, keep_csv: bool = False):
        """
        Run the documentation update process
        
        Args:
            keep_csv: If True, keep CSV files after processing. If False, delete them.
        """
        print("=" * 60)
        print("Vultr Documentation Updater")
        print("=" * 60)
        print()
        
        try:
            # Update PLAN_IDS.md
            print("📋 Processing Plans...")
            plans_csv = self.find_latest_csv("vultr_plans_*.csv")
            plans_data = self.read_csv(plans_csv)
            plans_md = self.generate_plans_markdown(plans_data)
            self.update_file(plans_md, self.docs_dir / "PLAN_IDS.md")
            print()
            
            # Update REGION_CODES.md
            print("🌍 Processing Regions...")
            regions_csv = self.find_latest_csv("vultr_regions_*.csv")
            regions_data = self.read_csv(regions_csv)
            regions_md = self.generate_regions_markdown(regions_data)
            self.update_file(regions_md, self.docs_dir / "REGION_CODES.md")
            print()
            
            # Update OS_IDS.md
            print("💿 Processing Operating Systems...")
            os_csv = self.find_latest_csv("vultr_os_*.csv")
            os_data = self.read_csv(os_csv)
            os_md = self.generate_os_markdown(os_data)
            self.update_file(os_md, self.docs_dir / "OS_IDS.md")
            print()
            
            print("=" * 60)
            print("✅ All documentation files updated successfully!")
            print("=" * 60)
            print()
            print("Updated files:")
            print(f"  - {self.docs_dir / 'PLAN_IDS.md'}")
            print(f"  - {self.docs_dir / 'REGION_CODES.md'}")
            print(f"  - {self.docs_dir / 'OS_IDS.md'}")
            print()
            
            # Clean up CSV files unless --keep-csv is specified
            if not keep_csv:
                print("🗑️  Cleaning up CSV files...")
                csv_files = [plans_csv, regions_csv, os_csv]
                for csv_file in csv_files:
                    try:
                        csv_file.unlink()
                        print(f"  ✓ Deleted: {csv_file.name}")
                    except Exception as e:
                        print(f"  ⚠ Could not delete {csv_file.name}: {e}")
                print()
            else:
                print("📁 Keeping CSV files as requested")
                print()
            
        except FileNotFoundError as e:
            print(f"❌ Error: {e}", file=sys.stderr)
            sys.exit(1)
        except Exception as e:
            print(f"❌ Unexpected error: {e}", file=sys.stderr)
            import traceback
            traceback.print_exc()
            sys.exit(1)


def main():
    """Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Update Vultr documentation markdown files from CSV data"
    )
    parser.add_argument(
        "--scripts-dir",
        default="./scripts",
        help="Directory containing CSV files (default: ./scripts)"
    )
    parser.add_argument(
        "--docs-dir",
        default=".",
        help="Directory containing markdown files (default: current directory)"
    )
    parser.add_argument(
        "--keep-csv",
        action="store_true",
        help="Keep CSV files after generating documentation (default: delete them)"
    )
    
    args = parser.parse_args()
    
    updater = VultrDocsUpdater(
        scripts_dir=args.scripts_dir,
        docs_dir=args.docs_dir
    )
    updater.run(keep_csv=args.keep_csv)


if __name__ == "__main__":
    main()
