/*
  main.tf - Root Terraform Configuration
  
  This file orchestrates the deployment of the Kelix Azure hub-spoke architecture,
  including core networking, compute, storage, AI services, and cross-resource
  access controls.
  
  Architecture Overview:
  - Hub: Core networking, shared services, and security controls
  - Spoke API: Web application workloads with Application Gateway
  - Cross-VNet connectivity via peering and private DNS resolution
  - Managed identity-based RBAC for secure service-to-service communication
*/

# =============================================================================
# PROVIDERS AND NAMING CONVENTION
# =============================================================================

module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment]
  suffix = [var.naming_region]
}

# Random string for DNS zone link uniqueness
resource "random_string" "dns_link_suffix" {
  length  = 8
  special = false
  upper   = false
}

# =============================================================================
# RESOURCE GROUPS
# =============================================================================

resource "azurerm_resource_group" "hub_rg" {
  location = var.hub_location
  name     = "${var.hub_location}-hub-rg"
}

resource "azurerm_resource_group" "api_rg" {
  location = var.spoke_api_location
  name     = "${var.spoke_api_location}-api-rg"
}

resource "azurerm_resource_group" "ai_rg" {
  location = var.spoke_ai_location
  name     = "${var.spoke_ai_location}-ai-rg"
}

# resource "azurerm_resource_group" "ai_container_apps_rg" {
#   location = var.spoke_ai_location
#   name     = "${var.spoke_ai_location}-ai-container-apps-infra-rg-${random_string.ai_container_apps_infra_suffix.result}"
# }

resource "random_string" "ai_container_apps_infra_suffix" {
  length  = 6
  special = false
  upper   = false
}

# =============================================================================
# USER-ASSIGNED MANAGED IDENTITY FOR AI CONTAINER APPS
# =============================================================================
# Centralized identity management for AI container apps with cross-resource access

resource "azurerm_user_assigned_identity" "ai_container_apps_identity" {
  name                = "${module.naming.user_assigned_identity.name}-${random_string.identity_suffix.result}"
  resource_group_name = azurerm_resource_group.ai_rg.name
  location            = var.spoke_ai_location
}

resource "random_string" "identity_suffix" {
  length  = 4
  special = false
  upper   = false
}

# =============================================================================
# USER-ASSIGNED MANAGED IDENTITY FOR APP GATEWAY
# =============================================================================
# Centralized identity management for app gateway with cross-resource access

resource "azurerm_user_assigned_identity" "app_gateway_identity" {
  name                = "${module.naming.user_assigned_identity.name}-${random_string.identity_app_gateway_suffix.result}"
  resource_group_name = azurerm_resource_group.api_rg.name
  location            = var.spoke_api_location
}

resource "random_string" "identity_app_gateway_suffix" {
  length  = 4
  special = false
  upper   = false
}

# =============================================================================
# HUB INFRASTRUCTURE DEPLOYMENT
# =============================================================================
# Core networking, compute, storage, and AI services for centralized operations

module "hub" {
  source = "./modules/hub"

  # Resource Group Configuration
  hub_resource_group_name = azurerm_resource_group.hub_rg.name

  # Location and Networking Configuration
  hub_location                     = var.hub_location
  hub_vnet_address_space           = var.hub_vnet_address_space
  hub_pe_subnet_prefix             = var.hub_pe_subnet_prefix
  hub_vm_subnet_prefix             = var.hub_vm_subnet_prefix
  hub_azure_firewall_subnet_prefix = var.hub_azure_firewall_subnet_prefix

  # Virtual Machine Configuration
  hub_vm_size                         = var.hub_vm_size
  hub_vm_admin_username               = var.hub_vm_admin_username
  hub_vm_admin_password               = var.hub_vm_admin_password
  hub_vm_os_disk_caching              = var.hub_vm_os_disk_caching
  hub_vm_os_disk_storage_account_type = var.hub_vm_os_disk_storage_account_type
  hub_vm_os_image_publisher           = var.hub_vm_os_image_publisher
  hub_vm_os_image_offer               = var.hub_vm_os_image_offer
  hub_vm_os_image_sku                 = var.hub_vm_os_image_sku
  hub_vm_os_image_version             = var.hub_vm_os_image_version

  # Public IP Configuration
  hub_vm_enable_public_ip            = var.hub_vm_enable_public_ip
  hub_vm_public_ip_allocation_method = var.hub_vm_public_ip_allocation_method
  hub_vm_public_ip_sku               = var.hub_vm_public_ip_sku

  # Storage Configuration
  hub_blob_storage_account_tier             = var.hub_blob_storage_account_tier
  hub_blob_storage_account_replication_type = var.hub_blob_storage_account_replication_type
  hub_blob_storage_account_kind             = var.hub_blob_storage_account_kind
  hub_blob_storage_min_tls_version          = var.hub_blob_storage_min_tls_version

