import os
from azure.storage.blob import BlobServiceClient

# Your storage account connection string
connection_string = os.getenv("AZURE_STORAGE_CONNECTION_STRING")  # Set via environment variable

try:
    # Create BlobServiceClient
    blob_service_client = BlobServiceClient.from_connection_string(connection_string)
    
    # Simple connectivity test - list containers
    containers = list(blob_service_client.list_containers())
    
    print("✅ SUCCESS! Connected to Azure Blob Storage")
    print(f"Found {len(containers)} containers:")
    for container in containers:
        print(f"  - {container.name}")
        
except Exception as e:
    print(f"❌ FAILED: {e}")
