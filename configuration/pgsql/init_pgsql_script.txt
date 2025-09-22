#!/bin/bash
set -euo pipefail
set -x

# -----------------------------
# Step 1: Get server info
# -----------------------------
SERVER_INFO=$(az postgres flexible-server list --query '[0].{name:name,resourceGroup:resourceGroup, fqdn:fullyQualifiedDomainName}' -o json)
SERVER_NAME=$(echo "$SERVER_INFO" | jq -r '.name')
SERVER_RG=$(echo "$SERVER_INFO" | jq -r '.resourceGroup')
SERVER_FQDN=$(echo "$SERVER_INFO" | jq -r '.fqdn')

echo "PostgreSQL Server: $SERVER_NAME in $SERVER_RG"

# -----------------------------
# Step 2: Get Azure AD token
# -----------------------------
PGTOKEN=$(curl -s "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://ossrdbms-aad.database.windows.net" -H Metadata:true | jq -r .access_token)

if [ -z "$PGTOKEN" ]; then
    echo "ERROR: Failed to get Azure AD token" >&2
    exit 1
fi

# -----------------------------
# Step 3: Use Managed Identity as user
# -----------------------------
PGUSER=$(az postgres flexible-server microsoft-entra-admin list --resource-group "$SERVER_RG" --server-name "$SERVER_NAME" -o json | jq -r '.[0].principalName')
DB_NAME="postgres"  # use default database

if [ -z "$PGUSER" ] || [ "$PGUSER" == "null" ]; then
    echo "ERROR: No Microsoft Entra admin found for PostgreSQL server" >&2
    exit 1
fi

# -----------------------------
# Step 4: Connect to PostgreSQL
# -----------------------------
export PGHOST="$SERVER_FQDN"
export PGDATABASE="$DB_NAME"
export PGUSER="$PGUSER"
export PGPASSWORD="$PGTOKEN"
export PGSSLMODE="require"

echo "Connecting to PostgreSQL at $PGHOST, database $PGDATABASE, user $PGUSER..."

psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT version();" || {
    echo "ERROR: PostgreSQL connection failed" >&2
    exit 1
}

echo "✅ PostgreSQL connection successful!"

# -----------------------------
# Step 5: Find backend app's managed identity
# -----------------------------
API_RG=$(az group list --query '[?contains(name, `api`)].name | [0]' -o tsv)

if [ -z "$API_RG" ]; then
    echo "ERROR: API resource group not found" >&2
    exit 1
fi

BACKEND_APP=$(az webapp list --resource-group "$API_RG" --query '[?contains(name, `backend`)].name | [0]' -o tsv)

if [ -z "$BACKEND_APP" ]; then
    echo "ERROR: Backend App Service not found" >&2
    exit 1
fi

MI_PRINCIPAL_ID=$(az webapp identity show --resource-group "$API_RG" --name "$BACKEND_APP" --query principalId -o tsv)

if [ -z "$MI_PRINCIPAL_ID" ]; then
    echo "ERROR: Managed Identity for backend app not found" >&2
    exit 1
fi

echo "Found App Service $BACKEND_APP with Managed Identity $MI_PRINCIPAL_ID"

# -----------------------------
# Step 6: Create AAD principal in PostgreSQL using display name
# -----------------------------
echo "Creating AAD principal in PostgreSQL..."

# Method 1: Try using the App Service name (most common for system-assigned MI)
psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT * FROM pgaadauth_create_principal('$BACKEND_APP', false, false);" && {
    echo "✅ AAD principal created successfully using App Service name!"
    exit 0
}

echo "App Service name failed, trying to get display name from Microsoft Graph..."

# Method 2: Get the actual display name from Microsoft Graph
MI_DISPLAY_NAME=$(az ad sp show --id "$MI_PRINCIPAL_ID" --query displayName -o tsv 2>/dev/null)

if [ -n "$MI_DISPLAY_NAME" ] && [ "$MI_DISPLAY_NAME" != "null" ]; then
    echo "Found display name: $MI_DISPLAY_NAME"
    psql -h "$PGHOST" -U "$PGUSER" -d "$PGDATABASE" -c "SELECT * FROM pgaadauth_create_principal('$MI_DISPLAY_NAME', false, false);" && {
        echo "✅ AAD principal created successfully using display name!"
        exit 0
    }
fi

echo "ERROR: Failed to create AAD principal using both App Service name and display name" >&2
echo "Managed Identity details:"
echo "  - App Service: $BACKEND_APP"
echo "  - Principal ID: $MI_PRINCIPAL_ID"
echo "  - Display Name: ${MI_DISPLAY_NAME:-'Not found'}"
echo ""
echo "Try creating the principal manually in PostgreSQL:"
echo "SELECT * FROM pgaadauth_create_principal('$BACKEND_APP', false, false);"
exit 1
