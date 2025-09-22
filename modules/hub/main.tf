/*
  main.tf - Hub Module Configuration
  
  This file orchestrates the deployment of all core hub resources for the Kelix Azure
  environment, including networking, compute, storage, AI services, and database
  infrastructure with comprehensive security controls.
  
  Hub Components:
  - Core networking infrastructure with private endpoints
  - Virtual machine for management and testing
  - Blob storage for data persistence
  - OpenAI services for AI capabilities
  - Azure AI Search for intelligent search
  - PostgreSQL database for structured data
  - Managed identity-based RBAC for secure access
*/

# =============================================================================
# NAMING
# =============================================================================
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix = [var.naming_region]
}

# =============================================================================
# RESOURCE GROUP REFERENCE
# =============================================================================
# Using pre-created resource group from main.tf to avoid circular dependencies

locals {
  resource_group_name = var.hub_resource_group_name
}

# =============================================================================
# NETWORKING INFRASTRUCTURE
# =============================================================================
# Core networking with VNet, subnets, and network security groups

module "networking" {
  source = "./modules/networking"

  # Resource Group and Location Configuration
  hub_networking_resource_group_name = local.resource_group_name
  hub_networking_location            = var.hub_location

  # Virtual Network Configuration
  hub_networking_vnet_address_space = var.hub_vnet_address_space
  hub_networking_pe_subnet_prefix   = var.hub_pe_subnet_prefix
  hub_networking_vm_subnet_prefix   = var.hub_vm_subnet_prefix
  hub_networking_azure_firewall_subnet_prefix = var.hub_azure_firewall_subnet_prefix

  # Security Configuration
  hub_allowed_ssh_sources  = var.hub_allowed_ssh_sources

  # Cross-Module Configuration
  spoke_api_networking_pe_subnet_prefix     = var.spoke_api_networking_pe_subnet_prefix
  spoke_ai_networking_pe_subnet_prefix      = var.spoke_ai_networking_pe_subnet_prefix
  spoke_ai_networking_cappenv_subnet_prefix = var.spoke_ai_networking_cappenv_subnet_prefix

  # Random Suffix Configuration - NSG PE
  hub_networking_nsg_pe_random_suffix_length  = 4
  hub_networking_nsg_pe_random_suffix_special = false
  hub_networking_nsg_pe_random_suffix_upper   = false

  # Random Suffix Configuration - NSG VM
  hub_networking_nsg_vm_random_suffix_length  = 4
  hub_networking_nsg_vm_random_suffix_special = false
  hub_networking_nsg_vm_random_suffix_upper   = false

  # Random Suffix Configuration - VNet
  hub_networking_vnet_random_suffix_length  = 4
  hub_networking_vnet_random_suffix_special = false
  hub_networking_vnet_random_suffix_upper   = false

  # Random Suffix Configuration - Subnet PE
  hub_networking_subnet_pe_random_suffix_length  = 4
  hub_networking_subnet_pe_random_suffix_special = false
  hub_networking_subnet_pe_random_suffix_upper   = false

  # Random Suffix Configuration - Subnet VM
  hub_networking_subnet_vm_random_suffix_length  = 4
  hub_networking_subnet_vm_random_suffix_special = false
  hub_networking_subnet_vm_random_suffix_upper   = false

  # Random Suffix Configuration - Subnet Azure Firewall
  hub_networking_subnet_azure_firewall_random_suffix_length  = 4
  hub_networking_subnet_azure_firewall_random_suffix_special = false
  hub_networking_subnet_azure_firewall_random_suffix_upper   = false

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = []
}

# =============================================================================
# COMPUTE INFRASTRUCTURE
# =============================================================================
# Virtual machine for management, testing, and administrative tasks

module "vm" {
  source = "./modules/vm"

  # Resource Group and Location Configuration
  hub_vm_resource_group_name = local.resource_group_name
  hub_vm_location            = var.hub_location

  # Networking Configuration
  hub_vm_subnet_id = module.networking.hub_networking_vm_subnet_id

  # Virtual Machine Configuration
  hub_vm_size           = var.hub_vm_size
  hub_vm_admin_username = var.hub_vm_admin_username
  hub_vm_admin_password = var.hub_vm_admin_password

  # Storage Configuration
  hub_vm_os_disk_caching              = var.hub_vm_os_disk_caching
  hub_vm_os_disk_storage_account_type = var.hub_vm_os_disk_storage_account_type

  # OS Image Configuration
  hub_vm_os_image_publisher = var.hub_vm_os_image_publisher
  hub_vm_os_image_offer     = var.hub_vm_os_image_offer
  hub_vm_os_image_sku       = var.hub_vm_os_image_sku
  hub_vm_os_image_version   = var.hub_vm_os_image_version

  # Public IP Configuration
  hub_vm_enable_public_ip              = var.hub_vm_enable_public_ip
  hub_vm_public_ip_allocation_method   = var.hub_vm_public_ip_allocation_method
  hub_vm_public_ip_sku                 = var.hub_vm_public_ip_sku

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking]
}

