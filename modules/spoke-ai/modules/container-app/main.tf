/*
  main.tf - Spoke AI Container App Module

  This module creates Container Apps within the AI spoke environment,
  providing scalable containerized applications with proper identity management
  and integration with the container apps environment.

  Components:
  - Multiple Container Apps using Azure Verified Modules (AVM)
  - Identity management and lifecycle settings
  - Integration with container apps environment
  - Template-based configuration for AI workloads
  - Support for arbitrary number of container apps via configuration
*/

# =============================================================================
# NAMING
# =============================================================================
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "ai"]
  suffix = [var.naming_region]
}

# =============================================================================
# CONTAINER APPS
# =============================================================================
# Multiple container apps using Azure Verified Modules

resource "random_string" "container_app_suffix" {
  for_each = var.spoke_ai_container_apps
  
  length  = var.spoke_ai_container_app_random_suffix_length
  special = var.spoke_ai_container_app_random_suffix_special
  upper   = var.spoke_ai_container_app_random_suffix_upper
}

module "avm_res_app_containerapp" {
  source  = "Azure/avm-res-app-containerapp/azurerm"
  version = "0.7.0"
  for_each = var.spoke_ai_container_apps

  name = each.value.name != null ? each.value.name : "${module.naming.container_app.name}-${each.key}-${random_string.container_app_suffix[each.key].result}"
  resource_group_name = var.spoke_ai_container_app_resource_group_name
  template = merge(
    {
      max_replicas = var.spoke_ai_container_apps_workload_profile_max_count
      min_replicas = var.spoke_ai_container_apps_workload_profile_min_count
      polling_interval = var.spoke_ai_container_apps_workload_profile_polling_interval
      revision_suffix = var.spoke_ai_container_apps_workload_profile_revision_suffix
      containers = each.value.containers
    },
    each.value.template != null ? each.value.template : {}
  )
  container_app_environment_resource_id = var.spoke_ai_container_app_environment_resource_id

  identity_settings = each.value.identity_settings != null ? each.value.identity_settings : [{
    identity = var.spoke_ai_container_app_identity_id
    lifecycle = var.spoke_ai_container_app_identity_lifecycle
  }]

  ingress = each.value.ingress != null ? (
    # Use the provided ingress configuration, but conditionally add exposed_port
    merge(
      {
        allow_insecure_connections = each.value.ingress.allow_insecure_connections
        external_enabled           = each.value.ingress.external_enabled
        target_port                = each.value.ingress.target_port
        transport                  = each.value.ingress.transport
        traffic_weight             = each.value.ingress.traffic_weight
      },
      # Only include exposed_port if external_enabled is true AND transport is tcp AND exposed_port is provided
      (each.value.ingress.external_enabled == true && each.value.ingress.transport == "tcp" && try(each.value.ingress.exposed_port, null) != null) ? {
        exposed_port = each.value.ingress.exposed_port
      } : {}
    )
  ) : (
    # Use default configuration, conditionally adding exposed_port
    merge(
      {
        allow_insecure_connections = var.spoke_ai_container_app_ingress_allow_insecure_connections
        external_enabled           = var.spoke_ai_container_app_ingress_external_enabled
        target_port                = var.spoke_ai_container_app_ingress_target_port
        transport                  = var.spoke_ai_container_app_ingress_transport
        traffic_weight = [{
          percentage = var.spoke_ai_container_app_ingress_traffic_weight
          latest_revision = true
        }]
      },
      # Only include exposed_port if external_enabled is true AND transport is tcp
      (var.spoke_ai_container_app_ingress_external_enabled == true && var.spoke_ai_container_app_ingress_transport == "tcp") ? {
        exposed_port = var.spoke_ai_container_app_ingress_exposed_port
      } : {}
    )
  )
}