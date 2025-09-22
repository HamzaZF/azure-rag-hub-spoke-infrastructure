/*
  main.tf - Spoke AI Module Configuration

  This file orchestrates the deployment of all AI spoke resources for the Kelix Azure
  environment, including networking, storage, and data management infrastructure
  with comprehensive security controls.

  AI Spoke Components:
  - Core networking infrastructure with private endpoints
  - Storage account with table storage for AI data persistence
  - Private endpoints for secure service connectivity
  - Cross-VNet peering with hub for centralized access
  - Managed identity-based RBAC for secure access
*/

# =============================================================================
# RESOURCE GROUP REFERENCE
# =============================================================================
# Using pre-created resource group from main.tf to avoid circular dependencies

locals {
  container_apps_resource_group_name = var.spoke_ai_container_apps_resource_group_name
  container_apps_infrastructure_rg_name  = var.spoke_ai_container_apps_infrastructure_rg_name 
}

# =============================================================================
# NETWORKING INFRASTRUCTURE
# =============================================================================
# Core networking with VNet, subnets, and network security groups

module "networking" {
  source = "./modules/networking"

  # Resource Group and Location Configuration
  spoke_ai_networking_resource_group_name = local.container_apps_resource_group_name
  spoke_ai_networking_location            = var.spoke_ai_location

  # Virtual Network Configuration
  spoke_ai_networking_vnet_address_space    = var.spoke_ai_vnet_address_space
  spoke_ai_networking_pe_subnet_prefix      = var.spoke_ai_pe_subnet_prefix
  spoke_ai_networking_cappenv_subnet_prefix = var.spoke_ai_cappenv_subnet_prefix

  # Hub Networking Integration
  hub_vnet_id             = var.hub_vnet_id
  hub_vnet_name           = var.hub_vnet_name
  hub_resource_group_name = var.hub_resource_group_name
  hub_vnet_address_space  = var.hub_vnet_address_space

  # Cross-Spoke Networking Integration
  spoke_api_vnet_address_space = var.spoke_api_vnet_address_space
  spoke_ai_pe_subnet_prefix    = var.spoke_ai_pe_subnet_prefix

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  hub_azure_firewall_public_ip_address = var.hub_azure_firewall_public_ip_address

  depends_on = []
}

# =============================================================================
# STORAGE ACCOUNT INFRASTRUCTURE
# =============================================================================
# Storage account with table storage for AI data persistence

module "storage-account" {
  source = "./modules/storage-account"

  # Resource Group and Location Configuration
  spoke_ai_storage_resource_group_name = local.container_apps_resource_group_name
  spoke_ai_storage_location            = var.spoke_ai_location

  # Storage Account Configuration
  spoke_ai_storage_account_tier             = var.spoke_ai_storage_account_tier
  spoke_ai_storage_account_replication_type = var.spoke_ai_storage_account_replication_type
  spoke_ai_storage_account_kind             = var.spoke_ai_storage_account_kind

  # Networking Integration
  spoke_ai_storage_subnet_id = module.networking.spoke_ai_networking_subnet_pe_id
  spoke_ai_storage_vnet_id   = module.networking.spoke_ai_networking_vnet_id

  # Security Configuration
  spoke_ai_storage_allowed_subnet_ids = var.spoke_ai_storage_allowed_subnet_ids
  spoke_ai_storage_allowed_ip_rules   = var.spoke_ai_storage_allowed_ip_rules

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking]
}

# =============================================================================
# KEY VAULT INFRASTRUCTURE
# =============================================================================
# Key vault for storing secrets

module "key-vault" {
  source = "./modules/key-vault"

  # Resource Group and Location Configuration
  spoke_ai_key_vault_resource_group_name = local.container_apps_resource_group_name
  spoke_ai_key_vault_location            = var.spoke_ai_location

  # Key Vault Configuration
  spoke_ai_key_vault_sku_name = var.spoke_ai_key_vault_sku_name

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  spoke_ai_container_apps_subnet_id = module.networking.spoke_ai_networking_subnet_cappenv_id
  spoke_ai_key_vault_random_suffix_length = var.spoke_ai_key_vault_random_suffix_length
  spoke_ai_key_vault_random_suffix_special = var.spoke_ai_key_vault_random_suffix_special
  spoke_ai_key_vault_random_suffix_upper = var.spoke_ai_key_vault_random_suffix_upper
}

# =============================================================================
# STORAGE PRIVATE ENDPOINT INFRASTRUCTURE
# =============================================================================
# Private endpoint for secure storage connectivity

module "storage-pe" {
  source = "./modules/private-endpoints/storage-pe"

  # Resource Group and Location Configuration
  spoke_ai_pe_storage_resource_group_name = local.container_apps_resource_group_name
  spoke_ai_pe_storage_location            = var.spoke_ai_location

  # Storage Account Integration
  spoke_ai_pe_storage_account_id = module.storage-account.spoke_ai_storage_account_id

  # Networking Integration
  spoke_ai_pe_storage_subnet_id = module.networking.spoke_ai_networking_subnet_pe_id
  spoke_ai_pe_storage_vnet_id   = module.networking.spoke_ai_networking_vnet_id

