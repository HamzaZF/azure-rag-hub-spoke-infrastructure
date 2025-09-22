/*
  outputs.tf (Hub Azure Firewall Submodule)

  This file exposes key outputs from the Kelix Azure Hub Azure Firewall submodule.
*/

# -----------------------------------------------------------------------------
# Azure Firewall Outputs
# -----------------------------------------------------------------------------

# The ID of the Azure Firewall
output "hub_azure_firewall_id" {
  description = "The ID of the Azure Firewall."
  value       = azurerm_firewall.azure_firewall.id
}

# The name of the Azure Firewall
output "hub_azure_firewall_name" {
  description = "The name of the Azure Firewall."
  value       = azurerm_firewall.azure_firewall.name
}

# The private IP address of the Azure Firewall
output "hub_azure_firewall_ip_configuration" {
  description = "The IP configuration of the Azure Firewall."
  value       = azurerm_firewall.azure_firewall.ip_configuration
}

# -----------------------------------------------------------------------------
# Public IP Outputs
# -----------------------------------------------------------------------------

# The ID of the Azure Firewall public IP
output "hub_azure_firewall_public_ip_id" {
  description = "The ID of the Azure Firewall public IP."
  value       = azurerm_public_ip.azure_firewall_pip.id
}

# The public IP address of the Azure Firewall
output "hub_azure_firewall_public_ip_address" {
  description = "The public IP address of the Azure Firewall."
  value       = azurerm_public_ip.azure_firewall_pip.ip_address
}

# The FQDN of the Azure Firewall public IP
output "hub_azure_firewall_public_ip_fqdn" {
  description = "The FQDN of the Azure Firewall public IP."
  value       = azurerm_public_ip.azure_firewall_pip.fqdn
}
