# Azure Hub-Spoke Infrastructure for AI and Cloud-Native Applications

![Architecture Diagram](assets/architecture.png)

## Table of Contents

- [Executive Summary](#executive-summary)
- [Architecture Overview](#architecture-overview)
  - [Network Topology](#network-topology)
  - [Hub-Spoke Connectivity](#hub-spoke-connectivity)
  - [Subnet Architecture](#subnet-architecture)
  - [Private DNS Architecture](#private-dns-architecture)
  - [Security Layers](#security-layers)
  - [Traffic Flows](#traffic-flows)
  - [Azure Firewall Configuration](#azure-firewall-configuration)
  - [Architecture Diagram](#architecture-diagram)
- [Configuration](#configuration)
  - [Configuration Files Structure](#configuration-files-structure)
  - [config.tfvars - Non-Sensitive Configuration](#configtfvars---non-sensitive-configuration)
  - [secrets.tfvars - Sensitive Configuration](#secretstfvars---sensitive-configuration)
  - [Setting Up Configuration](#setting-up-configuration)
  - [Important Configuration Notes](#important-configuration-notes)

---

## Executive Summary

This Terraform implementation deploys a **production-grade hub-spoke network architecture on Azure**, designed to provide secure, scalable infrastructure for **AI and cloud-native applications**. The infrastructure offers a robust foundation with Azure OpenAI, AI Search, and data services, ready for application deployment using managed identities and private connectivity.

### What This Infrastructure Provides

The solution implements a **three-network topology** consisting of:
- A **central hub network** that hosts shared AI services (Azure OpenAI, AI Search, PostgreSQL, Blob Storage, Azure Container Registry)
- An **API spoke network** for web applications with Application Gateway ingress and private connectivity
- An **AI spoke network** for containerized workloads running on Azure Container Apps

Azure Firewall serves as a **secure router between spoke networks**, while **Application Gateway handles all inbound traffic** from the internet. All Azure PaaS services are accessed through **private endpoints**, eliminating public internet exposure. The architecture uses **managed identities**, removing the need for credential management.

### Core Capabilities

**Fully Configurable Infrastructure:**
- Network topology (VNet address spaces, subnet ranges, peering configurations)
- Compute resources (VM sizes, OS images, public IP settings)
- Security components (NSG rules, firewall policies, WAF settings)
- Storage accounts (tiers, replication types, network rules)
- AI/ML services (OpenAI models, AI Search tiers, embeddings)
- Database configurations (PostgreSQL versions, storage, authentication)
- Container platform (Apps Environment, workload profiles, scaling)
- Web applications (App Service plans and infrastructure)
- Application Gateway (SSL certificates, routing rules, health probes)
- Managed identities and RBAC assignments
- DNS zones and private endpoint configurations

**Security & Compliance:**
- Zero-trust networking with private endpoints (9+ endpoints across all networks)
- Application Gateway with WAF v2 (OWASP protection, DDoS mitigation)
- Azure Firewall for spoke-to-spoke routing and traffic inspection
- Network Security Groups (NSGs) on all subnets with granular rules
- User-Defined Routes (UDR) for forced tunneling through firewall
- Managed identities (2 user-assigned, multiple system-assigned)
- 20+ RBAC role assignments with least privilege access
- Network isolation with storage account firewall rules (deny by default)
- SSL/TLS termination at Application Gateway
- Minimum TLS 1.2 enforcement across all services
- Key Vault with soft delete and purge protection
- Private DNS zones for all PaaS service resolution
- VNet integration for Web Apps (no public exposure)
- Container Apps with optional mutual TLS
- ACR with private endpoint and no public access

---

## Use Cases

This architecture is ideal for:
- **AI-powered applications** requiring secure access to Azure OpenAI and AI Search
- **Enterprise cloud applications** needing private connectivity to Azure services  
- **Microservices architectures** with containerized workloads
- **Multi-tier applications** requiring network isolation and security
- **Hybrid cloud scenarios** connecting on-premises systems to Azure securely

---

## Architecture Overview

### Network Topology

The infrastructure implements a **hub-spoke network model** with three Virtual Networks (VNets):

| Network | Address Space | Purpose | Resource Group |
|---------|--------------|---------|----------------|
| **Hub VNet** | 10.0.0.0/16 | Shared services, AI resources, and network routing | `{region}-hub-rg` |
| **API Spoke VNet** | 10.1.0.0/16 | Web application delivery and internet ingress | `{region}-api-rg` |
| **AI Spoke VNet** | 10.2.0.0/16 | Container-based AI workloads | `{region}-ai-rg` |

### Hub-Spoke Connectivity

The networks are connected through **bidirectional VNet peering**:
- Hub <-> API Spoke (direct peering)
- Hub <-> AI Spoke (direct peering)
- API Spoke <-> AI Spoke (routed through Azure Firewall in hub)

This design ensures that:
1. **Spoke-to-spoke traffic** is routed through Azure Firewall for inspection and control
2. Shared services in the hub are directly accessible from both spokes
3. Network segmentation is maintained between workload types

### Subnet Architecture

**Hub Network Subnets:**
- `10.0.0.0/24` - Private Endpoints subnet (for all hub PaaS services)
- `10.0.1.0/24` - VM subnet (management jumpbox)
- `10.0.2.0/24` - AzureFirewallSubnet
- `10.0.3.0/24` - Agent VM subnet (additional management)

**API Spoke Subnets:**
- `10.1.0.0/24` - Application Gateway subnet
- `10.1.1.0/24` - Azure App Service subnet for backend (VNet integrated)
- `10.1.2.0/24` - Private Endpoints subnet

**AI Spoke Subnets:**
- `10.2.0.0/23` - Container Apps Environment subnet
- `10.2.2.0/24` - Private Endpoints subnet
- `10.2.3.0/24` - VM subnet (AI workload management)

### Private DNS Architecture

The solution implements **10 Private DNS Zones** for private endpoint resolution:

| DNS Zone | Service | Location | Linked VNets |
|----------|---------|----------|--------------|
| privatelink.blob.core.windows.net | Blob Storage | Hub | Hub, API, AI |
| privatelink.table.core.windows.net | Table Storage | AI Spoke | AI |
| privatelink.openai.azure.com | Azure OpenAI | Hub | Hub, API, AI |
| privatelink.search.windows.net | AI Search | Hub | Hub, API, AI |
| privatelink.postgres.database.azure.com | PostgreSQL | Hub | Hub, API, AI |
| privatelink.azurecr.io | Container Registry | Hub | Hub, API, AI |
| privatelink.azurewebsites.net | Web Apps | API Spoke | API |
| privatelink.vaultcore.azure.net | Key Vault (API) | API Spoke | API |
| privatelink.vaultcore.azure.net | Key Vault (AI) | AI Spoke | AI |
| [Container Apps Domain] | Container Apps Environment | AI Spoke | Hub, API, AI |

Each private endpoint automatically registers its private IP in the corresponding DNS zone, ensuring services resolve to private IPs (10.x.x.x) instead of public endpoints.

### Security Layers

The architecture implements **defense in depth** with multiple security layers:

1. **Network Security**
   - **Application Gateway with WAF v2** for internet ingress and SSL termination
   - **Azure Firewall** for spoke-to-spoke routing and traffic inspection
   - Network Security Groups (NSGs) on all subnets
   - Storage account network rules (deny by default)
   - Private endpoints eliminate public exposure

2. **Identity & Access**

   **User-Assigned Managed Identities (2):**
   - `ai_container_apps_identity` - Used by Container Apps in AI spoke
   - `app_gateway_identity` - Used by Application Gateway for Key Vault access

   **System-Assigned Managed Identities:**
   - **Web App Backend** - System-assigned identity for accessing hub services
   - **Hub VM** - System-assigned identity for management operations

   **RBAC Assignments (20+ roles):**
   - Web App Backend - Blob Storage (Storage Blob Data Contributor)
   - Web App Backend - PostgreSQL (Contributor)
   - Web App Backend - AI Search (Search Service Contributor)
   - Web App Backend - Azure OpenAI (Cognitive Services User)
   - Web App Backend - ACR (AcrPull)
   - Web App Backend - Key Vault (Key Vault Secrets User)
   - Hub VM - All services for management operations
   - Container Apps Identity - All hub services + AI storage + Key Vault
   - App Gateway Identity - (Key Vault Secrets User)

3. **Application Security**
   - **Application Gateway** handles SSL/TLS termination
   - WAF v2 protection against OWASP threats

### Traffic Flows

**Inbound Traffic (Internet to Application):**
```
Internet -> Application Gateway (SSL termination) -> Backend Web App (via private endpoint)
```

**Spoke-to-Spoke Traffic:**
```
API Spoke -> Azure Firewall (hub) -> AI Spoke
```
- Enforced via User-Defined Routes (UDR)
- Firewall network rule allows TCP traffic from API spoke (10.1.0.0/16) to AI spoke (10.2.0.0/16)

**Service Access (via Private Endpoints):**
```
Web Apps/Container Apps -> Private Endpoint -> Azure PaaS Service
```
- All PaaS services accessed through private IPs
- DNS resolution handled by Private DNS Zones

### Azure Firewall Configuration

The Azure Firewall serves as a **secure router** between spokes:
- **Public IP** for outbound SNAT only (not for inbound traffic)
- **Network Rule Collection** "Allow-Spoke-To-Spoke-Traffic"
- Routes enforced via UDR on spoke subnets

### Architecture Diagram

![Architecture Diagram](assets/architecture.png)

---

## Configuration

The infrastructure is fully configurable through two configuration files located in `configuration/terraform/`:

### Configuration Files Structure

| File | Purpose | Git Status |
|------|---------|------------|
| **`config.tfvars`** | Non-sensitive infrastructure configuration | Can be committed | 
| **`secrets.tfvars`** | Sensitive values (passwords, keys, tokens) | Must be in .gitignore | 

### config.tfvars - Non-Sensitive Configuration

This file contains all non-sensitive configuration values organized into sections:

**1. Global Configuration**
- Azure subscription ID
- Naming conventions (company, product, environment, region)
- Resource group names

**2. Network Configuration**
- VNet address spaces (default: 10.0.0.0/16, 10.1.0.0/16, 10.2.0.0/16)
- Subnet CIDR blocks for each network segment
- NSG rules and allowed IP addresses
- Azure Firewall configuration

**3. Compute Resources**
- VM sizes and OS configurations (Ubuntu 22.04 LTS default)
- Public IP settings
- Container Apps scaling (min: 0, max: 3 replicas)
- Web App service plans (B1, P1v2 SKUs)

**4. Azure AI/ML Services**
- OpenAI models (GPT-4, text-embedding-3-small)
- AI Search tiers (standard, with semantic search)
- Custom subdomains and capacities

**5. Storage Configuration**
- Storage account tiers (Standard)
- Replication types (GRS, LRS)
- Container and table storage settings

**6. Database Configuration**
- PostgreSQL version (12) and SKU (GP_Standard_D2s_v3)
- Storage size (32GB) and tier
- Authentication methods (AD + password)

**7. Security Settings**
- WAF policies and rules
- SSL certificate paths
- Allowed SSH sources
- Container registry settings

**8. Infrastructure Integration**
- SSL certificate configuration
- Managed identity assignments
- Resource naming conventions

### secrets.tfvars - Sensitive Configuration

This file contains all sensitive values that must never be committed to version control:

**Required Sensitive Values:**
- VM administrator passwords (hub, agent, AI spoke VMs)
- PostgreSQL administrator password
- SSL certificate passwords for Application Gateway

**Example Structure:**
```hcl
# Infrastructure Authentication
hub_vm_admin_password = "YourSecurePassword123!"
hub_postgresql_admin_password = "DatabasePassword456!"
spoke_api_ag_ssl_certificate_password = "CertificatePassword789!"
```

---

## Prerequisites

Before deploying this infrastructure, ensure you have:

### **Required Tools**
- **Terraform** >= 1.9.0 ([Download](https://terraform.io/downloads.html))
- **Azure CLI** >= 2.50.0 ([Install Guide](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli))

### **Azure Requirements**
- Valid Azure subscription with sufficient credits
- Service Principal or User Account with following permissions:
  - `Contributor` role on target subscription
  - `User Access Administrator` role (for RBAC assignments)
  - `Azure AD Directory Readers` role (for managed identity operations)

### **Resource Quotas**
Verify your subscription has sufficient quotas:
- **Compute**: 10+ vCPUs for VMs and Container Apps
- **Networking**: 3 Virtual Networks, 1 Application Gateway, 1 Azure Firewall
- **Storage**: 2 Storage Accounts
- **AI Services**: Azure OpenAI, AI Search (check regional availability)

---

## Installation & Deployment

### **Step 1: Environment Setup**

1. **Clone and navigate to the project:**
   ```bash
   git clone <repository-url>
   cd azure-rag-hub-spoke-infrastructure
   ```

2. **Authenticate with Azure:**
   ```bash
   az login
   az account set --subscription "your-subscription-id"
   ```

3. **Verify Azure permissions:**
   ```bash
   az role assignment list --assignee $(az account show --query user.name -o tsv) --scope "/subscriptions/$(az account show --query id -o tsv)"
   ```

### **Step 2: Configuration Setup**

1. **Create configuration files:**
   ```bash
   # Copy template files
   cp configuration/terraform/config.tfvars.example configuration/terraform/config.tfvars
   cp configuration/terraform/secrets.tfvars.example configuration/terraform/secrets.tfvars
   ```

2. **Edit non-sensitive configuration:**
   ```bash
   # Update with your specific values
   nano configuration/terraform/config.tfvars
   ```
   
   **Key values to update:**
   - `subscription_id` - Your Azure subscription ID
   - `naming_company` - Your organization name
   - `hub_location` - Your preferred Azure region
   - `hub_openai_custom_subdomain` - Globally unique OpenAI subdomain
   - Network addressing (VNet/subnet CIDR blocks)
   - VM sizes and compute configurations

3. **Configure sensitive values:**
   ```bash
   # IMPORTANT: Keep this file secure and never commit to git
   nano configuration/terraform/secrets.tfvars
   ```
   
   **Required sensitive values:**
   - VM administrator passwords
   - PostgreSQL administrator password  
   - SSL certificate password (if using custom certificates)

### **Step 3: SSL Certificate Setup**

You must provide your own SSL certificate in PFX format. Place it in the `ssl_certs/` directory:

```bash
# Ensure ssl_certs directory exists
mkdir -p ssl_certs

# Place your PFX certificate file (you must provide this)
cp your-certificate.pfx ssl_certs/ssl_cert.pfx
```

**📋 See `ssl_certs/README.md` for detailed certificate requirements and sources.**

### **Step 4: Terraform Deployment**

1. **Initialize Terraform:**
   ```bash
   terraform init
   ```

2. **Validate configuration:**
   ```bash
   terraform validate
   terraform fmt
   ```

3. **Review deployment plan:**
   ```bash
   terraform plan \
     -var-file="configuration/terraform/config.tfvars" \
     -var-file="configuration/terraform/secrets.tfvars"
   ```

4. **Deploy infrastructure:**
   ```bash
   terraform apply \
     -var-file="configuration/terraform/config.tfvars" \
     -var-file="configuration/terraform/secrets.tfvars"
   ```

   **Deployment time:** ~10 minutes for complete infrastructure

### **Step 5: Post-Deployment Configuration**

After infrastructure deployment, configure PostgreSQL managed identity access by running the setup script on the hub VM (jump box):

```bash
# SSH to hub VM
ssh vmadmin@<hub-vm-ip>

# Copy script to hub VM and set execute permissions
chmod +x configuration/pgsql/init_pgsql_script.sh

# Run the PostgreSQL managed identity setup script
./configuration/pgsql/init_pgsql_script.sh
```

See `configuration/pgsql/README.md` for detailed instructions and troubleshooting.

---

## Configuration Management

### **Environment-Specific Configurations**

For multiple environments, create separate tfvars files:

```bash
# Development
configuration/terraform/dev.tfvars
configuration/terraform/dev-secrets.tfvars

# Production  
configuration/terraform/prod.tfvars
configuration/terraform/prod-secrets.tfvars
```

Deploy with environment-specific configs:
```bash
terraform apply -var-file="configuration/terraform/prod.tfvars" -var-file="configuration/terraform/prod-secrets.tfvars"
```

### **Key Configuration Sections**

| Configuration Area | File Location | Description |
|-------------------|---------------|-------------|
| **Network Topology** | `config.tfvars` | VNet addressing, subnet allocation |
| **Compute Resources** | `config.tfvars` | VM sizes, Container Apps scaling |
| **AI/ML Services** | `config.tfvars` | OpenAI models, AI Search configuration |
| **Security Settings** | `config.tfvars` | WAF rules, allowed IP ranges |
| **Sensitive Data** | `secrets.tfvars` | VM passwords, SSL certificates |
| **PostgreSQL Setup** | `configuration/pgsql/` | Managed identity database access configuration |

---

## Management & Operations

### **Common Operations**

**Scale Container Apps:**
```bash
# Update max_replicas in config.tfvars, then:
terraform apply -var-file="configuration/terraform/config.tfvars" -var-file="configuration/terraform/secrets.tfvars" -target=module.spoke_ai
```

**Update OpenAI Models:**
```bash
# Modify OpenAI configuration in config.tfvars, then:
terraform apply -var-file="configuration/terraform/config.tfvars" -var-file="configuration/terraform/secrets.tfvars" -target=module.hub.module.openai
```

**Rotate Secrets:**
```bash
# Update secrets.tfvars with new values, then:
terraform apply -var-file="configuration/terraform/config.tfvars" -var-file="configuration/terraform/secrets.tfvars"
```

### **Monitoring & Troubleshooting**

**View Application Gateway Logs:**
```bash
az monitor activity-log list --resource-group $(terraform output -raw spoke_api_resource_group_name)
```

**Check Private Endpoint Connectivity:**
```bash
# Use Azure CLI or portal to verify private endpoint connectivity
az network private-endpoint show --name <endpoint-name> --resource-group <rg-name>
```

**PostgreSQL Connection Test:**
```bash
# Test from hub VM using psql
psql -h <postgresql-server>.postgres.database.azure.com -U <username> -d postgres
```

---

## Cleanup

To destroy the infrastructure:

```bash
# CAUTION: This will delete ALL resources
terraform destroy \
  -var-file="configuration/terraform/config.tfvars" \
  -var-file="configuration/terraform/secrets.tfvars"
```

**Note:** Some resources may require manual cleanup:
- Key Vault (if purge protection is enabled)
- Storage account containers with retention policies
- Azure AD applications (if any were created manually)

---

## Architecture Validation

The infrastructure can be validated using Azure CLI commands and portal monitoring:

| Component | Validation Method | Usage |
|-----------|------------------|-------|
| **Blob Storage** | Azure CLI connectivity test | `az storage account show --name <storage-account>` |
| **PostgreSQL** | Connection test from hub VM | `psql -h <server>.postgres.database.azure.com -U <user>` |
| **AI Search** | Service status check | `az search service show --name <service-name>` |
| **OpenAI** | Service availability | `az cognitiveservices account show --name <openai-name>` |
| **Network Routing** | Route table verification | `az network route-table show --name <route-table>` |
| **Application Gateway** | Health probe status | `az network application-gateway show --name <ag-name>` |

---

## Security Considerations

### **Network Security**
- All PaaS services accessible only via private endpoints
- Azure Firewall controls spoke-to-spoke traffic
- NSGs provide subnet-level security
- Application Gateway with WAF v2 protects internet-facing services

### **Identity & Access**
- Managed identities eliminate credential management for applications
- RBAC follows principle of least privilege
- Key Vault infrastructure for secure secret storage
- Azure AD integration for PostgreSQL authentication

### **Data Protection**
- Storage accounts deny public access by default
- Minimum TLS 1.2 enforced across all services
- Private DNS zones prevent DNS hijacking
- Container registry isolated from public internet

---

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Test your changes thoroughly
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

---

## Support

For infrastructure questions or issues:
- Create an issue in this repository
- Include Terraform version and error details
- Provide relevant infrastructure configuration (without sensitive data)
- Applications should be deployed separately using the managed identities and outputs provided by this infrastructure
