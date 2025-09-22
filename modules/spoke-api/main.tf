/*
  main.tf (Spoke API Module)

  This file orchestrates the deployment of all resources for the Kelix Azure Spoke API environment.
*/

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "api"]
  suffix = [var.naming_region]
}

# -----------------------------------------------------------------------------
# Resource Group Reference
# -----------------------------------------------------------------------------
# Using pre-created resource group from main.tf to avoid circular dependencies
locals {
  resource_group_name = var.spoke_api_resource_group_name
}

# -----------------------------------------------------------------------------
# Networking
# -----------------------------------------------------------------------------
# Deploys the core networking infrastructure for the spoke API, including VNet and subnets.
module "networking" {
  source                                   = "./modules/networking"
  spoke_api_networking_resource_group_name = local.resource_group_name
  spoke_api_networking_location            = var.spoke_api_location
  spoke_api_networking_vnet_address_space  = var.spoke_api_vnet_address_space
  spoke_api_networking_ag_subnet_prefix    = var.spoke_api_ag_subnet_prefix
  spoke_api_networking_pe_subnet_prefix    = var.spoke_api_pe_subnet_prefix
  spoke_api_networking_wa_subnet_prefix    = var.spoke_api_wa_subnet_prefix
  hub_networking_pe_subnet_prefix          = var.hub_networking_pe_subnet_prefix
  spoke_ai_vnet_address_space              = var.spoke_ai_vnet_address_space
  static_web_app_allowed_ips               = var.static_web_app_allowed_ips
  naming_company                           = var.naming_company
  naming_product                           = var.naming_product
  naming_environment                       = var.naming_environment
  naming_region                            = var.naming_region
  hub_azure_firewall_public_ip_address     = var.hub_azure_firewall_public_ip_address
}

# -----------------------------------------------------------------------------
# Key Vault
# -----------------------------------------------------------------------------
module "key-vault" {
  source = "./modules/key-vault"

  spoke_api_key_vault_resource_group_name = local.resource_group_name
  spoke_api_key_vault_location = var.spoke_api_location
  spoke_api_key_vault_sku_name = var.spoke_api_key_vault_sku_name
  spoke_api_subnet_wa_id = module.networking.spoke_api_networking_subnet_wa_id
  spoke_api_ag_ssl_certificate_path = var.spoke_api_ag_ssl_certificate_path
  spoke_api_ag_ssl_certificate_password = var.spoke_api_ag_ssl_certificate_password
  
  # Random suffix configuration
  spoke_api_key_vault_random_suffix_length  = var.spoke_api_key_vault_random_suffix_length
  spoke_api_key_vault_random_suffix_special = var.spoke_api_key_vault_random_suffix_special
  spoke_api_key_vault_random_suffix_upper   = var.spoke_api_key_vault_random_suffix_upper
  
  # Naming convention
  naming_company = var.naming_company
  naming_product = var.naming_product
  naming_environment = var.naming_environment
  naming_region = var.naming_region
}

# -----------------------------------------------------------------------------
# Key Vault Private Endpoint
# -----------------------------------------------------------------------------
module "key-vault-pe" {
  source = "./modules/private-endpoints/key-vault-pe"

  spoke_api_pe_key_vault_location = var.spoke_api_location
  spoke_api_pe_key_vault_resource_group_name = local.resource_group_name
  spoke_api_pe_key_vault_subnet_id = module.networking.spoke_api_networking_subnet_pe_id
  spoke_api_pe_key_vault_id = module.key-vault.spoke_api_key_vault_id
  spoke_api_pe_key_vault_pe_random_suffix_length = var.spoke_api_pe_key_vault_pe_random_suffix_length
  spoke_api_pe_key_vault_pe_random_suffix_special = var.spoke_api_pe_key_vault_pe_random_suffix_special
  spoke_api_pe_key_vault_pe_random_suffix_upper = var.spoke_api_pe_key_vault_pe_random_suffix_upper
  spoke_api_pe_key_vault_dns_group_random_suffix_length = var.spoke_api_pe_key_vault_dns_group_random_suffix_length
  spoke_api_pe_key_vault_dns_group_random_suffix_special = var.spoke_api_pe_key_vault_dns_group_random_suffix_special
  spoke_api_pe_key_vault_dns_group_random_suffix_upper = var.spoke_api_pe_key_vault_dns_group_random_suffix_upper
  naming_company = var.naming_company
  naming_product = var.naming_product
  naming_environment = var.naming_environment
  naming_region = var.naming_region
}

# -----------------------------------------------------------------------------
# Web App Backend
# -----------------------------------------------------------------------------
# Deploys the Backend Web App for the spoke API.
module "web-app-backend" {
  source = "./modules/web-app-backend"

