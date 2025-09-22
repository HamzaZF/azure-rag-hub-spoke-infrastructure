/*
  outputs.tf - Spoke AI Key Vault Module Outputs

  This file defines all output values from the AI spoke Key Vault module,
  providing essential resource information for integration with other modules
  and private endpoint configuration.
*/

# =============================================================================
# KEY VAULT OUTPUTS
# =============================================================================

output "spoke_ai_key_vault_id" {
  description = "The ID of the AI spoke Key Vault."
  value       = azurerm_key_vault.container_apps_kv.id
}

output "spoke_ai_key_vault_name" {
  description = "The name of the AI spoke Key Vault."
  value       = azurerm_key_vault.container_apps_kv.name
}

output "spoke_ai_key_vault_uri" {
  description = "The URI of the AI spoke Key Vault for client applications."
  value       = azurerm_key_vault.container_apps_kv.vault_uri
}

output "spoke_ai_key_vault_resource_group_name" {
  description = "The resource group name of the AI spoke Key Vault."
  value       = azurerm_key_vault.container_apps_kv.resource_group_name
}

output "spoke_ai_key_vault_location" {
  description = "The location of the AI spoke Key Vault."
  value       = azurerm_key_vault.container_apps_kv.location
}

output "spoke_ai_key_vault_tenant_id" {
  description = "The tenant ID associated with the AI spoke Key Vault."
  value       = azurerm_key_vault.container_apps_kv.tenant_id
}
