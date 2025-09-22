/*
  outputs.tf (Spoke API Web App Submodule)

  This file defines all outputs for the Kelix Azure Spoke API Web App submodule.
*/

# -----------------------------------------------------------------------------
# Service Plan Outputs
# -----------------------------------------------------------------------------
output "spoke_api_web_app_service_plan_id" {
  description = "The ID of the App Service Plan."
  value       = azurerm_service_plan.plan.id
}

output "spoke_api_web_app_service_plan_name" {
  description = "The name of the App Service Plan."
  value       = azurerm_service_plan.plan.name
}

# -----------------------------------------------------------------------------
# Web App Outputs
# -----------------------------------------------------------------------------
output "spoke_api_web_app_id" {
  description = "The ID of the App Service."
  value       = azurerm_linux_web_app.app.id
}

output "spoke_api_web_app_name" {
  description = "The name of the App Service."
  value       = azurerm_linux_web_app.app.name
}

output "spoke_api_web_app_principal_id" {
  description = "The principal_id of the web app's managed identity."
  value       = azurerm_linux_web_app.app.identity[0].principal_id
}

# -----------------------------------------------------------------------------
# Networking Outputs
# -----------------------------------------------------------------------------
output "spoke_api_web_app_subnet_id" {
  description = "The ID of the subnet for Virtual Network integration of the Web App."
  value       = var.spoke_api_web_app_subnet_id
}

# -----------------------------------------------------------------------------
# Web App Credentials Outputs
# -----------------------------------------------------------------------------
output "spoke_api_web_app_site_credential_name" {
  description = "The username for the web app's site credentials."
  value       = azurerm_linux_web_app.app.site_credential[0].name
}

output "spoke_api_web_app_site_credential_password" {
  description = "The password for the web app's site credentials."
  value       = azurerm_linux_web_app.app.site_credential[0].password
  sensitive   = true
}
