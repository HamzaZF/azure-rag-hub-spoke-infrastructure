#!/usr/bin/env python3
"""
Application Gateway Test Script

This script tests the connectivity from Application Gateway to the private Web App.
It should be run from a machine that can reach the Application Gateway's public IP.
"""

import requests
import sys
import time

def test_application_gateway(ag_public_ip, timeout=30):
    """
    Test Application Gateway connectivity to the private Web App.
    
    Args:
        ag_public_ip (str): The public IP address of the Application Gateway
        timeout (int): Request timeout in seconds
    """
    
    url = f"http://{ag_public_ip}"
    
    print(f"🔍 Testing Application Gateway connectivity...")
    print(f"   URL: {url}")
    print(f"   Timeout: {timeout} seconds")
    print()
    
    try:
        # Test HTTP connectivity
        print("📡 Sending HTTP request to Application Gateway...")
        response = requests.get(url, timeout=timeout, allow_redirects=True)
        
        print(f"✅ SUCCESS! Application Gateway is reachable")
        print(f"   Status Code: {response.status_code}")
        print(f"   Response Time: {response.elapsed.total_seconds():.2f} seconds")
        print(f"   Content Length: {len(response.content)} bytes")
        
        # Check if we got a response from the Web App
        if response.status_code == 200:
            print("✅ Web App is responding through Application Gateway")
        elif response.status_code == 404:
            print("⚠️  Web App is reachable but returned 404 (no content)")
        else:
            print(f"⚠️  Web App returned status code: {response.status_code}")
            
    except requests.exceptions.ConnectionError as e:
        print(f"❌ CONNECTION ERROR: Cannot connect to Application Gateway")
        print(f"   Error: {e}")
        print()
        print("🔧 Troubleshooting steps:")
        print("   1. Verify Application Gateway is deployed and running")
        print("   2. Check if the public IP is correct")
        print("   3. Ensure firewall rules allow HTTP traffic (port 80)")
        print("   4. Verify VNet integration is configured on the Web App")
        return False
        
    except requests.exceptions.Timeout as e:
        print(f"❌ TIMEOUT ERROR: Request timed out after {timeout} seconds")
        print(f"   Error: {e}")
        print()
        print("🔧 Troubleshooting steps:")
        print("   1. Check Application Gateway health")
        print("   2. Verify backend pool configuration")
        print("   3. Check Web App VNet integration")
        return False
        
    except Exception as e:
        print(f"❌ UNEXPECTED ERROR: {e}")
        return False
    
    return True

def main():
    """Main function to run the test."""
    
    print("🚀 Application Gateway to Private Web App Connectivity Test")
    print("=" * 60)
    print()
    
    # Get Application Gateway public IP from user
    if len(sys.argv) > 1:
        ag_public_ip = sys.argv[1]
    else:
        ag_public_ip = input("Enter Application Gateway public IP: ").strip()
    
    if not ag_public_ip:
        print("❌ Error: Application Gateway public IP is required")
        sys.exit(1)
    
    print(f"🎯 Target: {ag_public_ip}")
    print()
    
    # Run the test
    success = test_application_gateway(ag_public_ip)
    
    print()
    if success:
        print("🎉 Test completed successfully!")
        print("   The Application Gateway can reach your private Web App.")
    else:
        print("💥 Test failed!")
        print("   Check the troubleshooting steps above.")
        sys.exit(1)

if __name__ == "__main__":
    main() 