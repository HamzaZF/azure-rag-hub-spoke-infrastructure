# Databricks notebook source
# MAGIC %md
# MAGIC # Databricks Network Connectivity and Table Storage Access Test
# MAGIC 
# MAGIC This notebook tests:
# MAGIC 1. Network connectivity through Azure Firewall
# MAGIC 2. Access to Table Storage via private endpoint
# MAGIC 3. Outbound connectivity rules
# MAGIC 4. DNS resolution for private endpoints

# COMMAND ----------

# MAGIC %md
# MAGIC ## 1. Install Required Libraries

# COMMAND ----------

# Install required packages
%pip install azure-data-tables azure-identity requests dnspython

# COMMAND ----------

# MAGIC %md
# MAGIC ## 2. Import Libraries and Setup

# COMMAND ----------

import requests
import socket
import dns.resolver
import subprocess
import json
from azure.data.tables import TableServiceClient
from azure.identity import DefaultAzureCredential
from datetime import datetime
import time

# Test configuration - Update these values based on your Terraform outputs
TABLE_STORAGE_ACCOUNT = "meinhardtkelixdatabricks"  # Your table storage account name
TABLE_STORAGE_ENDPOINT = f"https://{TABLE_STORAGE_ACCOUNT}.table.core.windows.net"
FIREWALL_IP = "10.0.1.4"  # Your Azure Firewall private IP

# COMMAND ----------

# MAGIC %md
# MAGIC ## 3. Network Connectivity Tests

# COMMAND ----------

def test_dns_resolution(hostname):
    """Test DNS resolution for a hostname."""
    try:
        ip = socket.gethostbyname(hostname)
        print(f"✅ DNS Resolution: {hostname} -> {ip}")
        return ip
    except Exception as e:
        print(f"❌ DNS Resolution failed for {hostname}: {e}")
        return None

def test_port_connectivity(host, port, timeout=5):
    """Test TCP connectivity to a host:port."""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(timeout)
        result = sock.connect_ex((host, port))
        sock.close()
        
        if result == 0:
            print(f"✅ Port connectivity: {host}:{port} - SUCCESS")
            return True
        else:
            print(f"❌ Port connectivity: {host}:{port} - FAILED")
            return False
    except Exception as e:
        print(f"❌ Port connectivity error for {host}:{port}: {e}")
        return False

def test_http_connectivity(url, timeout=10):
    """Test HTTP/HTTPS connectivity."""
    try:
        response = requests.get(url, timeout=timeout, verify=False)
        print(f"✅ HTTP connectivity: {url} - Status: {response.status_code}")
        return True
    except Exception as e:
        print(f"❌ HTTP connectivity failed for {url}: {e}")
        return False

# COMMAND ----------

# MAGIC %md
# MAGIC ## 4. Test Basic Network Connectivity

# COMMAND ----------

print("=" * 60)
print("NETWORK CONNECTIVITY TESTS")
print("=" * 60)

# Test DNS resolution for key services
test_hostnames = [
    f"{TABLE_STORAGE_ACCOUNT}.table.core.windows.net",
    "login.microsoftonline.com",
    "management.azure.com",
    "storage.azure.com"
]

print("\n1. DNS Resolution Tests:")
print("-" * 30)
for hostname in test_hostnames:
    test_dns_resolution(hostname)

# Test connectivity to Azure services
print("\n2. Port Connectivity Tests:")
print("-" * 30)
test_port_connectivity(f"{TABLE_STORAGE_ACCOUNT}.table.core.windows.net", 443)
test_port_connectivity("login.microsoftonline.com", 443)

# Test HTTP connectivity
print("\n3. HTTP Connectivity Tests:")
print("-" * 30)
test_http_connectivity("https://login.microsoftonline.com")
test_http_connectivity(f"https://{TABLE_STORAGE_ACCOUNT}.table.core.windows.net")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 5. Test Firewall Outbound Rules