# =============================================================================
# AZURE FIREWALL INFRASTRUCTURE
# =============================================================================
# Azure Firewall for network security and traffic control

module "azure-firewall" {
  source = "./modules/azure-firewall"

  # Resource Group and Location Configuration
  hub_azure_firewall_resource_group_name = local.resource_group_name
  hub_azure_firewall_location            = var.hub_location

  # Azure Firewall Configuration
  hub_azure_firewall_sku_tier = var.hub_azure_firewall_sku_tier
  hub_azure_firewall_sku_name = var.hub_azure_firewall_sku_name

  # Networking Configuration
  hub_azure_firewall_subnet_id = module.networking.hub_networking_azure_firewall_subnet_id

  # Random Suffix Configuration
  hub_azure_firewall_random_suffix_length  = var.hub_azure_firewall_random_suffix_length
  hub_azure_firewall_random_suffix_special = var.hub_azure_firewall_random_suffix_special
  hub_azure_firewall_random_suffix_upper   = var.hub_azure_firewall_random_suffix_upper

  # Azure Firewall Configuration
  hub_azure_firewall_name = module.networking.hub_networking_azure_firewall_name
  resource_group_name = local.resource_group_name
  spoke_api_vnet_address_space = var.spoke_api_vnet_address_space
  spoke_ai_vnet_address_space = var.spoke_ai_vnet_address_space

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking]
}

# =============================================================================
# STORAGE INFRASTRUCTURE
# =============================================================================
# Blob storage account for data persistence and file operations

module "blob-storage-account" {
  source = "./modules/blob-storage-account"

  # Resource Group and Location Configuration
  hub_blob_storage_resource_group_name = local.resource_group_name
  hub_blob_storage_location            = var.hub_location

  # Storage Account Configuration
  hub_blob_storage_account_tier             = var.hub_blob_storage_account_tier
  hub_blob_storage_account_replication_type = var.hub_blob_storage_account_replication_type
  hub_blob_storage_account_kind             = var.hub_blob_storage_account_kind
  hub_blob_storage_min_tls_version          = var.hub_blob_storage_min_tls_version

  # Network Access Configuration
  hub_blob_storage_allowed_subnet_ids = var.hub_blob_storage_allowed_subnet_ids
  hub_blob_storage_allowed_ip_rules   = var.hub_blob_storage_allowed_ip_rules

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking]
}

# =============================================================================
# AI SERVICES INFRASTRUCTURE
# =============================================================================
# OpenAI and Azure AI Search services for AI capabilities

# OpenAI Cognitive Service
module "openai" {
  source = "./modules/openai"

  # Resource Group and Location Configuration
  hub_openai_resource_group_name = local.resource_group_name
  hub_openai_location            = var.hub_location

  # OpenAI Service Configuration
  hub_openai_sku_name = var.hub_openai_sku_name
  hub_openai_custom_subdomain_name = var.hub_openai_custom_subdomain_name

  # GPT-4o Mini Model Configuration
  hub_openai_gpt4_1_mini_model_name    = var.hub_openai_gpt4_1_mini_model_name
  hub_openai_gpt4_1_mini_model_version = var.hub_openai_gpt4_1_mini_model_version
  hub_openai_gpt4_1_mini_sku_name      = var.hub_openai_gpt4_1_mini_sku_name
  hub_openai_gpt4_1_mini_sku_tier      = var.hub_openai_gpt4_1_mini_sku_tier
  hub_openai_gpt4_1_mini_sku_size      = var.hub_openai_gpt4_1_mini_sku_size
  hub_openai_gpt4_1_mini_capacity      = var.hub_openai_gpt4_1_mini_capacity

  # Text Embedding Model Configuration
  hub_openai_text_embedding_model_name    = var.hub_openai_text_embedding_model_name
  hub_openai_text_embedding_model_version = var.hub_openai_text_embedding_model_version
  hub_openai_text_embedding_sku_name      = var.hub_openai_text_embedding_sku_name
  hub_openai_text_embedding_sku_tier      = var.hub_openai_text_embedding_sku_tier
  hub_openai_text_embedding_sku_size      = var.hub_openai_text_embedding_sku_size
  hub_openai_text_embedding_capacity      = var.hub_openai_text_embedding_capacity

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking]
}

# Azure AI Search Service
module "azure-ai-search" {
  source = "./modules/azure-ai-search"

  # Resource Group and Location Configuration
  hub_ai_search_resource_group_name = local.resource_group_name
  hub_ai_search_location            = var.hub_location

  # AI Search Service Configuration
  hub_ai_search_sku                 = var.hub_ai_search_sku
  hub_ai_search_hosting_mode        = var.hub_ai_search_hosting_mode
  hub_ai_search_partition_count     = var.hub_ai_search_partition_count
  hub_ai_search_replica_count       = var.hub_ai_search_replica_count
  hub_ai_search_semantic_search_sku = var.hub_ai_search_semantic_search_sku

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking]
}

# =============================================================================
# DATABASE INFRASTRUCTURE
# =============================================================================
# PostgreSQL Flexible Server for structured data storage

