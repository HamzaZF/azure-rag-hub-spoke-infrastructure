variable "spoke_api_resource_group_name" {
  description = "The name of the resource group for API spoke resources."
  type        = string
}

variable "spoke_api_location" {
  description = "The Azure region where API spoke resources will be deployed."
  type        = string
}

# Hub ACR References
variable "hub_acr_login_server" {
  description = "The login server for the hub Azure Container Registry."
  type        = string
}

variable "hub_acr_resource_id" {
  description = "The resource ID for the hub Azure Container Registry."
  type        = string
}

variable "hub_acr_name" {
  description = "The name of the hub Azure Container Registry."
  type        = string
}

# Application Gateway Configuration
variable "spoke_api_ag_public_ip_allocation_method" {
  description = "The allocation method for the API spoke Application Gateway public IP address."
  type        = string
  default     = "Static"
}

variable "spoke_api_ag_public_ip_sku" {
  description = "The SKU for the API spoke Application Gateway public IP address."
  type        = string
  default     = "Standard"
}

variable "spoke_api_ag_public_ip_sku_tier" {
  description = "The SKU tier for the API spoke Application Gateway public IP address."
  type        = string
  default     = "Global"
}

variable "spoke_api_ag_frontend_protocol" {
  description = "The frontend protocol for the API spoke Application Gateway."
  type        = string
}

# Private IP address for Application Gateway (internal access only)
variable "spoke_api_ag_private_ip_address" {
  description = "The private IP address for the Application Gateway frontend (internal access via VNet integration)."
  type        = string
  default     = "10.1.0.10"
}

variable "spoke_api_ag_autoscale_min_capacity" {
  description = "The minimum capacity for API spoke Application Gateway autoscaling."
  type        = number
  default     = 1
}

variable "spoke_api_ag_autoscale_max_capacity" {
  description = "The maximum capacity for API spoke Application Gateway autoscaling."
  type        = number
  default     = 2
}

variable "spoke_api_ag_frontend_port" {
  description = "The frontend port for the API spoke Application Gateway."
  type        = number
  default     = 80
}

variable "spoke_api_ag_backend_port" {
  description = "The backend port for the API spoke Application Gateway."
  type        = number
  default     = 443
}

variable "spoke_api_ag_backend_protocol" {
  description = "The backend protocol for the API spoke Application Gateway."
  type        = string
  default     = "Https"
}

variable "spoke_api_ag_request_timeout" {
  description = "The request timeout for the API spoke Application Gateway backend settings."
  type        = number
  default     = 60
}

variable "spoke_api_ag_probe_interval" {
  description = "The interval for API spoke Application Gateway health probe."
  type        = number
  default     = 30
}

variable "spoke_api_ag_probe_timeout" {
  description = "The timeout for API spoke Application Gateway health probe."
  type        = number
  default     = 30
}

variable "spoke_api_ag_probe_unhealthy_threshold" {
  description = "The unhealthy threshold for API spoke Application Gateway health probe."
  type        = number
  default     = 3
}

variable "spoke_api_ag_probe_path" {
  description = "The path for API spoke Application Gateway health probe."
  type        = string
  default     = "/healthcheck"
}

variable "spoke_api_ag_waf_policy_mode" {
  description = "The mode for the API spoke Application Gateway WAF policy."
  type        = string
  default     = "Prevention"
}

variable "spoke_api_ag_waf_policy_managed_rule_set_type" {
  description = "The managed rule set type for the API spoke Application Gateway WAF policy."
  type        = string
  default     = "OWASP"
}

variable "spoke_api_ag_waf_policy_managed_rule_set_version" {
  description = "The managed rule set version for the API spoke Application Gateway WAF policy."
  type        = string
  default     = "3.2"
}

variable "spoke_api_sku_name" {
  description = "The SKU name for the service plan in the API spoke (e.g., B1, S1, P1v2)"
  type        = string
}

# -----------------------------------------------------------------------------
# Frontend Web App Configuration
# -----------------------------------------------------------------------------

variable "spoke_api_frontend_sku_name" {
  description = "The SKU name for the frontend service plan in the API spoke (e.g., B1, S1, P1v2)"
  type        = string
  default     = "B1"
}

variable "frontend_container_image_name" {
  description = "The name of the frontend container image to deploy."
  type        = string
  default     = "kelix-audit-frontend:latest"
}

variable "frontend_node_env" {
  description = "Node.js environment for the frontend application."
  type        = string
  default     = "production"
}

variable "frontend_port" {
  description = "Port for the frontend application."
  type        = string
  default     = "3000"
}

variable "spoke_api_vnet_address_space" {
  description = "The address space for the API spoke virtual network"
  type        = list(string)
}