  # Network Access Configuration - Shared service accessible by all spokes and hub
  hub_blob_storage_allowed_subnet_ids = [
    module.hub.hub_vm_subnet_id,                # Hub VM access
    module.spoke_api.spoke_api_wa_subnet_id,    # API spoke web app access
    module.spoke_ai.spoke_ai_cappenv_subnet_id, # AI spoke container apps access
  ]
  hub_blob_storage_allowed_ip_rules = var.hub_blob_storage_allowed_ip_rules

  # OpenAI Configuration
  hub_openai_sku_name                     = var.hub_openai_sku_name
  hub_openai_gpt4_1_mini_model_name       = var.hub_openai_gpt4_1_mini_model_name
  hub_openai_gpt4_1_mini_model_version    = var.hub_openai_gpt4_1_mini_model_version
  hub_openai_gpt4_1_mini_sku_name         = var.hub_openai_gpt4_1_mini_sku_name
  hub_openai_gpt4_1_mini_sku_tier         = var.hub_openai_gpt4_1_mini_sku_tier
  hub_openai_gpt4_1_mini_sku_size         = var.hub_openai_gpt4_1_mini_sku_size
  hub_openai_gpt4_1_mini_capacity         = var.hub_openai_gpt4_1_mini_capacity
  hub_openai_text_embedding_model_name    = var.hub_openai_text_embedding_model_name
  hub_openai_text_embedding_model_version = var.hub_openai_text_embedding_model_version
  hub_openai_text_embedding_sku_name      = var.hub_openai_text_embedding_sku_name
  hub_openai_text_embedding_sku_tier      = var.hub_openai_text_embedding_sku_tier
  hub_openai_text_embedding_sku_size      = var.hub_openai_text_embedding_sku_size
  hub_openai_text_embedding_capacity      = var.hub_openai_text_embedding_capacity
  hub_openai_custom_subdomain_name        = var.hub_openai_custom_subdomain_name

  # Azure AI Search Configuration
  hub_ai_search_hosting_mode        = var.hub_ai_search_hosting_mode
  hub_ai_search_partition_count     = var.hub_ai_search_partition_count
  hub_ai_search_replica_count       = var.hub_ai_search_replica_count
  hub_ai_search_semantic_search_sku = var.hub_ai_search_semantic_search_sku
  hub_ai_search_sku                 = var.hub_ai_search_sku

  # PostgreSQL Configuration
  hub_postgresql_version                       = var.hub_postgresql_version
  hub_postgresql_zone                          = var.hub_postgresql_zone
  hub_postgresql_active_directory_auth_enabled = var.hub_postgresql_active_directory_auth_enabled
  hub_postgresql_password_auth_enabled         = var.hub_postgresql_password_auth_enabled
  hub_storage_mb                               = var.hub_storage_mb
  hub_storage_tier                             = var.hub_storage_tier
  hub_postgresql_admin_login                   = var.hub_postgresql_admin_login
  hub_postgresql_sku_name                      = var.hub_postgresql_sku_name
  hub_postgresql_admin_password                = var.hub_postgresql_admin_password

  # Security Configuration
  hub_allowed_ssh_sources = var.hub_allowed_ssh_sources

  # Azure Firewall Configuration
  hub_azure_firewall_sku_tier              = var.hub_azure_firewall_sku_tier
  hub_azure_firewall_sku_name              = var.hub_azure_firewall_sku_name
  hub_azure_firewall_random_suffix_length  = var.hub_azure_firewall_random_suffix_length
  hub_azure_firewall_random_suffix_special = var.hub_azure_firewall_random_suffix_special
  hub_azure_firewall_random_suffix_upper   = var.hub_azure_firewall_random_suffix_upper

  # Cross-Module Configuration
  spoke_api_networking_pe_subnet_prefix     = var.spoke_api_pe_subnet_prefix
  spoke_ai_networking_pe_subnet_prefix      = var.spoke_ai_pe_subnet_prefix
  spoke_ai_networking_cappenv_subnet_prefix = var.spoke_ai_cappenv_subnet_prefix
  naming_company                            = var.naming_company
  naming_product                            = var.naming_product
  naming_environment                        = var.naming_environment
  naming_region                             = var.naming_region

  # ACR Configuration
  hub_acr_sku                           = var.hub_acr_sku
  hub_acr_admin_enabled                 = var.hub_acr_admin_enabled
  hub_acr_public_network_access_enabled = var.hub_acr_public_network_access_enabled
  hub_acr_random_suffix_length          = var.hub_acr_random_suffix_length
  hub_acr_random_suffix_special         = var.hub_acr_random_suffix_special
  hub_acr_random_suffix_upper           = var.hub_acr_random_suffix_upper
  acr_webhook_status                    = var.acr_webhook_status
  acr_webhook_scope                     = var.acr_webhook_scope
  acr_webhook_name                      = var.acr_webhook_name

