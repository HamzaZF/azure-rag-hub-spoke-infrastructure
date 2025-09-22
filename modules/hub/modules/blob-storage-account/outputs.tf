/*
  outputs.tf (Hub Blob Storage Account Submodule)

  This file defines all outputs for the Kelix Azure Hub Blob Storage Account submodule.
*/

# -----------------------------------------------------------------------------
# Storage Account Outputs
# -----------------------------------------------------------------------------
output "hub_blob_storage_account_name" {
  description = "The name of the Blob Storage account."
  value       = azurerm_storage_account.kelix_storage_account_hub.name
}

output "hub_blob_storage_account_id" {
  description = "The resource ID of the Blob Storage account."
  value       = azurerm_storage_account.kelix_storage_account_hub.id
}

output "hub_blob_storage_account_primary_connection_string" {
  description = "Primary connection string for the Blob Storage account."
  value       = azurerm_storage_account.kelix_storage_account_hub.primary_connection_string
}

# -----------------------------------------------------------------------------
# Storage Container Outputs
# -----------------------------------------------------------------------------
output "hub_blob_storage_container_name" {
  description = "Name of the Blob Storage container."
  value       = azurerm_storage_container.container.name
}

output "hub_blob_storage_container_id" {
  description = "Resource ID of the Blob Storage container."
  value       = azurerm_storage_container.container.id
}