variable "spoke_api_ag_subnet_prefix" {
  description = "The address prefix for the Application Gateway subnet in the API spoke"
  type        = string
}

variable "spoke_api_pe_subnet_prefix" {
  description = "The address prefix for the private endpoints subnet in the API spoke"
  type        = string
}

variable "spoke_api_wa_subnet_prefix" {
  description = "The address prefix for the web application subnet in the API spoke"
  type        = string
}

# -----------------------------------------------------------------------------
# Hub Resource IDs (for cross-resource access)
# -----------------------------------------------------------------------------

# REMOVED FOR MANAGED IDENTITY - No longer need resource IDs
# These are replaced by service names for managed identity access:
# - hub_blob_storage_account_name
# - hub_ai_search_service_name  
# - hub_openai_service_name

# The address prefix for the hub private endpoints subnet to allow cross-VNet access
variable "hub_networking_pe_subnet_prefix" {
  description = "The address prefix for the hub private endpoints subnet to allow cross-VNet access."
  type        = string
}

# Hub PostgreSQL Configuration
variable "hub_postgresql_fqdn" {
  description = "Hub PostgreSQL server FQDN."
  type        = string
}

# REMOVED FOR MANAGED IDENTITY - No longer need PostgreSQL admin credentials
# - hub_postgresql_admin_login  (REMOVED - using managed identity)
# - hub_postgresql_admin_password  (REMOVED - using managed identity)

# Container configuration
variable "backend_container_image_name" {
  description = "The name of the container image to deploy (e.g., myapp:latest)."
  type        = string
  //default     = "kelix-audit-backend:latest"
}

variable "spoke_api_ag_waf_sku_name" {
  description = "The WAF SKU name for the API spoke Application Gateway."
  type        = string
}

variable "spoke_api_ag_waf_sku_tier" {
  description = "The WAF SKU tier for the API spoke Application Gateway."
  type        = string
}

# -----------------------------------------------------------------------------
# Application Gateway SSL Configuration
# -----------------------------------------------------------------------------

# Application Gateway is hardcoded to public IP with SSL - removed configurable variables

variable "spoke_api_ag_frontend_port_http" {
  description = "The HTTP frontend port for the Application Gateway (for redirect)."
  type        = number
  default     = 80
}

variable "spoke_api_ag_ssl_certificate_name" {
  description = "The name for the SSL certificate in Application Gateway."
  type        = string
  default     = "kelix-api-ssl-cert"
}

variable "spoke_api_ag_ssl_certificate_path" {
  description = "The path to the SSL certificate PFX file."
  type        = string
}

variable "spoke_api_ag_ssl_certificate_password" {
  description = "The password for the SSL certificate PFX file."
  type        = string
  sensitive   = true
}


# -----------------------------------------------------------------------------
# Naming Variables
# -----------------------------------------------------------------------------

variable "naming_company" {
  description = "Company name for naming convention."
  type        = string
}

variable "naming_product" {
  description = "Product name for naming convention."
  type        = string
}

variable "naming_environment" {
  description = "Environment name for naming convention."
  type        = string
}

variable "naming_region" {
  description = "Region for naming convention."
  type        = string
}

# =============================================================================
# CROSS-SPOKE NETWORKING INTEGRATION
# =============================================================================

variable "spoke_ai_vnet_address_space" {
  description = "The address space for the AI spoke virtual network for security rules."
  type        = list(string)
}

# -----------------------------------------------------------------------------
# Container Image Building
# -----------------------------------------------------------------------------

# ACR Configuration
variable "acr_webhook_scope" {
  description = "The scope for the ACR webhook (e.g., image:tag)."
  type        = string
  default     = "kelix-audit-backend:*"
}

variable "acr_webhook_status" {
  description = "The status of the ACR webhook (enabled or disabled)."
  type        = string
  default     = "enabled"
}

# List of IP addresses allowed to access the Application Gateway (Static Web App IPs)
variable "static_web_app_allowed_ips" {
  description = "List of IP addresses allowed to access the Application Gateway (Static Web App outbound IPs)."
  type        = list(string)
  # default     = ["0.0.0.0/0"]  # Temporarily allow all, should be updated with actual Static Web App IPs
}

# -----------------------------------------------------------------------------
# Web App Application Configuration Variables
# -----------------------------------------------------------------------------

# Admin Configuration
variable "admin_account_email" {
  description = "Admin account email for the application."
  type        = string
  sensitive   = true
}

variable "admin_account_password" {
  description = "Admin account password for the application."
  type        = string
  sensitive   = true
}

# Application Insights Configuration
variable "appinsights_instrumentation_key" {
  description = "Application Insights instrumentation key."
  type        = string
  sensitive   = true
}

