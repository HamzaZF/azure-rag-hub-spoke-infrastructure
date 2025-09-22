/*
  variables.tf (Spoke API Web App Backend - MANAGED IDENTITY VERSION)

  This file defines ONLY the variables needed for managed identity access.
  ALL SECRET-BASED VARIABLES HAVE BEEN REMOVED.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the Web App resources will be deployed.
variable "spoke_api_web_app_location" {
  description = "The Azure region where the Web App resources will be deployed."
  type        = string
}

# The name of the resource group where the Web App resources will be created.
variable "spoke_api_web_app_resource_group_name" {
  description = "The name of the resource group where the Web App resources will be created."
  type        = string
}

# The SKU name for the spoke API web app (e.g., B1, S1).
variable "spoke_api_web_app_sku_name" {
  description = "The SKU name for the spoke API web app (e.g., B1, S1)."
  type        = string
}

# The subnet ID for the web app virtual network integration.
variable "spoke_api_web_app_subnet_id" {
  description = "The subnet ID for the web app virtual network integration."
  type        = string
}

# Random suffix configuration for service plan
variable "spoke_api_web_app_service_plan_random_suffix_length" {
  description = "The length of the random suffix for the service plan name."
  type        = number
  default     = 4
}

variable "spoke_api_web_app_service_plan_random_suffix_special" {
  description = "Whether to include special characters in the service plan random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_web_app_service_plan_random_suffix_upper" {
  description = "Whether to include uppercase letters in the service plan random suffix."
  type        = bool
  default     = false
}

# Random suffix configuration for web app
variable "spoke_api_web_app_random_suffix_length" {
  description = "The length of the random suffix for the web app name."
  type        = number
  default     = 4
}

variable "spoke_api_web_app_random_suffix_special" {
  description = "Whether to include special characters in the web app random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_web_app_random_suffix_upper" {
  description = "Whether to include uppercase letters in the web app random suffix."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Container Configuration
# -----------------------------------------------------------------------------

# The login server for the Azure Container Registry.
variable "acr_login_server" {
  description = "The login server for the Azure Container Registry."
  type        = string
}

# The name of the container image to deploy.
variable "backend_container_image_name" {
  description = "The name of the container image to deploy."
  type        = string
}

# The resource ID of the Azure Container Registry for role assignment.
variable "acr_resource_id" {
  description = "The resource ID of the Azure Container Registry for role assignment."
  type        = string
}

# =============================================================================
# HUB SERVICE ENDPOINTS FOR MANAGED IDENTITY ACCESS - NO SECRETS
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

variable "hub_postgresql_fqdn" {
  description = "The FQDN of the hub PostgreSQL server for managed identity access."
  type        = string
}

variable "hub_acr_login_server" {
  description = "The login server for the hub Azure Container Registry."
  type        = string
}

# -----------------------------------------------------------------------------
# Application Configuration (NON-SENSITIVE ONLY)
# -----------------------------------------------------------------------------

variable "azure_ai_search_index_name" {
  description = "Azure AI Search service index name."
  type        = string
}

variable "azure_blob_container_path" {
  description = "Azure Blob container file path."
  type        = string
}

variable "azure_conversation_model_name" {
  description = "Azure OpenAI conversation model deployment name."
  type        = string
}

variable "azure_openai_api_version" {
  description = "Azure OpenAI API version."
  type        = string
}

variable "azure_refine_model_name" {
  description = "Azure OpenAI refine model deployment name."
  type        = string
}

variable "azure_embedding_model_name" {
  description = "Azure OpenAI embedding model deployment name."
  type        = string
}

variable "frontend_domain" {
  description = "Frontend domain URL."
  type        = string
}

variable "csv_top_k" {
  description = "Top K value for CSV processing."
  type        = string
}

variable "images_top_k" {
  description = "Top K value for image search."
  type        = string
}

variable "main_top_k" {
  description = "Main top K value for search."
  type        = string
}

variable "score_threshold" {
  description = "Score threshold for search results."
  type        = string
}

variable "second_tier_threshold" {
  description = "Second tier threshold for search results."
  type        = string
}

variable "is_dev_environment" {
  description = "Whether this is a development environment."
  type        = string
}

variable "is_using_vector_search" {
  description = "Whether to use Azure AI Search vector search."
  type        = string
}

variable "docker_enable_ci" {
  description = "Enable Docker CI."
  type        = string
}

variable "websites_enable_storage" {
  description = "Enable websites app service storage."
  type        = string
}

# -----------------------------------------------------------------------------
# Application Insights Configuration (NON-SENSITIVE)
# -----------------------------------------------------------------------------

variable "appinsights_profiler_version" {
  description = "Application Insights profiler feature version."
  type        = string
}

variable "appinsights_snapshot_version" {
  description = "Application Insights snapshot feature version."
  type        = string
}

variable "applicationinsights_config_content" {
  description = "Application Insights configuration content."
  type        = string
}

variable "applicationinsights_agent_version" {
  description = "Application Insights agent extension version."
  type        = string
}

variable "diagnostic_services_version" {
  description = "Diagnostic services extension version."
  type        = string
}

variable "instrumentation_engine_version" {
  description = "Instrumentation engine extension version."
  type        = string
}

variable "snapshot_debugger_version" {
  description = "Snapshot debugger extension version."
  type        = string
}

variable "app_insights_base_extensions" {
  description = "Application Insights base extensions configuration."
  type        = string
}

variable "app_insights_mode" {
  description = "Application Insights mode."
  type        = string
}

variable "app_insights_preempt_sdk" {
  description = "Application Insights preempt SDK configuration."
  type        = string
}

# -----------------------------------------------------------------------------
# Naming Convention
# -----------------------------------------------------------------------------

variable "naming_company" {
  description = "Company or organization name for resource naming."
  type        = string
}

variable "naming_product" {
  description = "Product or application name for resource naming."
  type        = string
}

variable "naming_environment" {
  description = "Deployment environment (e.g., dev, staging, prod) for resource naming."
  type        = string
}

variable "naming_region" {
  description = "Azure region for resource naming."
  type        = string
}

# =============================================================================
# REMOVED: ALL SECRET-BASED VARIABLES FOR MANAGED IDENTITY MIGRATION
# =============================================================================
#
# The following variables have been REMOVED because we now use managed identity:
# - admin_account_email (SECRET)
# - admin_account_password (SECRET)  
# - appinsights_instrumentation_key (SECRET)
# - applicationinsights_connection_string (SECRET)
# - azure_ai_search_endpoint (SECRET-based)
# - azure_ai_search_query_key (SECRET)
# - azure_blob_base_url (SECRET-based)
# - azure_openai_base_url (SECRET-based)
# - azure_openai_key (SECRET)
# - azure_email_connection_string (SECRET)
# - azure_storage_account_key (SECRET)
# - azure_storage_account_name (SECRET-based)
# - azure_storage_connection_string (SECRET)
# - azure_workflow_job_id (SECRET-based)
# - database_url (SECRET)
# - databricks_access_token (SECRET)
# - databricks_job_base_url (SECRET-based)
# - databricks_job_jwt_token (SECRET)
# - databricks_vector_base_url (SECRET-based)
# - databricks_vector_jwt_token (SECRET)
# - hub_postgresql_admin_login (SECRET)
# - hub_postgresql_admin_password (SECRET)
# - default_password (SECRET)
# - azure_email_sender (SECRET-based)
# - databricks_catalog_name (SECRET-based)
#
# All authentication now uses Azure AD Managed Identity!