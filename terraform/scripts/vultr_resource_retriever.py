#!/usr/bin/env python3
"""
Vultr Resource Information Retriever
This script retrieves and saves resource codes, regions, and OS information from Vultr API.
"""

import requests
import json
import csv
import sys
from datetime import datetime
from typing import Dict, List, Any

class VultrResourceRetriever:
    """Class to handle Vultr API interactions and data retrieval"""
    
    BASE_URL = "https://api.vultr.com/v2"
    
    def __init__(self, api_key: str = None):
        """
        Initialize the retriever with optional API key.
        
        Args:
            api_key: Vultr API key (optional for public endpoints)
        """
        self.api_key = api_key
        self.headers = {}
        if api_key:
            self.headers["Authorization"] = f"Bearer {api_key}"
    
    def _make_request(self, endpoint: str) -> Dict[str, Any]:
        """
        Make a GET request to Vultr API.
        
        Args:
            endpoint: API endpoint path
            
        Returns:
            JSON response as dictionary
        """
        url = f"{self.BASE_URL}/{endpoint}"
        try:
            response = requests.get(url, headers=self.headers)
            response.raise_for_status()
            return response.json()
        except requests.exceptions.RequestException as e:
            print(f"Error fetching {endpoint}: {e}", file=sys.stderr)
            return {}
    
    def _reorder_with_id_first(self, data: List[Dict[str, Any]]) -> List[Dict[str, Any]]:
        """
        Reorder dictionary keys to put 'id' first.
        
        Args:
            data: List of dictionaries
            
        Returns:
            List of dictionaries with 'id' as first key
        """
        reordered = []
        for item in data:
            if 'id' in item:
                # Create new dict with id first
                new_item = {'id': item['id']}
                new_item.update({k: v for k, v in item.items() if k != 'id'})
                reordered.append(new_item)
            else:
                reordered.append(item)
        return reordered
    
    def get_plans(self) -> List[Dict[str, Any]]:
        """
        Retrieve all available Vultr plans/resource codes.
        
        Returns:
            List of plan dictionaries with 'id' as first key
        """
        print("Fetching Vultr plans...")
        data = self._make_request("plans")
        plans = data.get("plans", [])
        plans = self._reorder_with_id_first(plans)
        print(f"Retrieved {len(plans)} plans")
        return plans
    
    def get_regions(self) -> List[Dict[str, Any]]:
        """
        Retrieve all available Vultr regions.
        
        Returns:
            List of region dictionaries with 'id' as first key
        """
        print("Fetching Vultr regions...")
        data = self._make_request("regions")
        regions = data.get("regions", [])
        regions = self._reorder_with_id_first(regions)
        print(f"Retrieved {len(regions)} regions")
        return regions
    
    def get_os_list(self) -> List[Dict[str, Any]]:
        """
        Retrieve all available operating systems.
        
        Returns:
            List of OS dictionaries with 'id' as first key
        """
        print("Fetching Vultr operating systems...")
        data = self._make_request("os")
        os_list = data.get("os", [])
        os_list = self._reorder_with_id_first(os_list)
        print(f"Retrieved {len(os_list)} operating systems")
        return os_list
    
    def save_to_json(self, data: Dict[str, Any], filename: str):
        """
        Save data to JSON file.
        
        Args:
            data: Data to save
            filename: Output filename
        """
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(data, f, indent=2, ensure_ascii=False)
            print(f"Data saved to {filename}")
        except IOError as e:
            print(f"Error saving to {filename}: {e}", file=sys.stderr)
    
    def save_to_csv(self, data: List[Dict[str, Any]], filename: str):
        """
        Save data to CSV file with 'id' as the first column.
        
        Args:
            data: List of dictionaries to save
            filename: Output filename
        """
        if not data:
            print(f"No data to save to {filename}")
            return
        
        try:
            with open(filename, 'w', newline='', encoding='utf-8') as f:
                # Get all unique keys from all dictionaries
                fieldnames = set()
                for item in data:
                    fieldnames.update(item.keys())
                
                # Sort fieldnames but ensure 'id' is first
                fieldnames = sorted(fieldnames)
                if 'id' in fieldnames:
                    fieldnames.remove('id')
                    fieldnames = ['id'] + fieldnames
                
                writer = csv.DictWriter(f, fieldnames=fieldnames)
                writer.writeheader()
                writer.writerows(data)
            print(f"Data saved to {filename}")
        except IOError as e:
            print(f"Error saving to {filename}: {e}", file=sys.stderr)
    
    def retrieve_and_save_all(self, output_dir: str = "."):
        """
        Retrieve all resource information and save to files.
        
        Args:
            output_dir: Directory to save output files
        """
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        
        # Retrieve data
        plans = self.get_plans()
        regions = self.get_regions()
        os_list = self.get_os_list()
        
        # Prepare combined data
        all_data = {
            "timestamp": datetime.now().isoformat(),
            "plans": plans,
            "regions": regions,
            "operating_systems": os_list
        }
        
        # Save to JSON
        json_file = f"{output_dir}/vultr_resources_{timestamp}.json"
        self.save_to_json(all_data, json_file)
        
        # Save individual CSV files
        if plans:
            csv_file = f"{output_dir}/vultr_plans_{timestamp}.csv"
            self.save_to_csv(plans, csv_file)
        
        if regions:
            csv_file = f"{output_dir}/vultr_regions_{timestamp}.csv"
            self.save_to_csv(regions, csv_file)
        
        if os_list:
            csv_file = f"{output_dir}/vultr_os_{timestamp}.csv"
            self.save_to_csv(os_list, csv_file)
        
        print("\n=== Summary ===")
        print(f"Plans: {len(plans)}")
        print(f"Regions: {len(regions)}")
        print(f"Operating Systems: {len(os_list)}")
        print(f"\nAll data saved to {output_dir}/")


def main():
    """Main function to run the script"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Retrieve and save Vultr resource information (plans, regions, OS)"
    )
    parser.add_argument(
        "--api-key",
        help="Vultr API key (optional, not required for public endpoints)",
        default=None
    )
    parser.add_argument(
        "--output-dir",
        help="Directory to save output files (default: current directory)",
        default="."
    )
    parser.add_argument(
        "--format",
        choices=["json", "csv", "both"],
        default="both",
        help="Output format (default: both)"
    )
    
    args = parser.parse_args()
    
    # Create retriever instance
    retriever = VultrResourceRetriever(api_key=args.api_key)
    
    # Retrieve and save all data
    retriever.retrieve_and_save_all(output_dir=args.output_dir)


if __name__ == "__main__":
    main()