variable "applicationinsights_connection_string" {
  description = "Application Insights connection string."
  type        = string
  sensitive   = true
}

# Application Insights Configuration (Extended)
variable "appinsights_profiler_version" {
  description = "Application Insights profiler feature version."
  type        = string
  default     = "1.0.0"
}

variable "appinsights_snapshot_version" {
  description = "Application Insights snapshot feature version."
  type        = string
  default     = "1.0.0"
}

variable "applicationinsights_config_content" {
  description = "Application Insights configuration content."
  type        = string
  default     = ""
}

variable "applicationinsights_agent_version" {
  description = "Application Insights agent extension version."
  type        = string
  default     = "~3"
}

# Azure AI Search Configuration
variable "azure_ai_search_endpoint" {
  description = "Azure AI Search service endpoint."
  type        = string
}

variable "azure_ai_search_query_key" {
  description = "Azure AI Search service query key."
  type        = string
  sensitive   = true
}

# Azure AI Search Configuration (Extended)
variable "azure_ai_search_index_name" {
  description = "Azure AI Search service index name."
  type        = string
  default     = "keazuretable-index"
}

# Azure Blob Storage Configuration
variable "azure_blob_base_url" {
  description = "Azure Blob storage base URL."
  type        = string
}

# Azure Blob Storage Configuration (Extended)
variable "azure_blob_container_path" {
  description = "Azure Blob container file path."
  type        = string
  default     = "projects"
}

# Azure OpenAI Configuration
variable "azure_openai_base_url" {
  description = "Azure OpenAI base URL."
  type        = string
}

variable "azure_openai_key" {
  description = "Azure OpenAI API key."
  type        = string
  sensitive   = true
}

# Azure OpenAI Configuration (Extended)
variable "azure_conversation_model_name" {
  description = "Azure OpenAI conversation model deployment name."
  type        = string
  default     = "gpt-4o-mini-chat"
}

variable "azure_openai_api_version" {
  description = "Azure OpenAI API version."
  type        = string
  default     = "2024-10-21"
}

variable "azure_refine_model_name" {
  description = "Azure OpenAI refine model deployment name."
  type        = string
  default     = "gpt-4o-mini-chat"
}

variable "azure_embedding_model_name" {
  description = "Azure OpenAI embedding model deployment name."
  type        = string
  default     = "text-embedding-3-small"
}

# Azure Email Configuration
variable "azure_email_connection_string" {
  description = "Azure Email communication service connection string."
  type        = string
  sensitive   = true
}

# Azure Email Configuration (Extended)
variable "azure_email_sender" {
  description = "Azure Email sender address."
  type        = string
  default     = "DoNotReply@kelix.ai"
}

# Application Configuration
variable "csv_top_k" {
  description = "Top K value for CSV processing."
  type        = string
  default     = "3"
}

# Azure Storage Account Configuration
variable "azure_storage_account_key" {
  description = "Azure Storage account key."
  type        = string
  sensitive   = true
}

variable "azure_storage_account_name" {
  description = "Azure Storage account name."
  type        = string
}

variable "azure_storage_connection_string" {
  description = "Azure Storage connection string."
  type        = string
  sensitive   = true
}

# Azure Logic Apps Configuration
variable "azure_workflow_job_id" {
  description = "Azure Logic Apps workflow job ID for document ingestion."
  type        = string
}

# Database Configuration
variable "database_url" {
  description = "Database connection URL."
  type        = string
  sensitive   = true
}

# Databricks Configuration
variable "databricks_access_token" {
  description = "Databricks access token."
  type        = string
  sensitive   = true
}

variable "databricks_job_base_url" {
  description = "Databricks job trigger base URL."
  type        = string
}

variable "databricks_job_jwt_token" {
  description = "Databricks job JWT token."
  type        = string
  sensitive   = true
}

variable "databricks_vector_base_url" {
  description = "Databricks vector search base URL."
  type        = string
}

variable "databricks_vector_jwt_token" {
  description = "Databricks vector search JWT token."
  type        = string
  sensitive   = true
}

# Databricks Configuration (Extended)
variable "databricks_catalog_name" {
  description = "Databricks catalog name."
  type        = string
  default     = "catalog"
}

# Extensions Configuration
variable "diagnostic_services_version" {
  description = "Diagnostic services extension version."
  type        = string
  default     = "~3"
}

# Docker Configuration
variable "docker_enable_ci" {
  description = "Enable Docker CI."
  type        = string
  default     = "true"
}

# Search Configuration
variable "images_top_k" {
  description = "Top K value for image search."
  type        = string
  default     = "3"
}

variable "main_top_k" {
  description = "Main top K value for search."
  type        = string
  default     = "10"
}

