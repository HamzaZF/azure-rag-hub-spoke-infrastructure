/*
  main.tf (Hub PostgreSQL Flexible Server Submodule)

  This file provisions the PostgreSQL Flexible Server for the Kelix Azure Hub environment.
*/

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix = [var.naming_region]
}

# -----------------------------------------------------------------------------
# PostgreSQL Flexible Server
# -----------------------------------------------------------------------------
resource "azurerm_postgresql_flexible_server" "kelix_pgsql" {
  name                          = "${module.naming.postgresql_server.name}-${random_string.postgresql_suffix.result}"

  resource_group_name           = var.hub_postgresql_resource_group_name
  location                      = var.hub_postgresql_location
  version                       = var.hub_postgresql_version
  administrator_login           = var.hub_postgresql_administrator_login
  administrator_password        = var.hub_postgresql_administrator_password
  storage_mb                    = var.hub_postgresql_storage_mb
  storage_tier                  = var.hub_postgresql_storage_tier
  sku_name                      = var.hub_postgresql_sku_name
  public_network_access_enabled = false
  zone                          = var.hub_postgresql_zone

  authentication {
    active_directory_auth_enabled = var.hub_postgresql_active_directory_auth_enabled
    password_auth_enabled         = var.hub_postgresql_password_auth_enabled
    tenant_id                     = data.azurerm_client_config.current.tenant_id
  }
}

resource "random_string" "postgresql_suffix" {
  length  = var.hub_postgresql_random_suffix_length
  special = var.hub_postgresql_random_suffix_special
  upper   = var.hub_postgresql_random_suffix_upper
}

# Get current Azure configuration
data "azurerm_client_config" "current" {}

# Configure VM managed identity as PostgreSQL Azure AD administrator
resource "azurerm_postgresql_flexible_server_active_directory_administrator" "kelix_pgsql_vm_admin" {
  server_name         = azurerm_postgresql_flexible_server.kelix_pgsql.name
  resource_group_name = var.hub_postgresql_resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  object_id           = var.vm_managed_identity_principal_id
  principal_name      = var.vm_managed_identity_principal_name
  principal_type      = "ServicePrincipal"
}