# COMMAND ----------

print("=" * 60)
print("FIREWALL OUTBOUND RULES TESTS")
print("=" * 60)

# Test connectivity to required Azure services (should go through firewall)
firewall_test_urls = [
    "https://login.microsoftonline.com",
    "https://management.azure.com",
    "https://storage.azure.com",
    f"https://{TABLE_STORAGE_ACCOUNT}.table.core.windows.net",
    "https://graph.microsoft.com"
]

print("\nTesting outbound connectivity through Azure Firewall:")
print("-" * 50)

for url in firewall_test_urls:
    try:
        start_time = time.time()
        response = requests.get(url, timeout=10, verify=False)
        end_time = time.time()
        response_time = round((end_time - start_time) * 1000, 2)
        
        print(f"✅ {url}")
        print(f"   Status: {response.status_code}, Response Time: {response_time}ms")
    except Exception as e:
        print(f"❌ {url}")
        print(f"   Error: {str(e)}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 6. Test Azure Managed Identity

# COMMAND ----------

print("=" * 60)
print("AZURE MANAGED IDENTITY TESTS")
print("=" * 60)

try:
    # Test managed identity authentication
    print("Testing Databricks managed identity authentication...")
    credential = DefaultAzureCredential()
    
    # Get token for Azure Storage
    token = credential.get_token("https://storage.azure.com/.default")
    print(f"✅ Successfully acquired Azure Storage token")
    print(f"   Token expires: {datetime.fromtimestamp(token.expires_on)}")
    
    # Get token for Azure Resource Manager
    arm_token = credential.get_token("https://management.azure.com/.default")
    print(f"✅ Successfully acquired ARM token")
    print(f"   Token expires: {datetime.fromtimestamp(arm_token.expires_on)}")
    
except Exception as e:
    print(f"❌ Managed identity authentication failed: {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 7. Test Table Storage Access

# COMMAND ----------

print("=" * 60)
print("TABLE STORAGE ACCESS TESTS")
print("=" * 60)

try:
    # Initialize Table Service Client with managed identity
    print(f"Connecting to Table Storage: {TABLE_STORAGE_ENDPOINT}")
    credential = DefaultAzureCredential()
    table_service_client = TableServiceClient(
        endpoint=TABLE_STORAGE_ENDPOINT,
        credential=credential
    )
    
    # Test listing tables
    print("Testing table listing...")
    tables = list(table_service_client.list_tables())
    print(f"✅ Successfully connected to Table Storage")
    print(f"   Found {len(tables)} tables:")
    for table in tables[:5]:  # Show first 5 tables
        print(f"   - {table.name}")
    
    # Test creating a test table
    test_table_name = "databricks_connectivity_test"
    print(f"\nTesting table operations with '{test_table_name}'...")
    
    try:
        # Create table client
        table_client = table_service_client.get_table_client(table_name=test_table_name)
        
        # Create table if it doesn't exist
        table_client.create_table()
        print(f"✅ Created/confirmed table: {test_table_name}")
        
        # Insert a test entity
        test_entity = {
            'PartitionKey': 'test',
            'RowKey': f'databricks_test_{int(time.time())}',
            'Message': 'Connectivity test from Databricks',
            'Timestamp': datetime.now().isoformat(),
            'Source': 'Databricks Workspace'
        }
        
        table_client.create_entity(entity=test_entity)
        print(f"✅ Successfully inserted test entity")
        
        # Query the entity back
        entities = list(table_client.query_entities(query_filter="PartitionKey eq 'test'"))
        print(f"✅ Successfully queried entities: {len(entities)} found")
        
        # Show latest entity
        if entities:
            latest_entity = max(entities, key=lambda x: x['Timestamp'])
            print(f"   Latest entity: {latest_entity['RowKey']} - {latest_entity['Message']}")
        
    except Exception as table_error:
        print(f"⚠️  Table operations error: {table_error}")
    
except Exception as e:
    print(f"❌ Table Storage connection failed: {e}")
    print("This might indicate:")
    print("   - Private endpoint connectivity issues")
    print("   - Managed identity permission issues")
    print("   - Firewall rule blocking storage access")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 8. Test Network Routes and Firewall

# COMMAND ----------

print("=" * 60)
print("NETWORK ROUTING TESTS")
print("=" * 60)

# Test if traffic is going through the firewall
print("Testing network routing through Azure Firewall...")

try:
    # Check routing by testing connectivity to firewall IP
    print(f"Testing connectivity to Azure Firewall: {FIREWALL_IP}")
    
    # Test ICMP (ping) - might be blocked
    try:
        result = subprocess.run(['ping', '-c', '1', FIREWALL_IP], 
                              capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            print(f"✅ Ping to firewall successful")
        else:
            print(f"⚠️  Ping to firewall failed (expected - ICMP might be blocked)")
    except:
        print(f"⚠️  Ping test failed (expected - ICMP might be blocked)")
    
    # Test if we can resolve the firewall IP
    test_port_connectivity(FIREWALL_IP, 53)  # DNS
    
    # Get current IP and routing info
    try:
        # Get external IP (what the internet sees)
        external_ip_response = requests.get('https://api.ipify.org', timeout=5)
        external_ip = external_ip_response.text
        print(f"✅ External IP: {external_ip}")
    except:
        print("⚠️  Could not determine external IP")
    
except Exception as e:
    print(f"❌ Network routing test error: {e}")

# COMMAND ----------

# MAGIC %md
# MAGIC ## 9. Summary Report

# COMMAND ----------

print("=" * 60)
print("CONNECTIVITY TEST SUMMARY")
print("=" * 60)

summary = {
    "Test Date": datetime.now().isoformat(),
    "Databricks Cluster": "Active",
    "Tests Performed": [
        "DNS Resolution",
        "Port Connectivity", 
        "HTTP Connectivity",
        "Firewall Outbound Rules",
        "Managed Identity Authentication",
        "Table Storage Access",
        "Network Routing"
    ]
}

print(f"Test completed at: {summary['Test Date']}")
print("\nKey Findings:")
print("- DNS resolution for Azure services")
print("- HTTPS connectivity through firewall")
print("- Managed identity authentication")
print("- Table Storage access via private endpoint")
print("- Network routing through Azure Firewall")

print("\n" + "=" * 60)
print("If all tests passed:")
print("✅ Databricks can access Table Storage through private endpoint")
print("✅ Outbound traffic is properly routed through Azure Firewall")
print("✅ Network Security Group rules are correctly configured")
print("✅ Managed identity has proper permissions")

print("\nIf tests failed, check:")
print("- NSG rules allow outbound HTTPS (443)")
print("- Azure Firewall application rules")
print("- Private endpoint DNS configuration")
print("- Managed identity role assignments")
print("=" * 60)

# COMMAND ----------

# MAGIC %md
# MAGIC ## 10. Optional: Detailed Network Diagnostics

# COMMAND ----------

# Optional: More detailed network diagnostics
print("=" * 60)
print("DETAILED NETWORK DIAGNOSTICS")
print("=" * 60)

try:
    # Get network interface information
    import subprocess
    
    print("Network interface information:")
    result = subprocess.run(['ifconfig'], capture_output=True, text=True)
    if result.returncode == 0:
        lines = result.stdout.split('\n')[:20]  # First 20 lines
        for line in lines:
            if line.strip():
                print(f"  {line}")
    
    print("\nRoute table information:")
    result = subprocess.run(['route', '-n'], capture_output=True, text=True)
    if result.returncode == 0:
        lines = result.stdout.split('\n')[:10]  # First 10 lines
        for line in lines:
            if line.strip():
                print(f"  {line}")
                
except Exception as e:
    print(f"Could not get detailed network info: {e}")

print("\nTest completed! Review the results above.") 