/*
  outputs.tf (Hub Networking Submodule)

  This file exposes key outputs from the Kelix Azure Hub Networking submodule.
*/

# -----------------------------------------------------------------------------
# Virtual Network Outputs
# -----------------------------------------------------------------------------

# The ID of the hub virtual network
output "hub_networking_vnet_id" {
  description = "The ID of the hub virtual network."
  value       = azurerm_virtual_network.vnet_hub.id
}

# The name of the hub virtual network
output "hub_networking_vnet_name" {
  description = "The name of the hub virtual network."
  value       = azurerm_virtual_network.vnet_hub.name
}

# The address space of the hub virtual network
output "hub_networking_vnet_address_space" {
  description = "The address space of the hub virtual network."
  value       = azurerm_virtual_network.vnet_hub.address_space
}

# -----------------------------------------------------------------------------
# Subnet Outputs
# -----------------------------------------------------------------------------

# The ID of the VM subnet
output "hub_networking_vm_subnet_id" {
  description = "The ID of the VM subnet."
  value       = azurerm_subnet.subnet_vm.id
}

# The ID of the private endpoint subnet
output "hub_networking_pe_subnet_id" {
  description = "The ID of the private endpoint subnet."
  value       = azurerm_subnet.subnet_pe.id
}

# The ID of the Azure Firewall subnet
output "hub_networking_azure_firewall_subnet_id" {
  description = "The ID of the Azure Firewall subnet."
  value       = azurerm_subnet.subnet_azure_firewall.id
}

output "hub_networking_azure_firewall_name" {
  description = "The name of the Azure Firewall subnet."
  value       = azurerm_subnet.subnet_azure_firewall.name
}



# -----------------------------------------------------------------------------
# Network Security Group Outputs
# -----------------------------------------------------------------------------

# The ID of the NSG for the VM subnet
output "hub_networking_vm_nsg_id" {
  description = "The ID of the NSG for the VM subnet."
  value       = azurerm_network_security_group.nsg_vm.id
}

# The ID of the NSG for the private endpoint subnet
output "hub_networking_pe_nsg_id" {
  description = "The ID of the NSG for the private endpoint subnet."
  value       = azurerm_network_security_group.nsg_pe.id
}