  # Azure Firewall Configuration
  spoke_api_vnet_address_space = var.spoke_api_vnet_address_space
  spoke_ai_vnet_address_space  = var.spoke_ai_vnet_address_space
}

# =============================================================================
# SPOKE API INFRASTRUCTURE DEPLOYMENT
# =============================================================================
# Web application workloads with container registry, web app, and load balancer

module "spoke_api" {
  source = "./modules/spoke-api"

  # Resource Group Configuration
  spoke_api_resource_group_name = azurerm_resource_group.api_rg.name

  # Location and Networking Configuration
  spoke_api_location              = var.spoke_api_location
  spoke_api_sku_name              = var.spoke_api_sku_name
  spoke_api_vnet_address_space    = var.spoke_api_vnet_address_space
  spoke_api_ag_subnet_prefix      = var.spoke_api_ag_subnet_prefix
  spoke_api_wa_subnet_prefix      = var.spoke_api_wa_subnet_prefix
  spoke_api_pe_subnet_prefix      = var.spoke_api_pe_subnet_prefix
  hub_networking_pe_subnet_prefix = var.hub_pe_subnet_prefix

  # Container Registry Configuration - Moved to Hub
  # ACR is now managed in the hub module

  # Application Gateway Configuration
  spoke_api_ag_public_ip_allocation_method         = var.spoke_api_ag_public_ip_allocation_method
  spoke_api_ag_public_ip_sku                       = var.spoke_api_ag_public_ip_sku
  spoke_api_ag_public_ip_sku_tier                  = var.spoke_api_ag_public_ip_sku_tier
  spoke_api_ag_private_ip_address                  = var.spoke_api_ag_private_ip_address
  spoke_api_ag_autoscale_min_capacity              = var.spoke_api_ag_autoscale_min_capacity
  spoke_api_ag_autoscale_max_capacity              = var.spoke_api_ag_autoscale_max_capacity
  spoke_api_ag_frontend_port                       = var.spoke_api_ag_frontend_port
  spoke_api_ag_backend_port                        = var.spoke_api_ag_backend_port
  spoke_api_ag_backend_protocol                    = var.spoke_api_ag_backend_protocol
  spoke_api_ag_request_timeout                     = var.spoke_api_ag_request_timeout
  spoke_api_ag_probe_interval                      = var.spoke_api_ag_probe_interval
  spoke_api_ag_probe_timeout                       = var.spoke_api_ag_probe_timeout
  spoke_api_ag_probe_unhealthy_threshold           = var.spoke_api_ag_probe_unhealthy_threshold
  spoke_api_ag_probe_path                          = var.spoke_api_ag_probe_path
  spoke_api_ag_waf_policy_mode                     = var.spoke_api_ag_waf_policy_mode
  spoke_api_ag_waf_policy_managed_rule_set_type    = var.spoke_api_ag_waf_policy_managed_rule_set_type
  spoke_api_ag_waf_policy_managed_rule_set_version = var.spoke_api_ag_waf_policy_managed_rule_set_version
  spoke_api_ag_frontend_protocol                   = var.spoke_api_ag_frontend_protocol
  spoke_api_ag_waf_sku_name                        = var.spoke_api_ag_waf_sku_name
  spoke_api_ag_waf_sku_tier                        = var.spoke_api_ag_waf_sku_tier
  app_gateway_identity_id                          = azurerm_user_assigned_identity.app_gateway_identity.id

  # SSL Configuration
  spoke_api_ag_frontend_port_http       = var.spoke_api_ag_frontend_port_http
  spoke_api_ag_ssl_certificate_name     = var.spoke_api_ag_ssl_certificate_name
  spoke_api_ag_ssl_certificate_path     = var.spoke_api_ag_ssl_certificate_path
  spoke_api_ag_ssl_certificate_password = var.spoke_api_ag_ssl_certificate_password

  # Container Configuration
  backend_container_image_name = var.backend_container_image_name

  # Security Configuration
  static_web_app_allowed_ips = var.static_web_app_allowed_ips

  # Cross-Module Configuration (Hub Service Endpoints for Managed Identity)
  hub_blob_storage_account_name    = module.hub.hub_blob_storage_account_name
  hub_ai_search_service_name       = module.hub.hub_ai_search_service_name
  hub_openai_custom_subdomain_name = module.hub.hub_openai_custom_subdomain_name
  hub_postgresql_fqdn              = module.hub.hub_postgresql_server_fqdn
  hub_acr_login_server             = module.hub.hub_acr_login_server
  hub_acr_resource_id              = module.hub.hub_acr_resource_id
  hub_acr_name                     = module.hub.hub_acr_name

