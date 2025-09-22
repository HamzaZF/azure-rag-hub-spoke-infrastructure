import requests
import os

# Set your API key
api_key = os.getenv("AZURE_OPENAI_API_KEY")  # Set via environment variable
endpoint = "https://meinhardt-kelix-staging-hub-openai-cog-eastus2-g4n8.openai.azure.com"
deployment_name = "gpt4o-mini"  # Replace with your deployment name

# Simple test
url = f"{endpoint}/openai/deployments/{deployment_name}/chat/completions?api-version=2024-02-01"

headers = {
    "Content-Type": "application/json",
    "api-key": api_key
}

payload = {
    "messages": [{"role": "user", "content": "Hello, are you working?"}],
    "max_tokens": 50
}

try:
    response = requests.post(url, headers=headers, json=payload)
    if response.status_code == 200:
        result = response.json()
        print("✅ SUCCESS!")
        print(f"Response: {result['choices'][0]['message']['content']}")
    else:
        print(f"❌ FAILED: {response.status_code}")
        print(response.text)
except Exception as e:
    print(f"❌ ERROR: {e}")