# Monitoring Configuration
variable "instrumentation_engine_version" {
  description = "Instrumentation engine extension version."
  type        = string
  default     = "disabled"
}

# Environment Configuration
variable "is_dev_environment" {
  description = "Whether this is a development environment."
  type        = string
  default     = "False"
}

variable "is_using_vector_search" {
  description = "Whether to use Azure AI Search vector search."
  type        = string
  default     = "True"
}

# Score Configuration
variable "score_threshold" {
  description = "Score threshold for search results."
  type        = string
  default     = "2.0"
}

variable "second_tier_threshold" {
  description = "Second tier threshold for search results."
  type        = string
  default     = "1.0"
}

# Debug Configuration
variable "snapshot_debugger_version" {
  description = "Snapshot debugger extension version."
  type        = string
  default     = "disabled"
}

# Storage Configuration
variable "websites_enable_storage" {
  description = "Enable websites app service storage."
  type        = string
  default     = "false"
}

# Application Insights Advanced Configuration
variable "app_insights_base_extensions" {
  description = "Application Insights base extensions configuration."
  type        = string
  default     = "disabled"
}

variable "app_insights_mode" {
  description = "Application Insights mode."
  type        = string
  default     = "recommended"
}

variable "app_insights_preempt_sdk" {
  description = "Application Insights preempt SDK configuration."
  type        = string
  default     = "disabled"
}

# Security Configuration
variable "default_password" {
  description = "Default password for application."
  type        = string
  sensitive   = true
  default     = "ChangeMe123!"
}

# Frontend Configuration
variable "frontend_domain" {
  description = "Frontend domain URL."
  type        = string
  default     = "https://portal.kelix.ai/"
}

# =============================================================================
# HUB SERVICE ENDPOINTS FOR MANAGED IDENTITY ACCESS - NO DEFAULTS
# =============================================================================

variable "hub_blob_storage_account_name" {
  description = "The name of the hub blob storage account for managed identity access."
  type        = string
}

variable "hub_ai_search_service_name" {
  description = "The name of the hub AI search service for managed identity access."
  type        = string
}

# variable "hub_openai_service_name" {
#   description = "The name of the hub OpenAI service for managed identity access."
#   type        = string
# }

variable "hub_openai_custom_subdomain_name" {
  description = "The custom subdomain name for the hub OpenAI service for managed identity access."
  type        = string
}

# =============================================================================

variable "spoke_api_key_vault_sku_name" {
  description = "The SKU name for the key vault."
  type        = string
}

variable "spoke_api_pe_key_vault_pe_random_suffix_length" {
  description = "The length of the random suffix for the key vault private endpoint."
  type        = number
}

variable "spoke_api_pe_key_vault_pe_random_suffix_special" {
  description = "The special characters for the key vault private endpoint random suffix."
  type        = string
}

variable "spoke_api_pe_key_vault_pe_random_suffix_upper" {
  description = "The uppercase characters for the key vault private endpoint random suffix."
  type        = string
}

variable "spoke_api_pe_key_vault_dns_group_random_suffix_length" {
  description = "The length of the random suffix for the key vault private endpoint DNS group."
  type        = number
}

variable "spoke_api_pe_key_vault_dns_group_random_suffix_special" {
  description = "The special characters for the key vault private endpoint DNS group random suffix."
  type        = string
}

variable "spoke_api_pe_key_vault_dns_group_random_suffix_upper" {
  description = "The uppercase characters for the key vault private endpoint DNS group random suffix."
  type = string
}

/*
define variables for
var.spoke_api_key_vault_random_suffix_length
var.spoke_api_key_vault_random_suffix_special
var.spoke_api_key_vault_random_suffix_upper
*/

variable "spoke_api_key_vault_random_suffix_length" {
  description = "The length of the random suffix for the key vault."
  type        = number
}

variable "spoke_api_key_vault_random_suffix_special" {
  description = "The special characters for the key vault random suffix."
  type        = string
}

variable "spoke_api_key_vault_random_suffix_upper" {
  description = "The uppercase characters for the key vault random suffix."
  type        = string
}

# -----------------------------------------------------------------------------

variable "spoke_api_networking_route_table_random_suffix_length" {
  description = "The length of the random suffix for the route table name."
  type        = number
  default     = 4
}

variable "spoke_api_networking_route_table_random_suffix_special" {
  description = "Whether to include special characters in the route table random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_networking_route_table_random_suffix_upper" {
  description = "Whether to include uppercase letters in the route table random suffix."
  type        = bool
  default     = false
}

variable "hub_azure_firewall_public_ip_address" {
  description = "The public IP address of the Azure Firewall."
  type        = string
}

variable "app_gateway_identity_id" {
  description = "The ID of the user assigned identity for the Application Gateway."
  type        = string
}