  # Cross-Spoke Configuration
  spoke_ai_vnet_address_space = var.spoke_ai_vnet_address_space

  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  # Key Vault Configuration
  spoke_api_key_vault_sku_name              = var.spoke_api_key_vault_sku_name
  spoke_api_key_vault_random_suffix_length  = var.spoke_api_key_vault_random_suffix_length
  spoke_api_key_vault_random_suffix_special = var.spoke_api_key_vault_random_suffix_special
  spoke_api_key_vault_random_suffix_upper   = var.spoke_api_key_vault_random_suffix_upper

  # Key Vault Private Endpoint Configuration
  spoke_api_pe_key_vault_pe_random_suffix_length         = var.spoke_api_pe_key_vault_pe_random_suffix_length
  spoke_api_pe_key_vault_pe_random_suffix_special        = var.spoke_api_pe_key_vault_pe_random_suffix_special
  spoke_api_pe_key_vault_pe_random_suffix_upper          = var.spoke_api_pe_key_vault_pe_random_suffix_upper
  spoke_api_pe_key_vault_dns_group_random_suffix_length  = var.spoke_api_pe_key_vault_dns_group_random_suffix_length
  spoke_api_pe_key_vault_dns_group_random_suffix_special = var.spoke_api_pe_key_vault_dns_group_random_suffix_special
  spoke_api_pe_key_vault_dns_group_random_suffix_upper   = var.spoke_api_pe_key_vault_dns_group_random_suffix_upper

  # Web App Application Configuration Variables
  admin_account_email                   = var.admin_account_email
  admin_account_password                = var.admin_account_password
  appinsights_instrumentation_key       = var.appinsights_instrumentation_key
  appinsights_profiler_version          = var.appinsights_profiler_version
  appinsights_snapshot_version          = var.appinsights_snapshot_version
  applicationinsights_config_content    = var.applicationinsights_config_content
  applicationinsights_connection_string = var.applicationinsights_connection_string
  applicationinsights_agent_version     = var.applicationinsights_agent_version
  azure_ai_search_endpoint              = var.azure_ai_search_endpoint
  azure_ai_search_index_name            = var.azure_ai_search_index_name
  azure_ai_search_query_key             = var.azure_ai_search_query_key
  azure_blob_base_url                   = var.azure_blob_base_url
  azure_blob_container_path             = var.azure_blob_container_path
  azure_conversation_model_name         = var.azure_conversation_model_name
  azure_openai_base_url                 = var.azure_openai_base_url
  azure_openai_key                      = var.azure_openai_key
  azure_openai_api_version              = var.azure_openai_api_version
  azure_refine_model_name               = var.azure_refine_model_name
  azure_embedding_model_name            = var.azure_embedding_model_name
  azure_email_connection_string         = var.azure_email_connection_string
  azure_email_sender                    = var.azure_email_sender
  azure_storage_account_key             = var.azure_storage_account_key
  azure_storage_account_name            = var.azure_storage_account_name
  azure_storage_connection_string       = var.azure_storage_connection_string
  azure_workflow_job_id                 = var.azure_workflow_job_id
  csv_top_k                             = var.csv_top_k
  database_url                          = var.database_url
  databricks_access_token               = var.databricks_access_token
  databricks_catalog_name               = var.databricks_catalog_name
  databricks_job_base_url               = var.databricks_job_base_url
  databricks_job_jwt_token              = var.databricks_job_jwt_token
  databricks_vector_base_url            = var.databricks_vector_base_url
  databricks_vector_jwt_token           = var.databricks_vector_jwt_token
  default_password                      = var.default_password
  diagnostic_services_version           = var.diagnostic_services_version
  docker_enable_ci                      = var.docker_enable_ci
  frontend_domain                       = var.frontend_domain
  images_top_k                          = var.images_top_k
  main_top_k                            = var.main_top_k
  instrumentation_engine_version        = var.instrumentation_engine_version
  is_dev_environment                    = var.is_dev_environment
  is_using_vector_search                = var.is_using_vector_search
  score_threshold                       = var.score_threshold
  second_tier_threshold                 = var.second_tier_threshold
  snapshot_debugger_version             = var.snapshot_debugger_version
  websites_enable_storage               = var.websites_enable_storage
  app_insights_base_extensions          = var.app_insights_base_extensions
  app_insights_mode                     = var.app_insights_mode
  app_insights_preempt_sdk              = var.app_insights_preempt_sdk

  # Hub Service Configuration - REMOVED SECRETS FOR MANAGED IDENTITY
  # hub_postgresql_admin_login            = module.hub.hub_postgresql_administrator_login  # REMOVED
  # hub_postgresql_admin_password         = module.hub.hub_postgresql_administrator_password  # REMOVED

  # Frontend Web App Configuration Variables
  spoke_api_frontend_sku_name   = var.spoke_api_frontend_sku_name
  frontend_container_image_name = var.frontend_container_image_name
  frontend_node_env             = var.frontend_node_env
  frontend_port                 = var.frontend_port

