/*
  outputs.tf (Hub ACR Submodule)

  This file defines all outputs for the Kelix Azure Hub Azure Container Registry (ACR) submodule.
*/

# -----------------------------------------------------------------------------
# ACR Outputs
# -----------------------------------------------------------------------------
output "hub_acr_id" {
  description = "The resource ID of the Azure Container Registry."
  value       = azurerm_container_registry.acr.id
}

output "hub_acr_name" {
  description = "The name of the Azure Container Registry."
  value       = azurerm_container_registry.acr.name
}

output "hub_acr_login_server" {
  description = "The login server URL of the Azure Container Registry."
  value       = azurerm_container_registry.acr.login_server
}