  # Core Configuration
  spoke_api_web_app_resource_group_name = local.resource_group_name
  spoke_api_web_app_location            = var.spoke_api_location
  spoke_api_web_app_sku_name            = var.spoke_api_sku_name
  spoke_api_web_app_subnet_id           = module.networking.spoke_api_networking_subnet_wa_id
  acr_login_server                      = var.hub_acr_login_server
  acr_resource_id                       = var.hub_acr_resource_id
  backend_container_image_name          = var.backend_container_image_name
  naming_company                        = var.naming_company
  naming_product                        = var.naming_product
  naming_environment                    = var.naming_environment
  naming_region                         = var.naming_region

  # =========================================================================
  # MANAGED IDENTITY CONFIGURATION - NO SECRETS/KEYS NEEDED
  # =========================================================================
  # Only service endpoints and non-sensitive configuration for managed identity access

  # Hub Service Endpoints (from Terraform outputs - no secrets)
  hub_blob_storage_account_name    = var.hub_blob_storage_account_name
  hub_ai_search_service_name       = var.hub_ai_search_service_name
  hub_openai_custom_subdomain_name = var.hub_openai_custom_subdomain_name
  hub_postgresql_fqdn              = var.hub_postgresql_fqdn
  hub_acr_login_server             = var.hub_acr_login_server

  # Application Configuration (non-sensitive)
  azure_ai_search_index_name    = var.azure_ai_search_index_name
  azure_blob_container_path     = var.azure_blob_container_path
  azure_conversation_model_name = var.azure_conversation_model_name
  azure_openai_api_version      = var.azure_openai_api_version
  azure_refine_model_name       = var.azure_refine_model_name
  azure_embedding_model_name    = var.azure_embedding_model_name
  frontend_domain               = var.frontend_domain
  csv_top_k                     = var.csv_top_k
  images_top_k                  = var.images_top_k
  main_top_k                    = var.main_top_k
  is_dev_environment            = var.is_dev_environment
  is_using_vector_search        = var.is_using_vector_search
  score_threshold               = var.score_threshold
  second_tier_threshold         = var.second_tier_threshold
  docker_enable_ci              = var.docker_enable_ci
  websites_enable_storage       = var.websites_enable_storage

  # Application Insights (non-sensitive configuration)
  appinsights_profiler_version       = var.appinsights_profiler_version
  appinsights_snapshot_version       = var.appinsights_snapshot_version
  applicationinsights_config_content = var.applicationinsights_config_content
  applicationinsights_agent_version  = var.applicationinsights_agent_version
  diagnostic_services_version        = var.diagnostic_services_version
  instrumentation_engine_version     = var.instrumentation_engine_version
  snapshot_debugger_version          = var.snapshot_debugger_version
  app_insights_base_extensions       = var.app_insights_base_extensions
  app_insights_mode                  = var.app_insights_mode
  app_insights_preempt_sdk           = var.app_insights_preempt_sdk

  # =========================================================================
  # COMMENTED OUT: ALL SECRET/KEY-BASED AUTHENTICATION
  # =========================================================================
  # These are replaced by managed identity authentication

  # admin_account_email                   = var.admin_account_email
  # admin_account_password                = var.admin_account_password
  # appinsights_instrumentation_key       = var.appinsights_instrumentation_key
  # applicationinsights_connection_string = var.applicationinsights_connection_string
  # azure_ai_search_endpoint              = var.azure_ai_search_endpoint
  # azure_ai_search_query_key             = var.azure_ai_search_query_key
  # azure_blob_base_url                   = var.azure_blob_base_url
  # azure_openai_base_url                 = var.azure_openai_base_url
  # azure_openai_key                      = var.azure_openai_key
  # azure_email_connection_string         = var.azure_email_connection_string
  # azure_email_sender                    = var.azure_email_sender
  # azure_storage_account_key             = var.azure_storage_account_key
  # azure_storage_account_name            = var.azure_storage_account_name
  # azure_storage_connection_string       = var.azure_storage_connection_string
  # azure_workflow_job_id                 = var.azure_workflow_job_id
  # database_url                          = var.database_url
  # databricks_access_token               = var.databricks_access_token
  # databricks_catalog_name               = var.databricks_catalog_name
  # databricks_job_base_url               = var.databricks_job_base_url
  # databricks_job_jwt_token              = var.databricks_job_jwt_token
  # databricks_vector_base_url            = var.databricks_vector_base_url
  # databricks_vector_jwt_token           = var.databricks_vector_jwt_token
  # default_password                      = var.default_password
  # hub_postgresql_admin_login            = var.hub_postgresql_admin_login
  # hub_postgresql_admin_password         = var.hub_postgresql_admin_password
}

