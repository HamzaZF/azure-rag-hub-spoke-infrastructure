/*
  outputs.tf (Hub OpenAI Submodule)

  This file defines all outputs for the Kelix Azure Hub OpenAI submodule.
*/

# -----------------------------------------------------------------------------
# OpenAI Cognitive Account Outputs
# -----------------------------------------------------------------------------
output "hub_openai_cognitive_account_id" {
  description = "The ID of the OpenAI Cognitive Service."
  value       = azurerm_cognitive_account.openai.id
}

# output "hub_openai_cognitive_account_name" {
#   description = "The name of the OpenAI Cognitive Service."
#   value       = azurerm_cognitive_account.kelix-openai.name
# }

output "hub_openai_custom_subdomain_name" {
  description = "The custom subdomain name for the hub OpenAI service for managed identity access."
  value       = azurerm_cognitive_account.openai.custom_subdomain_name
}