  # Private DNS Zone Configuration - will be created by the private endpoint module
  spoke_ai_pe_storage_private_dns_zone_id = null

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.storage-account, module.networking]
}

# =============================================================================
# CONTAINER APPS ENVIRONMENT INFRASTRUCTURE
# =============================================================================
# Container apps environment for hosting containerized AI workloads

module "container-apps-environment" {
  source = "./modules/container-apps-environment"

  # Resource Group and Location Configuration
  spoke_ai_container_apps_resource_group_name = local.container_apps_resource_group_name
  spoke_ai_container_apps_location            = var.spoke_ai_location

  # Infrastructure Configuration
  spoke_ai_container_apps_infrastructure_rg_name   = local.container_apps_infrastructure_rg_name 
  spoke_ai_container_apps_infrastructure_subnet_id = module.networking.spoke_ai_networking_subnet_cappenv_id

  # Environment Configuration
  spoke_ai_container_apps_zone_redundancy_enabled = var.spoke_ai_container_apps_zone_redundancy_enabled
  spoke_ai_container_apps_mutual_tls_enabled      = var.spoke_ai_container_apps_mutual_tls_enabled

  # Workload Profile Configuration
  spoke_ai_container_apps_workload_profile_name      = var.spoke_ai_container_apps_workload_profile_name
  spoke_ai_container_apps_workload_profile_type      = var.spoke_ai_container_apps_workload_profile_type
  spoke_ai_container_apps_workload_profile_min_count = var.spoke_ai_container_apps_workload_profile_min_count
  spoke_ai_container_apps_workload_profile_max_count = var.spoke_ai_container_apps_workload_profile_max_count

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.networking]
}

# -----------------------------------------------------------------------------
# Private DNS Zone
# -----------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "container_apps_environment_dns_zone" {
  name                = module.container-apps-environment.spoke_ai_container_apps_environment_default_domain
  resource_group_name = local.container_apps_resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "container_apps_environment_dns_zone_link" {
  name                = "ai-spoke-link"
  resource_group_name = local.container_apps_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.container_apps_environment_dns_zone.name
  virtual_network_id = module.networking.spoke_ai_networking_vnet_id
  registration_enabled = false
  
  depends_on = [azurerm_private_dns_zone.container_apps_environment_dns_zone]
}

//add a link to the hub
resource "azurerm_private_dns_zone_virtual_network_link" "container_apps_environment_dns_zone_hub_link" {
  name                = "hub-link"
  resource_group_name = local.container_apps_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.container_apps_environment_dns_zone.name
  virtual_network_id = var.hub_vnet_id
  registration_enabled = false
  
  depends_on = [azurerm_private_dns_zone.container_apps_environment_dns_zone]
}

//add a link to the api spoke
resource "azurerm_private_dns_zone_virtual_network_link" "container_apps_environment_dns_zone_api_spoke_link" {
  name                = "api-spoke-link"
  resource_group_name = local.container_apps_resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.container_apps_environment_dns_zone.name
  virtual_network_id = var.spoke_api_vnet_id
  registration_enabled = false
  
  depends_on = [azurerm_private_dns_zone.container_apps_environment_dns_zone]
}


//add record to link container apps url to the container app environment ip (internal load balancer)
resource "azurerm_private_dns_a_record" "container_apps_records" {
  for_each            = var.spoke_ai_container_apps
  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.container_apps_environment_dns_zone.name
  resource_group_name = local.container_apps_resource_group_name
  ttl                 = 300
  records             = [module.container-apps-environment.spoke_ai_container_apps_environment_static_ip_address]
}


# =============================================================================
# CONTAINER APPS INFRASTRUCTURE
# =============================================================================
# Multiple container apps for AI workloads

module "container-app" {
  source = "./modules/container-app"

  # Resource Group and Location Configuration
  spoke_ai_container_app_resource_group_name = local.container_apps_resource_group_name

  # Container Apps Configuration
  spoke_ai_container_apps = var.spoke_ai_container_apps

  spoke_ai_container_app_environment_resource_id = module.container-apps-environment.spoke_ai_container_apps_environment_id

  # Default Ingress Configuration
  spoke_ai_container_app_ingress_allow_insecure_connections = var.spoke_ai_container_app_ingress_allow_insecure_connections
  spoke_ai_container_app_ingress_exposed_port               = var.spoke_ai_container_app_ingress_exposed_port
  spoke_ai_container_app_ingress_external_enabled           = var.spoke_ai_container_app_ingress_external_enabled
  spoke_ai_container_app_ingress_target_port                = var.spoke_ai_container_app_ingress_target_port
  spoke_ai_container_app_ingress_transport                  = var.spoke_ai_container_app_ingress_transport
  spoke_ai_container_app_ingress_traffic_weight             = var.spoke_ai_container_app_ingress_traffic_weight

  # Default Identity Configuration
  spoke_ai_container_app_identity_id        = var.spoke_ai_container_app_identity_id
  spoke_ai_container_app_identity_lifecycle = var.spoke_ai_container_app_identity_lifecycle

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  depends_on = [module.container-apps-environment]
}
