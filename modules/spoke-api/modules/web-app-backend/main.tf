module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "backend"]
  suffix = [var.naming_region]
}

resource "azurerm_service_plan" "plan" {
  name                = "${module.naming.app_service_plan.name}-${random_string.service_plan_suffix.result}"
  resource_group_name = var.spoke_api_web_app_resource_group_name
  location            = var.spoke_api_web_app_location
  sku_name            = var.spoke_api_web_app_sku_name
  os_type             = "Linux"
}

resource "random_string" "service_plan_suffix" {
  length  = var.spoke_api_web_app_service_plan_random_suffix_length
  special = var.spoke_api_web_app_service_plan_random_suffix_special
  upper   = var.spoke_api_web_app_service_plan_random_suffix_upper
}

resource "azurerm_linux_web_app" "app" {
  name                          = "${module.naming.app_service.name}-${random_string.web_app_suffix.result}"
  resource_group_name           = var.spoke_api_web_app_resource_group_name
  location                      = var.spoke_api_web_app_location
  service_plan_id               = azurerm_service_plan.plan.id
  public_network_access_enabled = false

  site_config {
    always_on                               = true
    container_registry_use_managed_identity = true
    
    
    # container_registry_managed_identity_client_id = azurerm_linux_web_app.app.identity[0].principal_id

    # Container configuration
    application_stack {
      docker_image_name   = var.backend_container_image_name
      docker_registry_url = "https://${var.acr_login_server}"
    }
  }

  # =========================================================================
  # MANAGED IDENTITY ENVIRONMENT VARIABLES - NO SECRETS/KEYS
  # =========================================================================
  app_settings = {

    # -------------------------------------------------------------------------
    # Continuous deployment configuration
    # -------------------------------------------------------------------------

    #"DOCKER_ENABLE_CI" = "true"

    # -------------------------------------------------------------------------
    # Azure Service Endpoints (Managed Identity Access)
    # -------------------------------------------------------------------------
    
    # Azure Blob Storage (Hub) - Managed Identity Access
    AZURE_STORAGE_ACCOUNT_NAME = var.hub_blob_storage_account_name
    AZURE_STORAGE_ENDPOINT     = "https://${var.hub_blob_storage_account_name}.blob.core.windows.net"
    AZURE_BLOB_CONTAINER_PATH  = var.azure_blob_container_path
    
    # Azure AI Search (Hub) - Managed Identity Access  
    AZURE_SEARCH_ENDPOINT   = "https://${var.hub_ai_search_service_name}.search.windows.net"
    # AZURE_SEARCH_INDEX_NAME = var.azure_ai_search_index_name
    
    # Azure OpenAI (Hub) - Managed Identity Access
    # AZURE_OPENAI_ENDPOINT                     = "https://${var.hub_openai_service_name}.openai.azure.com"
    # AZURE_OPENAI_ENDPOINT                     = "https://your-openai-instance.openai.azure.com">
    AZURE_OPENAI_ENDPOINT                     = "https://${var.hub_openai_custom_subdomain_name}.openai.azure.com"
    AZURE_OPENAI_API_VERSION                  = var.azure_openai_api_version
    AZURE_CONVERSATION_MODEL_DEPLOYMENT_NAME  = var.azure_conversation_model_name
    AZURE_REFINE_WITH_AI_DEPLOYMENT_NAME      = var.azure_refine_model_name
    AZURE_EMBEDDING_MODEL_DEPLOYMENT_NAME     = var.azure_embedding_model_name
    
    # PostgreSQL (Hub) - Managed Identity Access
    POSTGRES_HOST       = var.hub_postgresql_fqdn
    POSTGRES_DB         = "postgres"
    POSTGRES_PORT       = "5432"
    # Note: No POSTGRES_USER/PASSWORD - using managed identity
    
    # Azure Container Registry (Hub) - Managed Identity Access
    AZURE_CONTAINER_REGISTRY_URL = var.hub_acr_login_server
    
    # -------------------------------------------------------------------------
    # Application Configuration (Non-Sensitive)
    # -------------------------------------------------------------------------
    
    # Container port configuration
    PORT          = "3000"
    WEBSITES_PORT = "3000"
    
    # Frontend Configuration
    FRONTEND_DOMAIN = var.frontend_domain
    
    # Application Configuration
    APP_SERVICE_BACKEND_NAME = "${module.naming.app_service.name}-${random_string.web_app_suffix.result}"
    CSV_TOP_K     = var.csv_top_k
    IMAGES_TOP_K  = var.images_top_k
    MAIN_TOP_K    = var.main_top_k
    
    # Search Configuration
    SCORE_THRESHOLD                           = var.score_threshold
    SECOND_TIER_THRESHOLD                     = var.second_tier_threshold
    IS_USING_AZURE_AI_SEARCH_VECTOR_SEARCH    = var.is_using_vector_search
    
    # Environment Configuration
    IS_DEV        = var.is_dev_environment
    DOCKER_ENABLE_CI = var.docker_enable_ci
    
    # Storage Configuration
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = var.websites_enable_storage
    
    # -------------------------------------------------------------------------
    # Application Insights (Non-Sensitive Configuration)
    # -------------------------------------------------------------------------
    APPINSIGHTS_PROFILERFEATURE_VERSION        = var.appinsights_profiler_version
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION        = var.appinsights_snapshot_version
    APPLICATIONINSIGHTS_CONFIGURATION_CONTENT  = var.applicationinsights_config_content
    ApplicationInsightsAgent_EXTENSION_VERSION = var.applicationinsights_agent_version
    DiagnosticServices_EXTENSION_VERSION       = var.diagnostic_services_version
    InstrumentationEngine_EXTENSION_VERSION    = var.instrumentation_engine_version
    SnapshotDebugger_EXTENSION_VERSION         = var.snapshot_debugger_version
    XDT_MicrosoftApplicationInsights_BaseExtensions = var.app_insights_base_extensions
    XDT_MicrosoftApplicationInsights_Mode           = var.app_insights_mode
    XDT_MicrosoftApplicationInsights_PreemptSdk     = var.app_insights_preempt_sdk
    
    # -------------------------------------------------------------------------
    # COMMENTED OUT: ALL SECRET/KEY-BASED ENVIRONMENT VARIABLES
    # -------------------------------------------------------------------------
    # The following variables contain secrets/keys and are replaced by managed identity:
    
    # ADMIN_ACCOUNT_EMAIL                        = var.admin_account_email
    # ADMIN_ACCOUNT_PASSWORD                     = var.admin_account_password
    # APPINSIGHTS_INSTRUMENTATIONKEY             = var.appinsights_instrumentation_key
    # APPLICATIONINSIGHTS_CONNECTION_STRING      = var.applicationinsights_connection_string
    # AZURE_AI_SEARCH_SERVICE_QUERY_KEY          = var.azure_ai_search_query_key
    # AZURE_OPEN_AI_KEY                          = var.azure_openai_key
    # AZURE_EMAIL_CONNECTION_STRING              = var.azure_email_connection_string
    # AZURE_EMAIL_SENDER                         = var.azure_email_sender
    # AZURE_STORAGE_ACCOUNT_KEY                  = var.azure_storage_account_key
    # AZURE_STORAGE_CONNECTION_STRING            = var.azure_storage_connection_string
    # AZURE_WORKFLOW_JOB_ID_INGEST_DOCUMENT      = var.azure_workflow_job_id
    # DATABASE_URL                               = var.database_url
    # DATABRICKS_ACCESS_TOKEN                    = var.databricks_access_token
    # DATABRICKS_CATALOG_NAME                    = var.databricks_catalog_name
    # DATABRICKS_TRIGGER_JOB_BASEURL             = var.databricks_job_base_url
    # DATABRICKS_TRIGGER_JOB_JWT_TOKEN           = var.databricks_job_jwt_token
    # DATABRICKS_VECTOR_SEARCH_BASEURL           = var.databricks_vector_base_url
    # DATABRICKS_VECTOR_SEARCH_JWT_TOKEN         = var.databricks_vector_jwt_token
    # DEFAULT_PASSWORD                           = var.default_password
    # POSTGRES_USER                              = var.hub_postgresql_admin_login
    # POSTGRES_PASSWORD                          = var.hub_postgresql_admin_password
  }

  sticky_settings {
    app_setting_names = [
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
      "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
      "ApplicationInsightsAgent_EXTENSION_VERSION",
      "DiagnosticServices_EXTENSION_VERSION",
      "InstrumentationEngine_EXTENSION_VERSION",
      "SnapshotDebugger_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "XDT_MicrosoftApplicationInsights_Mode",
      "XDT_MicrosoftApplicationInsights_PreemptSdk"
    ]
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "random_string" "web_app_suffix" {
  length  = var.spoke_api_web_app_random_suffix_length
  special = var.spoke_api_web_app_random_suffix_special
  upper   = var.spoke_api_web_app_random_suffix_upper
}

# VNet Integration for the Web App
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = var.spoke_api_web_app_subnet_id
}