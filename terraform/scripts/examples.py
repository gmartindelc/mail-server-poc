#!/usr/bin/env python3
"""
Example usage of VultrResourceRetriever class
Demonstrates how to use the retriever programmatically in your own scripts
"""

from vultr_resource_retriever import VultrResourceRetriever

def example_basic_usage():
    """Example: Basic usage without API key"""
    print("=== Example 1: Basic Usage ===\n")
    
    retriever = VultrResourceRetriever()
    
    # Get plans
    plans = retriever.get_plans()
    print(f"Found {len(plans)} plans")
    if plans:
        print(f"First plan: {plans[0]['id']}")
    
    # Get regions
    regions = retriever.get_regions()
    print(f"Found {len(regions)} regions")
    if regions:
        print(f"First region: {regions[0]['id']} - {regions[0]['city']}")
    
    # Get operating systems
    os_list = retriever.get_os_list()
    print(f"Found {len(os_list)} operating systems")
    if os_list:
        print(f"First OS: {os_list[0]['name']}")
    print()


def example_with_api_key():
    """Example: Usage with API key"""
    print("=== Example 2: With API Key ===\n")
    
    # Replace with your actual API key
    api_key = "YOUR_API_KEY_HERE"
    
    retriever = VultrResourceRetriever(api_key=api_key)
    
    # Retrieve and save all data
    retriever.retrieve_and_save_all(output_dir="./output")
    print()


def example_filter_plans():
    """Example: Filter plans by criteria"""
    print("=== Example 3: Filter Plans ===\n")
    
    retriever = VultrResourceRetriever()
    plans = retriever.get_plans()
    
    # Filter plans with at least 2 CPUs and 4GB RAM
    filtered_plans = [
        plan for plan in plans 
        if plan.get('vcpu_count', 0) >= 2 and plan.get('ram', 0) >= 4096
    ]
    
    print(f"Plans with 2+ CPUs and 4+ GB RAM: {len(filtered_plans)}")
    for plan in filtered_plans[:5]:  # Show first 5
        print(f"  - {plan['id']}: {plan['vcpu_count']} CPU, "
              f"{plan['ram']//1024}GB RAM, ${plan.get('monthly_cost', 'N/A')}/mo")
    print()


def example_find_regions_by_country():
    """Example: Find regions by country"""
    print("=== Example 4: Find Regions by Country ===\n")
    
    retriever = VultrResourceRetriever()
    regions = retriever.get_regions()
    
    # Group regions by country
    countries = {}
    for region in regions:
        country = region.get('country', 'Unknown')
        if country not in countries:
            countries[country] = []
        countries[country].append(region)
    
    print("Regions by country:")
    for country, region_list in sorted(countries.items()):
        cities = [r['city'] for r in region_list]
        print(f"  {country}: {', '.join(cities)}")
    print()


def example_os_by_family():
    """Example: Group operating systems by family"""
    print("=== Example 5: Operating Systems by Family ===\n")
    
    retriever = VultrResourceRetriever()
    os_list = retriever.get_os_list()
    
    # Group by family
    families = {}
    for os in os_list:
        family = os.get('family', 'other')
        if family not in families:
            families[family] = []
        families[family].append(os['name'])
    
    print("Operating systems by family:")
    for family, os_names in sorted(families.items()):
        print(f"\n{family.upper()}:")
        for name in sorted(os_names)[:10]:  # Show first 10
            print(f"  - {name}")
        if len(os_names) > 10:
            print(f"  ... and {len(os_names) - 10} more")
    print()


def example_cheapest_plans():
    """Example: Find cheapest plans"""
    print("=== Example 6: Find Cheapest Plans ===\n")
    
    retriever = VultrResourceRetriever()
    plans = retriever.get_plans()
    
    # Sort by monthly cost
    plans_with_cost = [p for p in plans if 'monthly_cost' in p and p['monthly_cost']]
    sorted_plans = sorted(plans_with_cost, key=lambda x: float(x['monthly_cost']))
    
    print("5 Cheapest plans:")
    for plan in sorted_plans[:5]:
        print(f"  ${plan['monthly_cost']:>6}/mo - {plan['id']}: "
              f"{plan['vcpu_count']} CPU, {plan['ram']//1024}GB RAM, {plan['disk']}GB disk")
    print()


def example_save_specific_data():
    """Example: Save only specific data"""
    print("=== Example 7: Save Specific Data Only ===\n")
    
    retriever = VultrResourceRetriever()
    
    # Get only regions in the US
    all_regions = retriever.get_regions()
    us_regions = [r for r in all_regions if r.get('country') == 'US']
    
    # Save to custom file
    retriever.save_to_json({"us_regions": us_regions}, "us_regions_only.json")
    retriever.save_to_csv(us_regions, "us_regions_only.csv")
    
    print(f"Saved {len(us_regions)} US regions to custom files")
    print()


if __name__ == "__main__":
    print("Vultr Resource Retriever - Usage Examples\n")
    print("=" * 60)
    print()
    
    # Run all examples
    try:
        example_basic_usage()
        # example_with_api_key()  # Uncomment and add your API key to test
        example_filter_plans()
        example_find_regions_by_country()
        example_os_by_family()
        example_cheapest_plans()
        example_save_specific_data()
        
        print("=" * 60)
        print("\nAll examples completed successfully!")
        
    except Exception as e:
        print(f"\nError running examples: {e}")
        print("Make sure you have an internet connection and the 'requests' library installed.")
        print("Install with: pip install requests")