  # Azure Firewall Configuration
  hub_azure_firewall_public_ip_address = module.hub.hub_azure_firewall_public_ip_address

  # Route Table Configuration
  spoke_api_networking_route_table_random_suffix_length  = var.spoke_api_networking_route_table_random_suffix_length
  spoke_api_networking_route_table_random_suffix_special = var.spoke_api_networking_route_table_random_suffix_special
  spoke_api_networking_route_table_random_suffix_upper   = var.spoke_api_networking_route_table_random_suffix_upper
}

# =============================================================================
# SPOKE AI INFRASTRUCTURE DEPLOYMENT
# =============================================================================
# AI workloads with storage account and table storage for data persistence

module "spoke_ai" {
  source = "./modules/spoke-ai"

  # Resource Group Configuration
  spoke_ai_container_apps_resource_group_name    = azurerm_resource_group.ai_rg.name
  spoke_ai_container_apps_infrastructure_rg_name = "${var.spoke_ai_location}-ai-container-apps-infra-rg" //azurerm_resource_group.ai_container_apps_rg.name

  # Location and Networking Configuration
  spoke_ai_location              = var.spoke_ai_location
  spoke_ai_vnet_address_space    = var.spoke_ai_vnet_address_space
  spoke_ai_pe_subnet_prefix      = var.spoke_ai_pe_subnet_prefix
  spoke_ai_cappenv_subnet_prefix = var.spoke_ai_cappenv_subnet_prefix

  # Storage Account Configuration
  spoke_ai_storage_account_tier             = var.spoke_ai_storage_account_tier
  spoke_ai_storage_account_replication_type = var.spoke_ai_storage_account_replication_type
  spoke_ai_storage_account_kind             = var.spoke_ai_storage_account_kind

  # Network Access Configuration - AI storage accessible by AI container apps
  spoke_ai_storage_allowed_subnet_ids = [
    module.spoke_ai.spoke_ai_cappenv_subnet_id # AI container apps access
  ]
  spoke_ai_storage_allowed_ip_rules = var.spoke_ai_storage_allowed_ip_rules

  # Container Apps Configuration
  spoke_ai_container_apps = var.spoke_ai_container_apps

  # ACR Configuration
  acr_webhook_scope  = var.acr_webhook_scope
  acr_webhook_status = var.acr_webhook_status

  spoke_ai_container_app_identity_id                        = azurerm_user_assigned_identity.ai_container_apps_identity.id
  spoke_ai_container_app_identity_lifecycle                 = var.spoke_ai_container_app_identity_lifecycle
  spoke_ai_container_app_ingress_allow_insecure_connections = var.spoke_ai_container_app_ingress_allow_insecure_connections
  spoke_ai_container_app_ingress_exposed_port               = var.spoke_ai_container_app_ingress_exposed_port
  spoke_ai_container_app_ingress_external_enabled           = var.spoke_ai_container_app_ingress_external_enabled
  spoke_ai_container_app_ingress_target_port                = var.spoke_ai_container_app_ingress_target_port
  spoke_ai_container_app_ingress_transport                  = var.spoke_ai_container_app_ingress_transport
  spoke_ai_container_app_ingress_traffic_weight             = var.spoke_ai_container_app_ingress_traffic_weight
  spoke_ai_container_apps_zone_redundancy_enabled           = var.spoke_ai_container_apps_zone_redundancy_enabled
  spoke_ai_container_apps_mutual_tls_enabled                = var.spoke_ai_container_apps_mutual_tls_enabled
  spoke_ai_container_apps_workload_profile_name             = var.spoke_ai_container_apps_workload_profile_name
  spoke_ai_container_apps_workload_profile_type             = var.spoke_ai_container_apps_workload_profile_type
  spoke_ai_container_apps_workload_profile_min_count        = var.spoke_ai_container_apps_workload_profile_min_count
  spoke_ai_container_apps_workload_profile_max_count        = var.spoke_ai_container_apps_workload_profile_max_count

  # Hub Networking Integration
  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_virtual_network_name
  hub_resource_group_name = module.hub.hub_resource_group_name
  hub_vnet_address_space  = var.hub_vnet_address_space

  # Cross-Spoke Networking Integration
  spoke_api_vnet_address_space = var.spoke_api_vnet_address_space
  spoke_api_vnet_id           = module.spoke_api.spoke_api_vnet_id

  spoke_ai_key_vault_random_suffix_upper   = var.spoke_ai_key_vault_random_suffix_upper
  spoke_ai_key_vault_random_suffix_special = var.spoke_ai_key_vault_random_suffix_special
  spoke_ai_key_vault_random_suffix_length  = var.spoke_ai_key_vault_random_suffix_length
  spoke_ai_key_vault_sku_name              = var.spoke_ai_key_vault_sku_name