# -----------------------------------------------------------------------------
# Web App Frontend
# -----------------------------------------------------------------------------
# Deploys the Frontend Web App for the spoke API.
module "web-app-frontend" {
  source = "./modules/web-app-frontend"

  # Core Configuration
  spoke_api_frontend_resource_group_name = local.resource_group_name
  spoke_api_frontend_location            = var.spoke_api_location
  spoke_api_frontend_sku_name            = var.spoke_api_frontend_sku_name
  spoke_api_frontend_subnet_id           = module.networking.spoke_api_networking_subnet_wa_id
  acr_login_server                       = var.hub_acr_login_server
  frontend_container_image_name          = var.frontend_container_image_name
  naming_company                         = var.naming_company
  naming_product                         = var.naming_product
  naming_environment                     = var.naming_environment
  naming_region                          = var.naming_region

  # Frontend Configuration
  backend_api_url      = "https://${var.spoke_api_ag_private_ip_address}"
  backend_api_base_url = "https://${var.spoke_api_ag_private_ip_address}/api"
  frontend_domain      = var.frontend_domain
  frontend_node_env    = var.frontend_node_env
  frontend_port        = var.frontend_port

  # Application Insights Configuration
  appinsights_instrumentation_key       = var.appinsights_instrumentation_key
  appinsights_profiler_version          = var.appinsights_profiler_version
  appinsights_snapshot_version          = var.appinsights_snapshot_version
  applicationinsights_config_content    = var.applicationinsights_config_content
  applicationinsights_connection_string = var.applicationinsights_connection_string
  applicationinsights_agent_version     = var.applicationinsights_agent_version

  # Environment Configuration
  is_dev_environment           = var.is_dev_environment
  diagnostic_services_version  = var.diagnostic_services_version
  docker_enable_ci             = var.docker_enable_ci
  app_insights_base_extensions = var.app_insights_base_extensions
  app_insights_mode            = var.app_insights_mode
  app_insights_preempt_sdk     = var.app_insights_preempt_sdk
}

# -----------------------------------------------------------------------------
# Application Gateway
# -----------------------------------------------------------------------------
# Deploys the Application Gateway for the spoke API.
module "application_gateway" {
  source                                           = "./modules/application-gateway"
  spoke_api_ag_resource_group_name                 = local.resource_group_name
  spoke_api_ag_location                            = var.spoke_api_location
  spoke_api_ag_subnet_id                           = module.networking.spoke_api_networking_subnet_ag_id
  web_app_fqdn                                     = "${module.web-app-backend.spoke_api_web_app_name}.azurewebsites.net"
  web_app_private_ip                               = module.web-app-pe.spoke_api_pe_web_app_private_endpoint_ip
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
  naming_company                                   = var.naming_company
  naming_product                                   = var.naming_product
  naming_environment                               = var.naming_environment
  naming_region                                    = var.naming_region
  spoke_api_ag_frontend_protocol                   = var.spoke_api_ag_frontend_protocol
  spoke_api_ag_waf_sku_name                        = var.spoke_api_ag_waf_sku_name
  spoke_api_ag_waf_sku_tier                        = var.spoke_api_ag_waf_sku_tier

  # SSL Configuration
  spoke_api_ag_frontend_port_http       = var.spoke_api_ag_frontend_port_http
  spoke_api_ag_ssl_certificate_name     = var.spoke_api_ag_ssl_certificate_name
  spoke_api_ag_ssl_certificate_path     = var.spoke_api_ag_ssl_certificate_path
  spoke_api_ag_ssl_certificate_password = var.spoke_api_ag_ssl_certificate_password
  # spoke_api_ag_ssl_certificate_key_vault_secret_id = module.key-vault.spoke_api_key_vault_certificate_secret_id

  app_gateway_identity_id = var.app_gateway_identity_id

  depends_on = [module.web-app-backend, module.web-app-pe]
}

# Web App Private Endpoint
module "web-app-pe" {
  source                                   = "./modules/private-endpoints/web-app-pe"
  spoke_api_pe_web_app_resource_group_name = local.resource_group_name
  spoke_api_pe_web_app_location            = var.spoke_api_location
  spoke_api_pe_web_app_id                  = module.web-app-backend.spoke_api_web_app_id
  spoke_api_pe_web_app_vnet_id             = module.networking.spoke_api_networking_vnet_id
  spoke_api_pe_web_app_subnet_id           = module.networking.spoke_api_networking_subnet_pe_id
  naming_company                           = var.naming_company
  naming_product                           = var.naming_product
  naming_environment                       = var.naming_environment
  naming_region                            = var.naming_region
}
