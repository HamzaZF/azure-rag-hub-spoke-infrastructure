/*
  outputs.tf (Spoke API Web App Frontend Submodule)

  This file defines all outputs for the Kelix Azure Spoke API Web App Frontend submodule.
*/

# -----------------------------------------------------------------------------
# Service Plan Outputs
# -----------------------------------------------------------------------------
output "spoke_api_frontend_service_plan_id" {
  description = "The ID of the Frontend App Service Plan."
  value       = azurerm_service_plan.frontend_plan.id
}

output "spoke_api_frontend_service_plan_name" {
  description = "The name of the Frontend App Service Plan."
  value       = azurerm_service_plan.frontend_plan.name
}

# -----------------------------------------------------------------------------
# Frontend Web App Outputs
# -----------------------------------------------------------------------------
output "spoke_api_frontend_app_id" {
  description = "The ID of the Frontend App Service."
  value       = azurerm_linux_web_app.frontend_app.id
}

output "spoke_api_frontend_app_name" {
  description = "The name of the Frontend App Service."
  value       = azurerm_linux_web_app.frontend_app.name
}

output "spoke_api_frontend_app_principal_id" {
  description = "The principal_id of the frontend web app's managed identity."
  value       = azurerm_linux_web_app.frontend_app.identity[0].principal_id
}

output "spoke_api_frontend_app_url" {
  description = "The default URL of the Frontend App Service."
  value       = "https://${azurerm_linux_web_app.frontend_app.default_hostname}"
}

# -----------------------------------------------------------------------------
# Networking Outputs
# -----------------------------------------------------------------------------
output "spoke_api_frontend_subnet_id" {
  description = "The ID of the subnet for Virtual Network integration of the Frontend Web App."
  value       = var.spoke_api_frontend_subnet_id
}

# -----------------------------------------------------------------------------
# Frontend Web App Credentials Outputs
# -----------------------------------------------------------------------------
output "spoke_api_frontend_site_credential_name" {
  description = "The username for the frontend web app's site credentials."
  value       = azurerm_linux_web_app.frontend_app.site_credential[0].name
}

output "spoke_api_frontend_site_credential_password" {
  description = "The password for the frontend web app's site credentials."
  value       = azurerm_linux_web_app.frontend_app.site_credential[0].password
  sensitive   = true
}
