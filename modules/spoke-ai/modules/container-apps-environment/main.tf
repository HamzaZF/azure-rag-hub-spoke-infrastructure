/*
  main.tf - Spoke AI Container Apps Environment Module

  This module creates the Container Apps Environment for the AI spoke,
  providing a managed environment for running containerized AI workloads
  with proper networking integration and security controls.

  Components:
  - Container Apps Environment with internal load balancer
  - Workload profiles for scalable AI workloads
  - Integration with spoke networking infrastructure
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
# CONTAINER APPS ENVIRONMENT
# =============================================================================
# Core container apps environment for AI workloads

resource "azurerm_container_app_environment" "capp_env" {
  name                               = "${module.naming.container_app_environment.name}-${random_string.cappenv_suffix.result}"
  location                           = var.spoke_ai_container_apps_location
  resource_group_name                = var.spoke_ai_container_apps_resource_group_name
  infrastructure_resource_group_name = var.spoke_ai_container_apps_infrastructure_rg_name
  infrastructure_subnet_id           = var.spoke_ai_container_apps_infrastructure_subnet_id

  internal_load_balancer_enabled = true
  zone_redundancy_enabled        = var.spoke_ai_container_apps_zone_redundancy_enabled
  mutual_tls_enabled             = var.spoke_ai_container_apps_mutual_tls_enabled

  workload_profile {
    name                  = var.spoke_ai_container_apps_workload_profile_name
    workload_profile_type = var.spoke_ai_container_apps_workload_profile_type
    minimum_count         = var.spoke_ai_container_apps_workload_profile_min_count
    maximum_count         = var.spoke_ai_container_apps_workload_profile_max_count
  }
}

resource "random_string" "cappenv_suffix" {
  length  = var.spoke_ai_container_apps_environment_random_suffix_length
  special = var.spoke_ai_container_apps_environment_random_suffix_special
  upper   = var.spoke_ai_container_apps_environment_random_suffix_upper
}
