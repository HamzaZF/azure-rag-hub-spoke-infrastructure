import os
from azure.core.credentials import AzureKeyCredential
from azure.search.documents.indexes import SearchIndexClient

# Set your Azure Search service endpoint and API key
endpoint = "https://hub-search-service.search.windows.net"
api_key = os.getenv("AZURE_AI_SEARCH_API_KEY")  # Set via environment variable

try:
    # Create a SearchIndexClient
    client = SearchIndexClient(endpoint, AzureKeyCredential(api_key))
    
    # List all indexes
    indexes = client.list_indexes()
    
    print("✅ SUCCESS! Connected to Azure AI Search")
    print("List of indexes in the Azure Search service:")
    for index in indexes:
        print(f"- {index.name}")
        
except Exception as e:
    print(f"❌ FAILED: {e}")