  # Naming Convention
  naming_company     = var.naming_company
  naming_product     = var.naming_product
  naming_environment = var.naming_environment
  naming_region      = var.naming_region

  # Route Table Configuration
  spoke_ai_networking_route_table_random_suffix_length  = var.spoke_ai_networking_route_table_random_suffix_length
  spoke_ai_networking_route_table_random_suffix_special = var.spoke_ai_networking_route_table_random_suffix_special
  spoke_ai_networking_route_table_random_suffix_upper   = var.spoke_ai_networking_route_table_random_suffix_upper

  # Azure Firewall Configuration
  hub_azure_firewall_public_ip_address = module.hub.hub_azure_firewall_public_ip_address
}

# =============================================================================
# CROSS-VNET PRIVATE DNS RESOLUTION
# =============================================================================
# Enables private DNS resolution across VNets for secure service communication

# Blob Storage DNS Zone Links
resource "azurerm_private_dns_zone_virtual_network_link" "blob_storage_hub_link" {
  name                  = "kelix-stg-wus3-blob-hub-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  virtual_network_id    = module.hub.hub_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub]
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_storage_api_link" {
  name                  = "kelix-stg-wus3-blob-api-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  virtual_network_id    = module.spoke_api.spoke_api_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_api]
}

resource "azurerm_private_dns_zone_virtual_network_link" "blob_storage_ai_link" {
  name                  = "kelix-stg-wus3-blob-ai-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.blob.core.windows.net"
  virtual_network_id    = module.spoke_ai.spoke_ai_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_ai]
}

# OpenAI DNS Zone Links
resource "azurerm_private_dns_zone_virtual_network_link" "openai_hub_link" {
  name                  = "kelix-stg-wus3-openai-hub-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.openai.azure.com"
  virtual_network_id    = module.hub.hub_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub]
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_api_link" {
  name                  = "kelix-stg-wus3-openai-api-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.openai.azure.com"
  virtual_network_id    = module.spoke_api.spoke_api_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_api]
}

resource "azurerm_private_dns_zone_virtual_network_link" "openai_ai_link" {
  name                  = "kelix-stg-wus3-openai-ai-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.openai.azure.com"
  virtual_network_id    = module.spoke_ai.spoke_ai_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_ai]
}

# AI Search DNS Zone Links
resource "azurerm_private_dns_zone_virtual_network_link" "ai_search_hub_link" {
  name                  = "kelix-stg-wus3-aisearch-hub-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.search.windows.net"
  virtual_network_id    = module.hub.hub_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub]
}

resource "azurerm_private_dns_zone_virtual_network_link" "ai_search_api_link" {
  name                  = "kelix-stg-wus3-aisearch-api-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.search.windows.net"
  virtual_network_id    = module.spoke_api.spoke_api_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_api]
}

resource "azurerm_private_dns_zone_virtual_network_link" "ai_search_ai_link" {
  name                  = "kelix-stg-wus3-aisearch-ai-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.search.windows.net"
  virtual_network_id    = module.spoke_ai.spoke_ai_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_ai]
}

# PostgreSQL DNS Zone Links
resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_hub_link" {
  name                  = "kelix-stg-wus3-pgsql-hub-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.postgres.database.azure.com"
  virtual_network_id    = module.hub.hub_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub]
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_api_link" {
  name                  = "kelix-stg-wus3-pgsql-api-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.postgres.database.azure.com"
  virtual_network_id    = module.spoke_api.spoke_api_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_api]
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgresql_ai_link" {
  name                  = "kelix-stg-wus3-pgsql-ai-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.postgres.database.azure.com"
  virtual_network_id    = module.spoke_ai.spoke_ai_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_ai]
}

# ACR DNS Zone Links
resource "azurerm_private_dns_zone_virtual_network_link" "acr_hub_link" {
  name                  = "kelix-stg-wus3-acr-hub-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.azurecr.io"
  virtual_network_id    = module.hub.hub_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub]
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_api_link" {
  name                  = "kelix-stg-wus3-acr-api-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.azurecr.io"
  virtual_network_id    = module.spoke_api.spoke_api_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_api]
}

resource "azurerm_private_dns_zone_virtual_network_link" "acr_ai_link" {
  name                  = "kelix-stg-wus3-acr-ai-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.hub.hub_resource_group_name
  private_dns_zone_name = "privatelink.azurecr.io"
  virtual_network_id    = module.spoke_ai.spoke_ai_vnet_id
  registration_enabled  = false
  depends_on            = [module.hub, module.spoke_ai]
}

