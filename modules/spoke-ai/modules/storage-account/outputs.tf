/*
  outputs.tf - Spoke AI Storage Account Module Outputs

  This file defines all outputs for the AI spoke storage account module,
  providing resource IDs and information for cross-module integration.
*/

# =============================================================================
# STORAGE ACCOUNT OUTPUTS
# =============================================================================

output "spoke_ai_storage_account_id" {
  description = "The resource ID of the AI spoke storage account."
  value       = azurerm_storage_account.storage_account.id
}

output "spoke_ai_storage_account_name" {
  description = "The name of the AI spoke storage account."
  value       = azurerm_storage_account.storage_account.name
}

output "spoke_ai_storage_account_primary_access_key" {
  description = "The primary access key for the AI spoke storage account."
  value       = azurerm_storage_account.storage_account.primary_access_key
  sensitive   = true
}

# =============================================================================
# TABLE STORAGE OUTPUTS
# =============================================================================
 