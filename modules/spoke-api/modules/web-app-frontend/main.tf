module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "frontend"]
  suffix = [var.naming_region]
}

resource "azurerm_service_plan" "frontend_plan" {
  name                = "${module.naming.app_service_plan.name}-${random_string.frontend_service_plan_suffix.result}"
  resource_group_name = var.spoke_api_frontend_resource_group_name
  location            = var.spoke_api_frontend_location
  sku_name            = var.spoke_api_frontend_sku_name
  os_type             = "Linux"
}

resource "random_string" "frontend_service_plan_suffix" {
  length  = var.spoke_api_frontend_service_plan_random_suffix_length
  special = var.spoke_api_frontend_service_plan_random_suffix_special
  upper   = var.spoke_api_frontend_service_plan_random_suffix_upper
}

resource "azurerm_linux_web_app" "frontend_app" {
  name                          = "${module.naming.app_service.name}-${random_string.frontend_web_app_suffix.result}"
  resource_group_name           = var.spoke_api_frontend_resource_group_name
  location                      = var.spoke_api_frontend_location
  service_plan_id               = azurerm_service_plan.frontend_plan.id
  public_network_access_enabled = true  # Frontend needs public access

  site_config {
    always_on                               = true
    container_registry_use_managed_identity = true
    
    
    # container_registry_managed_identity_client_id = azurerm_linux_web_app.frontend_app.identity[0].principal_id

    # Container configuration for frontend
    application_stack {
      docker_image_name   = var.frontend_container_image_name
      docker_registry_url = "https://${var.acr_login_server}"
    }
  }

  # Frontend-specific environment variables
  app_settings = {

    # -------------------------------------------------------------------------
    # Continuous deployment configuration
    # -------------------------------------------------------------------------

    #"DOCKER_ENABLE_CI" = "true"

    # Application Insights Configuration (for frontend monitoring)
    APPINSIGHTS_INSTRUMENTATIONKEY             = var.appinsights_instrumentation_key
    APPINSIGHTS_PROFILERFEATURE_VERSION        = var.appinsights_profiler_version
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION        = var.appinsights_snapshot_version
    APPLICATIONINSIGHTS_CONFIGURATION_CONTENT  = var.applicationinsights_config_content
    APPLICATIONINSIGHTS_CONNECTION_STRING      = var.applicationinsights_connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = var.applicationinsights_agent_version

    # Backend API Configuration
    BACKEND_API_URL    = var.backend_api_url
    BACKEND_API_BASE   = var.backend_api_base_url

    # Frontend Configuration
    FRONTEND_DOMAIN = var.frontend_domain
    
    # Environment Configuration
    NODE_ENV = var.frontend_node_env
    PORT     = var.frontend_port
    WEBSITES_PORT = "80"

    # Extensions Configuration
    DiagnosticServices_EXTENSION_VERSION = var.diagnostic_services_version

    # Docker Configuration
    DOCKER_ENABLE_CI = var.docker_enable_ci

    # Application Environment
    IS_DEV = var.is_dev_environment

    # Application Insights Advanced Configuration
    XDT_MicrosoftApplicationInsights_BaseExtensions = var.app_insights_base_extensions
    XDT_MicrosoftApplicationInsights_Mode           = var.app_insights_mode
    XDT_MicrosoftApplicationInsights_PreemptSdk     = var.app_insights_preempt_sdk
  }

  sticky_settings {
    app_setting_names = [
      "APPINSIGHTS_INSTRUMENTATIONKEY",
      "APPINSIGHTS_PROFILERFEATURE_VERSION",
      "APPINSIGHTS_SNAPSHOTFEATURE_VERSION",
      "APPLICATIONINSIGHTS_CONFIGURATION_CONTENT",
      "ApplicationInsightsAgent_EXTENSION_VERSION",
      "DiagnosticServices_EXTENSION_VERSION",
      "XDT_MicrosoftApplicationInsights_BaseExtensions",
      "XDT_MicrosoftApplicationInsights_Mode",
      "XDT_MicrosoftApplicationInsights_PreemptSdk"
    ]
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "random_string" "frontend_web_app_suffix" {
  length  = var.spoke_api_frontend_web_app_random_suffix_length
  special = var.spoke_api_frontend_web_app_random_suffix_special
  upper   = var.spoke_api_frontend_web_app_random_suffix_upper
}

# # VNet Integration for the Frontend Web App (optional for frontend, but good for security)
# resource "azurerm_app_service_virtual_network_swift_connection" "frontend_vnet_integration" {
#   app_service_id = azurerm_linux_web_app.frontend_app.id
#   subnet_id      = var.spoke_api_frontend_subnet_id
# }