module "postgresql-flexible-server" {
  source = "./modules/postgresql-flexible-server"

  # Resource Group and Location Configuration
  hub_postgresql_resource_group_name = local.resource_group_name
  hub_postgresql_location            = var.hub_location

  # Database Configuration
  hub_postgresql_administrator_login    = var.hub_postgresql_admin_login
  hub_postgresql_administrator_password = var.hub_postgresql_admin_password
  hub_postgresql_sku_name               = var.hub_postgresql_sku_name
  hub_postgresql_version                = var.hub_postgresql_version
  hub_postgresql_zone                   = var.hub_postgresql_zone

  # Storage Configuration
  hub_postgresql_storage_mb   = var.hub_storage_mb
  hub_postgresql_storage_tier = var.hub_storage_tier

  # Authentication Configuration
  hub_postgresql_active_directory_auth_enabled = var.hub_postgresql_active_directory_auth_enabled
  hub_postgresql_password_auth_enabled         = var.hub_postgresql_password_auth_enabled

  # Managed Identity Configuration
  vm_managed_identity_principal_id   = module.vm.hub_vm_principal_id
  vm_managed_identity_principal_name = module.vm.hub_vm_name

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking, module.vm]
}

# =============================================================================
# PRIVATE ENDPOINTS
# =============================================================================
# Secure private connectivity for all hub services

# Blob Storage Private Endpoint
module "blob-storage-pe" {
  source = "./modules/private-endpoints/blob-storage-pe"

  # Resource Configuration
  hub_pe_blob_storage_account_id          = module.blob-storage-account.hub_blob_storage_account_id
  hub_pe_blob_storage_resource_group_name = local.resource_group_name
  hub_pe_blob_storage_location            = var.hub_location
  hub_pe_blob_storage_subnet_id           = module.networking.hub_networking_pe_subnet_id

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking, module.blob-storage-account]
}

# OpenAI Private Endpoint
module "openai-pe" {
  source = "./modules/private-endpoints/openai-pe"

  # Resource Configuration
  hub_pe_openai_resource_group_name  = local.resource_group_name
  hub_pe_openai_location             = var.hub_location
  hub_pe_openai_subnet_id            = module.networking.hub_networking_pe_subnet_id
  hub_pe_openai_cognitive_account_id = module.openai.hub_openai_cognitive_account_id

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking, module.openai]
}

# Azure AI Search Private Endpoint
module "azure-ai-search-pe" {
  source = "./modules/private-endpoints/azure-ai-search-pe"

  # Resource Configuration
  hub_pe_ai_search_resource_group_name = local.resource_group_name
  hub_pe_ai_search_location            = var.hub_location
  hub_pe_ai_search_subnet_id           = module.networking.hub_networking_pe_subnet_id
  hub_pe_ai_search_service_id          = module.azure-ai-search.hub_ai_search_service_id

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking, module.blob-storage-account, module.azure-ai-search]
}

# PostgreSQL Private Endpoint
module "postgresql-flexible-server-pe" {
  source = "./modules/private-endpoints/postgresql-flexible-server-pe"

  # Resource Configuration
  hub_pe_postgresql_resource_group_name = local.resource_group_name
  hub_pe_postgresql_location            = var.hub_location
  hub_pe_postgresql_subnet_id           = module.networking.hub_networking_pe_subnet_id
  hub_pe_postgresql_server_id           = module.postgresql-flexible-server.hub_postgresql_server_id
  hub_pe_postgresql_server_name         = module.postgresql-flexible-server.hub_postgresql_server_name

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking, module.blob-storage-account, module.postgresql-flexible-server]
}

# =============================================================================
# ACR INFRASTRUCTURE
# =============================================================================
# Azure Container Registry for container image storage

module "acr" {
  source                                = "./modules/acr"
  hub_acr_resource_group_name           = local.resource_group_name
  hub_acr_location                      = var.hub_location
  hub_acr_sku                           = var.hub_acr_sku
  hub_acr_admin_enabled                 = var.hub_acr_admin_enabled
  hub_acr_public_network_access_enabled = var.hub_acr_public_network_access_enabled
  hub_acr_random_suffix_length          = var.hub_acr_random_suffix_length
  hub_acr_random_suffix_special         = var.hub_acr_random_suffix_special
  hub_acr_random_suffix_upper           = var.hub_acr_random_suffix_upper
  naming_company                        = var.naming_company
  naming_product                        = var.naming_product
  naming_environment                    = var.naming_environment
  naming_region                         = var.naming_region
}

# ACR Private Endpoint
module "acr-pe" {
  source                         = "./modules/private-endpoints/acr-pe"
  hub_pe_acr_resource_group_name = local.resource_group_name
  hub_pe_acr_location            = var.hub_location
  hub_pe_acr_id                  = module.acr.hub_acr_id
  hub_pe_acr_subnet_id           = module.networking.hub_networking_pe_subnet_id
  naming_company                 = var.naming_company
  naming_product                 = var.naming_product
  naming_environment             = var.naming_environment
  naming_region                  = var.naming_region
}
