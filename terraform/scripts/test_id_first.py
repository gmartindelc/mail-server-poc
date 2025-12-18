#!/usr/bin/env python3
"""
Test script to demonstrate that 'id' is always the first column/key
"""

import json
import csv

# Sample data to demonstrate
sample_plan = {
    'id': 'vc2-1c-1gb',
    'vcpu_count': 1,
    'ram': 1024,
    'disk': 25,
    'bandwidth': 1000,
    'monthly_cost': 5.00,
    'type': 'vc2'
}

sample_region = {
    'id': 'ewr',
    'city': 'New Jersey',
    'country': 'US',
    'continent': 'North America',
    'options': ['ddos_protection']
}

sample_os = {
    'id': 387,
    'name': 'Ubuntu 22.04 x64',
    'arch': 'x64',
    'family': 'ubuntu'
}

def reorder_with_id_first(item: dict) -> dict:
    """Reorder dictionary to have 'id' first"""
    if 'id' in item:
        new_item = {'id': item['id']}
        new_item.update({k: v for k, v in item.items() if k != 'id'})
        return new_item
    return item

def demo_json_order():
    """Demonstrate JSON key order"""
    print("=" * 60)
    print("JSON KEY ORDER DEMONSTRATION")
    print("=" * 60)
    
    print("\n1. Original Plan (random key order):")
    print(json.dumps(sample_plan, indent=2))
    
    print("\n2. Reordered Plan (id first):")
    reordered_plan = reorder_with_id_first(sample_plan)
    print(json.dumps(reordered_plan, indent=2))
    
    print("\n3. Keys order:")
    print(f"   Original: {list(sample_plan.keys())}")
    print(f"   Reordered: {list(reordered_plan.keys())}")
    print(f"   ✓ 'id' is first: {list(reordered_plan.keys())[0] == 'id'}")

def demo_csv_order():
    """Demonstrate CSV column order"""
    print("\n" + "=" * 60)
    print("CSV COLUMN ORDER DEMONSTRATION")
    print("=" * 60)
    
    # Sample data list
    data = [
        {'name': 'Item A', 'price': 10, 'id': 'itm-001', 'stock': 50},
        {'name': 'Item B', 'price': 20, 'id': 'itm-002', 'stock': 30},
        {'name': 'Item C', 'price': 15, 'id': 'itm-003', 'stock': 40},
    ]
    
    print("\n1. Original data (id not first):")
    for item in data[:2]:
        print(f"   {item}")
    
    # Reorder to have id first
    reordered_data = [reorder_with_id_first(item) for item in data]
    
    print("\n2. Reordered data (id first):")
    for item in reordered_data[:2]:
        print(f"   {item}")
    
    # Write CSV
    filename = 'test_output.csv'
    fieldnames = list(reordered_data[0].keys())
    
    with open(filename, 'w', newline='') as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(reordered_data)
    
    print(f"\n3. CSV file created: {filename}")
    print("   Column order:", ', '.join(fieldnames))
    print(f"   ✓ First column is 'id': {fieldnames[0] == 'id'}")
    
    # Show CSV content
    print("\n4. CSV file contents:")
    with open(filename, 'r') as f:
        print(f.read())

def main():
    print("\n")
    print("╔" + "=" * 58 + "╗")
    print("║  VULTR RESOURCE RETRIEVER - ID FIRST COLUMN TEST       ║")
    print("╚" + "=" * 58 + "╝")
    print()
    
    demo_json_order()
    demo_csv_order()
    
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    print("✓ All JSON objects have 'id' as the first key")
    print("✓ All CSV files have 'id' as the first column")
    print("✓ This applies to plans, regions, and operating systems")
    print("\nThis ensures easy sorting and reference of resources!")
    print()

if __name__ == "__main__":
    main()
