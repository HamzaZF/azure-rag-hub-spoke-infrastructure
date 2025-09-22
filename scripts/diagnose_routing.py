# Databricks notebook source
# MAGIC %md
# MAGIC # Databricks Routing Diagnosis
# MAGIC 
# MAGIC This notebook diagnoses why traffic isn't going through the firewall

# COMMAND ----------

import subprocess
import requests
import socket
import json

print("=" * 60)
print("DATABRICKS ROUTING DIAGNOSIS")
print("=" * 60)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. Check Current Network Configuration

# COMMAND ----------

print("1. NETWORK INTERFACE INFORMATION:")
print("-" * 40)

try:
    # Get network interface info
    result = subprocess.run(['ip', 'addr', 'show'], capture_output=True, text=True)
    if result.returncode == 0:
        lines = result.stdout.split('\n')
        for line in lines:
            if 'inet ' in line and '127.0.0.1' not in line:
                print(f"   {line.strip()}")
    else:
        print("   Could not get network interface info")
except Exception as e:
    print(f"   Error: {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2. Check Route Table

# COMMAND ----------

print("\n2. ROUTE TABLE INFORMATION:")
print("-" * 40)

try:
    # Check routing table
    result = subprocess.run(['ip', 'route', 'show'], capture_output=True, text=True)
    if result.returncode == 0:
        print("   Current routes:")
        lines = result.stdout.split('\n')
        for line in lines:
            if line.strip():
                print(f"   {line}")
    else:
        print("   Could not get routing table")
except Exception as e:
    print(f"   Error: {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3. Check Default Gateway

# COMMAND ----------

print("\n3. DEFAULT GATEWAY CHECK:")
print("-" * 40)

try:
    # Check default route
    result = subprocess.run(['ip', 'route', 'show', 'default'], capture_output=True, text=True)
    if result.returncode == 0:
        default_route = result.stdout.strip()
        print(f"   Default route: {default_route}")
        
        # Extract gateway IP
        if 'via' in default_route:
            gateway_ip = default_route.split('via')[1].split()[0]
            print(f"   Gateway IP: {gateway_ip}")
            
            # Expected firewall IPs based on your config
            expected_firewall_ip = "10.0.1.4"  # Based on firewall subnet
            
            if gateway_ip == expected_firewall_ip:
                print(f"   ✅ Gateway matches expected firewall IP: {expected_firewall_ip}")
            else:
                print(f"   ❌ Gateway {gateway_ip} does NOT match expected firewall IP: {expected_firewall_ip}")
                print(f"   🔧 This is likely why traffic bypasses the firewall!")
        else:
            print("   ❌ No gateway found in default route")
    else:
        print("   Could not get default route")
except Exception as e:
    print(f"   Error: {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 4. Test External IP (What Internet Sees)

# COMMAND ----------

print("\n4. EXTERNAL IP TEST:")
print("-" * 40)

try:
    # Get external IP
    response = requests.get('https://api.ipify.org', timeout=10)
    external_ip = response.text.strip()
    print(f"   External IP: {external_ip}")
    
    # Expected firewall public IP (you'll need to update this)
    expected_firewall_public_ip = "UNKNOWN"  # Update this with your firewall's public IP
    
    print(f"   Expected firewall public IP: {expected_firewall_public_ip}")
    
    if external_ip == expected_firewall_public_ip:
        print("   ✅ Traffic IS going through firewall")
    else:
        print("   ❌ Traffic is NOT going through firewall")
        print("   📝 This confirms routing issue")
        
except Exception as e:
    print(f"   Error getting external IP: {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 5. Test Connectivity to Expected Firewall

# COMMAND ----------

print("\n5. FIREWALL CONNECTIVITY TEST:")
print("-" * 40)

firewall_private_ip = "10.0.1.4"  # Expected firewall private IP

try:
    # Test connectivity to firewall
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(5)
    result = sock.connect_ex((firewall_private_ip, 53))  # Test DNS port
    sock.close()
    
    if result == 0:
        print(f"   ✅ Can reach firewall at {firewall_private_ip}:53")
    else:
        print(f"   ❌ Cannot reach firewall at {firewall_private_ip}:53")
        
except Exception as e:
    print(f"   Error testing firewall connectivity: {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 6. DNS Resolution Test

# COMMAND ----------

print("\n6. DNS RESOLUTION TEST:")
print("-" * 40)

test_domains = ["google.com", "microsoft.com", "azure.com"]

for domain in test_domains:
    try:
        ip = socket.gethostbyname(domain)
        print(f"   {domain} -> {ip}")
    except Exception as e:
        print(f"   {domain} -> ERROR: {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 7. Diagnosis Summary

# COMMAND ----------

print("\n" + "=" * 60)
print("DIAGNOSIS SUMMARY")
print("=" * 60)

print("""
ROUTING ISSUE TROUBLESHOOTING:

If default gateway is NOT 10.0.1.4 (firewall IP):
🔧 SOLUTION: Check route table association in Azure Portal
   - Go to Databricks VNet -> Subnets -> Route Tables
   - Verify 'adb-route-table' is associated with both subnets
   - Check route table has 0.0.0.0/0 -> 10.0.1.4

If external IP is NOT your firewall's public IP:
🔧 SOLUTION: Route table is not working
   - Verify firewall is running and has correct private IP
   - Check if route table was applied after subnet creation
   - May need to restart Databricks cluster

COMMON CAUSES:
1. Route table created but not associated with subnets
2. Firewall private IP changed after route table creation
3. Databricks delegated subnet ignoring custom routes
4. Route table has lower priority than system routes

NEXT STEPS:
1. Check Azure Portal for route table associations
2. Verify firewall private IP matches route table
3. Restart Databricks cluster after fixing routes
""")

print("Current Status:")
print("- Network interfaces: Check output above")
print("- Route table: Check if default gateway = 10.0.1.4") 
print("- External IP: Check if matches firewall public IP")
print("- Firewall connectivity: Check if can reach 10.0.1.4") 