import urllib.parse
import os

from azure.identity import DefaultAzureCredential

# IMPORTANT! This code is for demonstration purposes only. It's not suitable for use in production. 
# For example, tokens issued by Microsoft Entra ID have a limited lifetime (24 hours by default). 
# In production code, you need to implement a token refresh policy.

def get_connection_uri():

    # Read URI parameters from the environment
    dbhost = "meinhardt-kelix-psql-sea.postgres.database.azure.com"
    dbname = "postgres"#postgres
    dbuser = "meinhardt-kelix" #meinhardt-kelix
    sslmode = "require" #require

    # Use passwordless authentication via DefaultAzureCredential.
    # IMPORTANT! This code is for demonstration purposes only. DefaultAzureCredential() is invoked on every call.
    # In practice, it's better to persist the credential across calls and reuse it so you can take advantage of token
    # caching and minimize round trips to the identity provider. To learn more, see:
    # https://github.com/Azure/azure-sdk-for-python/blob/main/sdk/identity/azure-identity/TOKEN_CACHING.md 
    credential = DefaultAzureCredential()

    # Call get_token() to get a token from Microsft Entra ID and add it as the password in the URI.
    # Note the requested scope parameter in the call to get_token, "https://ossrdbms-aad.database.windows.net/.default".
    password = credential.get_token("https://ossrdbms-aad.database.windows.net/.default").token

    db_uri = f"postgresql://{dbuser}:{password}@{dbhost}/{dbname}?sslmode={sslmode}"
    return db_uri

def main():
    try:
        print("Starting PostgreSQL managed identity test...")
        db_uri = get_connection_uri()
        print("✅ Successfully got connection URI!")
        print(f"Connection URI: {db_uri[:50]}...{db_uri[-20:]}")  # Print partial URI for security
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    main()
