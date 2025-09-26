# PostgreSQL Managed Identity Setup Script

## Overview

This directory contains a post-deployment script that enables **Azure App Service backend** to connect to **Azure Database for PostgreSQL** using **managed identity authentication**. The script must be executed from the **hub VM (jump box)** which serves as the Entra ID administrator for the PostgreSQL database.

## Purpose

The script (`init_pgsql_script.sh`) automates the process of creating a PostgreSQL database principal for the App Service's system-assigned managed identity, enabling secure, passwordless database connections.

## Architecture Context

```
Hub VM (Entra Admin) → PostgreSQL Database
                    ↓ (Creates principal for)
                   App Service Managed Identity
```

- **Hub VM**: Acts as PostgreSQL Entra ID administrator
- **App Service**: Backend web application with system-assigned managed identity
- **PostgreSQL**: Azure Database for PostgreSQL with Azure AD authentication enabled

## How It Works

### Step-by-Step Process:

1. **Service Discovery**: Automatically finds PostgreSQL server and App Service resources
2. **Azure AD Authentication**: Uses hub VM's managed identity to get access token
3. **Database Connection**: Connects to PostgreSQL as Entra ID administrator
4. **Principal Creation**: Creates database principal for App Service managed identity
5. **Permission Assignment**: Grants necessary database access permissions

### Key Functions:

- **`pgaadauth_create_principal()`**: PostgreSQL function that creates Azure AD principals
- **Metadata Service**: Azure Instance Metadata Service for token acquisition
- **Automatic Fallback**: Tries multiple methods to identify the managed identity

## Prerequisites

### Required Tools on Hub VM:
- `az` (Azure CLI)
- `psql` (PostgreSQL client)
- `jq` (JSON processor)
- `curl` (for metadata service access)

## Execution Instructions

### 1. Connect to Hub VM

```bash
# SSH to the hub VM (jump box)
ssh vmadmin@<hub-vm-ip>
```

### 2. Install Prerequisites (if not already installed)

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install PostgreSQL client
sudo apt-get update
sudo apt-get install postgresql-client

# Install jq
sudo apt-get install jq
```

### 3. Authenticate Azure CLI

```bash
# Login using the VM's managed identity
az login --identity
```

### 4. Execute the Script

```bash
# Copy the script to the VM and make executable
chmod +x init_pgsql_script.txt

# Run the script
./init_pgsql_script.txt
```

## Security Considerations

### Authentication Flow:
1. **Hub VM** → Azure AD Token (using managed identity)
2. **Hub VM** → PostgreSQL (as Entra ID administrator)
3. **App Service** → PostgreSQL (using created principal)

### Security Benefits:
- **No hardcoded credentials** in application code
- **Automatic token refresh** handled by Azure
- **Centralized access management** through Azure AD
- **Principle of least privilege** with specific database permissions

## References

- [Azure App Service Managed Identity](https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity)
- [PostgreSQL Azure AD Authentication](https://docs.microsoft.com/en-us/azure/postgresql/flexible-server/how-to-configure-sign-in-aad-authentication)
- [Connect App Service to PostgreSQL with Managed Identity](https://docs.microsoft.com/en-us/azure/app-service/tutorial-connect-msi-azure-database?tabs=postgresql-sc)

## 🛠️ Maintenance

### Regular Tasks:
- **Monitor access logs** in PostgreSQL and Azure AD
- **Update permissions** when application requirements change

---

**Note**: This script is a **one-time setup** requirement after infrastructure deployment. It bridges the gap between infrastructure provisioning and application connectivity, enabling secure, managed identity-based database access.