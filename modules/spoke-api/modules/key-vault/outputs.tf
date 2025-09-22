output "spoke_api_key_vault_id" {
  description = "The ID of the API spoke Key Vault."
  value       = azurerm_key_vault.spoke_api_key_vault.id
}

output "spoke_api_key_vault_name" {
  description = "The name of the API spoke Key Vault."
  value       = azurerm_key_vault.spoke_api_key_vault.name
}

output "spoke_api_key_vault_uri" {
  description = "The URI of the API spoke Key Vault."
  value       = azurerm_key_vault.spoke_api_key_vault.vault_uri
}

# output "spoke_api_key_vault_certificate_secret_id" {
#   description = "The ID of the key vault secret for the SSL certificate."
#   value       = azurerm_key_vault_certificate.spoke_api_key_vault_certificate.secret_id
# }