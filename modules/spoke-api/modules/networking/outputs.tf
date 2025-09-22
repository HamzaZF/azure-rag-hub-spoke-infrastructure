/*
  outputs.tf (Spoke API Networking Submodule)

  This file defines all outputs for the Kelix Azure Spoke API Networking submodule.
*/

# -----------------------------------------------------------------------------
# Virtual Network Outputs
# -----------------------------------------------------------------------------
output "spoke_api_networking_vnet_id" {
  description = "The ID of the API spoke virtual network."
  value       = azurerm_virtual_network.vnet_api.id
}

output "spoke_api_networking_vnet_name" {
  description = "The name of the API spoke virtual network."
  value       = azurerm_virtual_network.vnet_api.name
}

# -----------------------------------------------------------------------------
# Subnet Outputs
# -----------------------------------------------------------------------------
output "spoke_api_networking_subnet_ag_id" {
  description = "The ID of the Application Gateway subnet."
  value       = azurerm_subnet.subnet_ag.id
}

output "spoke_api_networking_subnet_pe_id" {
  description = "The ID of the Private Endpoints subnet."
  value       = azurerm_subnet.subnet_pe.id
}

output "spoke_api_networking_subnet_wa_id" {
  description = "The ID of the Web Application subnet."
  value       = azurerm_subnet.subnet_wa.id
}

output "spoke_api_networking_subnet_ag_name" {
  description = "The name of the Application Gateway subnet."
  value       = azurerm_subnet.subnet_ag.name
}

output "spoke_api_networking_subnet_pe_name" {
  description = "The name of the Private Endpoints subnet."
  value       = azurerm_subnet.subnet_pe.name
}

output "spoke_api_networking_subnet_wa_name" {
  description = "The name of the Web Application subnet."
  value       = azurerm_subnet.subnet_wa.name
}

# -----------------------------------------------------------------------------
# NSG Association Outputs
# -----------------------------------------------------------------------------
# output "spoke_api_networking_nsg_ag_association_id" {
#   description = "The ID of the NSG association for the Application Gateway subnet."
#   value       = azurerm_subnet_network_security_group_association.ag.id
# }

# output "spoke_api_networking_nsg_pe_association_id" {
#   description = "The ID of the NSG association for the Private Endpoints subnet."
#   value       = azurerm_subnet_network_security_group_association.pe.id
# }

# output "spoke_api_networking_nsg_wa_association_id" {
#   description = "The ID of the NSG association for the Web Application subnet."
#   value       = azurerm_subnet_network_security_group_association.wa.id
# }
