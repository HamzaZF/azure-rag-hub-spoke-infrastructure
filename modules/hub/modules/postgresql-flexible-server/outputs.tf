/*
  outputs.tf (Hub PostgreSQL Flexible Server Submodule)

  This file defines all outputs for the Kelix Azure Hub PostgreSQL Flexible Server submodule.
*/

# -----------------------------------------------------------------------------
# Server Outputs
# -----------------------------------------------------------------------------
output "hub_postgresql_server_id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.id
}

output "hub_postgresql_server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.name
}

output "hub_postgresql_server_fqdn" {
  description = "The fully qualified domain name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.fqdn
}

output "hub_postgresql_server_host" {
  description = "The host/endpoint for connecting to the PostgreSQL server."
  value       = "${azurerm_postgresql_flexible_server.kelix_pgsql.name}.postgres.database.azure.com"
}

output "hub_postgresql_server_version" {
  description = "The version of PostgreSQL running on the server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.version
}

output "hub_postgresql_server_location" {
  description = "The Azure region where the PostgreSQL server is deployed."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.location
}

output "hub_postgresql_server_resource_group_name" {
  description = "The resource group containing the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.resource_group_name
}

output "hub_postgresql_server_zone" {
  description = "The availability zone of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.zone
}

# -----------------------------------------------------------------------------
# Credentials Outputs
# -----------------------------------------------------------------------------
output "hub_postgresql_administrator_login" {
  description = "The administrator login name for the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.administrator_login
}

output "hub_postgresql_administrator_password" {
  description = "The administrator password for the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.administrator_password
  sensitive   = true
}

# -----------------------------------------------------------------------------
# SKU & Storage Outputs
# -----------------------------------------------------------------------------
output "hub_postgresql_server_sku_name" {
  description = "The SKU name of the PostgreSQL Flexible Server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.sku_name
}

output "hub_postgresql_server_storage_mb" {
  description = "The storage capacity in MB of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.kelix_pgsql.storage_mb
}