# AI Storage DNS Zone Links
resource "azurerm_private_dns_zone_virtual_network_link" "table_storage_ai_link" {
  name                  = "kelix-stg-wus3-aistorage-ai-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = azurerm_resource_group.ai_rg.name
  private_dns_zone_name = "privatelink.table.core.windows.net"
  virtual_network_id    = module.spoke_ai.spoke_ai_vnet_id
  registration_enabled  = false
  depends_on            = [module.spoke_ai]
}

# Web App DNS Zone Links
resource "azurerm_private_dns_zone_virtual_network_link" "web_app_api_link" {
  name                  = "kelix-stg-wus3-webapp-api-link-${random_string.dns_link_suffix.result}"
  resource_group_name   = module.spoke_api.resource_group_name
  private_dns_zone_name = "privatelink.azurewebsites.net"
  virtual_network_id    = module.spoke_api.spoke_api_vnet_id
  registration_enabled  = false
  depends_on            = [module.spoke_api]
}

# =============================================================================
# VIRTUAL NETWORK PEERING CONFIGURATION
# =============================================================================
# Establishes secure connectivity between hub and spoke networks

# API Spoke <--> Hub Peering
resource "azurerm_virtual_network_peering" "spoke_api_to_hub" {
  name                         = "${module.naming.virtual_network_peering.name}-api-to-hub-${random_string.peering_api_to_hub_suffix.result}"
  resource_group_name          = module.spoke_api.resource_group_name
  virtual_network_name         = module.spoke_api.virtual_network_name
  remote_virtual_network_id    = module.hub.hub_vnet_id
  allow_virtual_network_access = true
  depends_on                   = [module.hub, module.spoke_api]
}

resource "random_string" "peering_api_to_hub_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_api" {
  name                         = "${module.naming.virtual_network_peering.name}-hub-to-api-${random_string.peering_hub_to_api_suffix.result}"
  resource_group_name          = module.hub.hub_resource_group_name
  virtual_network_name         = module.hub.hub_virtual_network_name
  remote_virtual_network_id    = module.spoke_api.spoke_api_vnet_id
  allow_virtual_network_access = true
  depends_on                   = [module.hub, module.spoke_api]
}

resource "random_string" "peering_hub_to_api_suffix" {
  length  = 4
  special = false
  upper   = false
}

# AI Spoke <--> Hub Peering
resource "azurerm_virtual_network_peering" "spoke_ai_to_hub" {
  name                         = "${module.naming.virtual_network_peering.name}-ai-to-hub-${random_string.peering_ai_to_hub_suffix.result}"
  resource_group_name          = azurerm_resource_group.ai_rg.name
  virtual_network_name         = module.spoke_ai.spoke_ai_vnet_name
  remote_virtual_network_id    = module.hub.hub_vnet_id
  allow_virtual_network_access = true
  depends_on                   = [module.hub, module.spoke_ai]
}

resource "random_string" "peering_ai_to_hub_suffix" {
  length  = 4
  special = false
  upper   = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_ai" {
  name                         = "${module.naming.virtual_network_peering.name}-hub-to-ai-${random_string.peering_hub_to_ai_suffix.result}"
  resource_group_name          = module.hub.hub_resource_group_name
  virtual_network_name         = module.hub.hub_virtual_network_name
  remote_virtual_network_id    = module.spoke_ai.spoke_ai_vnet_id
  allow_virtual_network_access = true
  depends_on                   = [module.hub, module.spoke_ai]
}

resource "random_string" "peering_hub_to_ai_suffix" {
  length  = 4
  special = false
  upper   = false
}

# =============================================================================
# STORAGE ACCOUNT NETWORK RULES
# =============================================================================
# Configure network access rules for storage accounts after all resources are created
# This prevents circular dependency issues between storage accounts and spoke subnets

resource "azurerm_storage_account_network_rules" "hub_blob_storage_rules" {
  storage_account_id = module.hub.hub_blob_storage_account_id

  default_action = "Deny"
  virtual_network_subnet_ids = [
    module.hub.hub_vm_subnet_id,                # Hub VM access
    module.spoke_api.spoke_api_wa_subnet_id,    # API spoke web app access
    module.spoke_ai.spoke_ai_cappenv_subnet_id, # AI spoke container apps access
  ]
  ip_rules = var.hub_blob_storage_allowed_ip_rules

  depends_on = [
    module.hub,
    module.spoke_api,
    module.spoke_ai
  ]
}

# AI spoke storage account network rules
resource "azurerm_storage_account_network_rules" "spoke_ai_storage_rules" {
  storage_account_id = module.spoke_ai.spoke_ai_storage_account_id

  default_action = "Deny"
  virtual_network_subnet_ids = [
    module.spoke_ai.spoke_ai_cappenv_subnet_id # AI container apps access
  ]
  ip_rules = var.spoke_ai_storage_allowed_ip_rules

  depends_on = [
    module.hub,
    module.spoke_api,
    module.spoke_ai
  ]
}

# =============================================================================
# CROSS-RESOURCE ACCESS CONTROL (RBAC)
# =============================================================================
# Manages role-based access control for secure service-to-service communication

# Web App backend Service Principal Role Assignments
resource "azurerm_role_assignment" "web_app_blob_storage_contributor" {
  scope                = module.hub.hub_blob_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.spoke_api.spoke_api_web_app_principal_id
}

resource "azurerm_role_assignment" "web_app_postgresql_contributor" {
  scope                = module.hub.hub_postgresql_server_id
  role_definition_name = "Contributor"
  principal_id         = module.spoke_api.spoke_api_web_app_principal_id
}

resource "azurerm_role_assignment" "web_app_ai_search_user" {
  scope                = module.hub.hub_ai_search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = module.spoke_api.spoke_api_web_app_principal_id
}

resource "azurerm_role_assignment" "web_app_openai_user" {
  scope                = module.hub.hub_openai_cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.spoke_api.spoke_api_web_app_principal_id
}

resource "azurerm_role_assignment" "web_app_acr_pull" {
  scope                = module.hub.hub_acr_resource_id
  role_definition_name = "AcrPull"
  principal_id         = module.spoke_api.spoke_api_web_app_principal_id
}

resource "azurerm_role_assignment" "web_app_key_vault_secret_reader" {
  scope                = module.spoke_api.spoke_api_key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.spoke_api.spoke_api_web_app_principal_id
}

# Hub VM Service Principal Role Assignments
resource "azurerm_role_assignment" "hub_vm_blob_storage_contributor" {
  scope                = module.hub.hub_blob_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = module.hub.hub_vm_principal_id
}

resource "azurerm_role_assignment" "hub_vm_ai_search_contributor" {
  scope                = module.hub.hub_ai_search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = module.hub.hub_vm_principal_id
}

resource "azurerm_role_assignment" "hub_vm_openai_user" {
  scope                = module.hub.hub_openai_cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = module.hub.hub_vm_principal_id
}

resource "azurerm_role_assignment" "hub_vm_postgresql_contributor" {
  scope                = module.hub.hub_postgresql_server_id
  role_definition_name = "Contributor"
  principal_id         = module.hub.hub_vm_principal_id
}

resource "azurerm_role_assignment" "hub_vm_acr_pull" {
  scope                = module.hub.hub_acr_resource_id
  role_definition_name = "AcrPull"
  principal_id         = module.hub.hub_vm_principal_id
}

resource "azurerm_role_assignment" "hub_vm_ai_storage_contributor" {
  scope                = module.spoke_ai.spoke_ai_storage_account_id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = module.hub.hub_vm_principal_id
}

data "azurerm_subscription" "current" {}

resource "azurerm_role_assignment" "hub_vm_reader_subscription" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "Reader"
  principal_id         = module.hub.hub_vm_principal_id
  # Optional (but explicit) if desired:
  # principal_type       = "ServicePrincipal"
}


# AI Container Apps Service Principal Role Assignments
resource "azurerm_role_assignment" "ai_container_apps_blob_storage_contributor" {
  scope                = module.hub.hub_blob_storage_account_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.ai_container_apps_identity.principal_id
}

resource "azurerm_role_assignment" "ai_container_apps_postgresql_contributor" {
  scope                = module.hub.hub_postgresql_server_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.ai_container_apps_identity.principal_id
}

resource "azurerm_role_assignment" "ai_container_apps_ai_search_user" {
  scope                = module.hub.hub_ai_search_service_id
  role_definition_name = "Search Service Contributor"
  principal_id         = azurerm_user_assigned_identity.ai_container_apps_identity.principal_id
}

resource "azurerm_role_assignment" "ai_container_apps_openai_user" {
  scope                = module.hub.hub_openai_cognitive_account_id
  role_definition_name = "Cognitive Services User"
  principal_id         = azurerm_user_assigned_identity.ai_container_apps_identity.principal_id
}

resource "azurerm_role_assignment" "ai_container_apps_acr_pull" {
  scope                = module.hub.hub_acr_resource_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.ai_container_apps_identity.principal_id
}

resource "azurerm_role_assignment" "ai_container_apps_ai_storage_contributor" {
  scope                = module.spoke_ai.spoke_ai_storage_account_id
  role_definition_name = "Storage Table Data Contributor"
  principal_id         = azurerm_user_assigned_identity.ai_container_apps_identity.principal_id
}

# Key vault access to the app gateway
resource "azurerm_role_assignment" "app_gateway_key_vault_secret_reader" {
  scope                = module.spoke_api.spoke_api_key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.app_gateway_identity.principal_id
}

resource "azurerm_role_assignment" "app_gateway_key_vault_certificate_reader" {
  scope                = module.spoke_api.spoke_api_key_vault_id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = azurerm_user_assigned_identity.app_gateway_identity.principal_id
}