/*
  main.tf - Spoke AI Networking Module

  This module creates the core networking infrastructure for the AI spoke,
  including virtual network, subnets, and network security groups with
  comprehensive security controls.

  Components:
  - Virtual network with dedicated address space
  - Private endpoints subnet for secure service connectivity
  - Network security groups with restrictive access controls
  - Cross-module integration with hub networking
*/

# =============================================================================
# NAMING
# =============================================================================
module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "ai"]
  suffix = [var.naming_region]
}

# =============================================================================
# VIRTUAL NETWORK
# =============================================================================
# Core virtual network for AI workloads with dedicated address space

resource "azurerm_virtual_network" "vnet_ai" {
  name                = "${module.naming.virtual_network.name}-${random_string.vnet_suffix.result}"
  location            = var.spoke_ai_networking_location
  resource_group_name = var.spoke_ai_networking_resource_group_name
  address_space       = var.spoke_ai_networking_vnet_address_space
}

resource "random_string" "vnet_suffix" {
  length  = var.spoke_ai_networking_vnet_random_suffix_length
  special = var.spoke_ai_networking_vnet_random_suffix_special
  upper   = var.spoke_ai_networking_vnet_random_suffix_upper
}

# =============================================================================
# SUBNETS
# =============================================================================
# Dedicated subnets for different workload types

resource "azurerm_subnet" "subnet_pe" {
  name                 = "ai-subnet-pe"
  resource_group_name  = var.spoke_ai_networking_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_ai.name
  address_prefixes     = [var.spoke_ai_networking_pe_subnet_prefix]
}

resource "azurerm_subnet" "subnet_cappenv" {
  name                 = "ai-subnet-cappenv"
  resource_group_name  = var.spoke_ai_networking_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_ai.name
  address_prefixes     = [var.spoke_ai_networking_cappenv_subnet_prefix]

  delegation {
    name = "containerappsenvironmentdelegation"
    service_delegation {
      name    = "Microsoft.App/environments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
    }
  }

  service_endpoints = ["Microsoft.Storage"]
}

# =============================================================================
# NETWORK SECURITY GROUPS
# =============================================================================
# Security controls for network traffic

resource "azurerm_network_security_group" "nsg_pe" {
  name                = "${module.naming.network_security_group.name}-pe-${random_string.nsg_pe_suffix.result}"
  location            = var.spoke_ai_networking_location
  resource_group_name = var.spoke_ai_networking_resource_group_name
}

resource "random_string" "nsg_pe_suffix" {
  length  = var.spoke_ai_networking_nsg_pe_random_suffix_length
  special = var.spoke_ai_networking_nsg_pe_random_suffix_special
  upper   = var.spoke_ai_networking_nsg_pe_random_suffix_upper
}

resource "azurerm_network_security_group" "nsg_cappenv" {
  name                = "${module.naming.network_security_group.name}-cappenv-${random_string.nsg_cappenv_suffix.result}"
  location            = var.spoke_ai_networking_location
  resource_group_name = var.spoke_ai_networking_resource_group_name
}

resource "random_string" "nsg_cappenv_suffix" {
  length  = var.spoke_ai_networking_nsg_cappenv_random_suffix_length
  special = var.spoke_ai_networking_nsg_cappenv_random_suffix_special
  upper   = var.spoke_ai_networking_nsg_cappenv_random_suffix_upper
}

# =============================================================================
# NSG RULES
# =============================================================================
# Security rules for private endpoints subnet

resource "azurerm_network_security_rule" "nsg_pe_allow_https_inbound" {
  name                        = "AllowHTTPSInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_pe.name
}

resource "azurerm_network_security_rule" "nsg_pe_deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_pe.name
}

resource "azurerm_network_security_rule" "nsg_pe_allow_https_outbound" {
  name                        = "AllowHTTPSOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_pe.name
}

resource "azurerm_network_security_rule" "nsg_pe_deny_all_outbound" {
  name                        = "DenyAllOutbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_pe.name
}

# Security rules for container apps environment subnet

# Allow inbound access from web app in API spoke
resource "azurerm_network_security_rule" "nsg_cappenv_allow_webapp_inbound" {
  name                        = "AllowWebAppInbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "443"]
  source_address_prefixes     = var.spoke_api_vnet_address_space
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_cappenv.name
}

# Allow inbound access from hub VM
resource "azurerm_network_security_rule" "nsg_cappenv_allow_hub_vm_inbound" {
  name                        = "AllowHubVMInbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["80", "31080", "443", "31443"]
  source_address_prefixes     = var.hub_vnet_address_space
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_cappenv.name
}

# AzureLoadBalancer
resource "azurerm_network_security_rule" "nsg_cappenv_allow_azure_load_balancer_inbound" {
  name                        = "AllowAzureLoadBalancerInbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_ranges     = ["30000-32767"]
  source_address_prefix       = "AzureLoadBalancer"
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_cappenv.name
}

//

# Deny all other inbound traffic
resource "azurerm_network_security_rule" "nsg_cappenv_deny_all_inbound" {
  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_cappenv.name
}

# Allow outbound access to private endpoints subnet in AI spoke
resource "azurerm_network_security_rule" "nsg_cappenv_allow_pe_outbound" {
  name                        = "AllowPEOutbound"
  priority                    = 100
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "VirtualNetwork"
  destination_address_prefix  = var.spoke_ai_pe_subnet_prefix
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_cappenv.name
}

# Allow outbound access to hub services
resource "azurerm_network_security_rule" "nsg_cappenv_allow_hub_outbound" {
  name                         = "AllowHubOutbound"
  priority                     = 110
  direction                    = "Outbound"
  access                       = "Allow"
  protocol                     = "Tcp"
  source_port_range            = "*"
  destination_port_range       = "443"
  source_address_prefix        = "VirtualNetwork"
  destination_address_prefixes = var.hub_vnet_address_space
  resource_group_name          = var.spoke_ai_networking_resource_group_name
  network_security_group_name  = azurerm_network_security_group.nsg_cappenv.name
}

# Allow outbound HTTPS access to internet for Docker image pulls
resource "azurerm_network_security_rule" "nsg_cappenv_allow_internet_outbound" {
  name                        = "AllowInternetOutbound"
  priority                    = 120
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "Internet"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_cappenv.name
}

# Deny all other outbound traffic
resource "azurerm_network_security_rule" "nsg_cappenv_deny_all_outbound" {
  name                        = "DenyAllOutbound"
  priority                    = 4096
  direction                   = "Outbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.spoke_ai_networking_resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg_cappenv.name
}

# =============================================================================
# SUBNET NSG ASSOCIATIONS
# =============================================================================
# Associate NSGs with their respective subnets

resource "azurerm_subnet_network_security_group_association" "ai_pe_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_pe.id
  network_security_group_id = azurerm_network_security_group.nsg_pe.id
}

resource "azurerm_subnet_network_security_group_association" "ai_cappenv_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet_cappenv.id
  network_security_group_id = azurerm_network_security_group.nsg_cappenv.id
}




resource "azurerm_route_table" "ai_route_table" {
  name                = "${module.naming.route_table.name}-${random_string.route_table_suffix.result}"
  location            = var.spoke_ai_networking_location
  resource_group_name = var.spoke_ai_networking_resource_group_name
}

resource "azurerm_route" "ai_route" {
  name                   = "to-spoke-api"
  resource_group_name    = var.spoke_ai_networking_resource_group_name
  route_table_name       = azurerm_route_table.ai_route_table.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_azure_firewall_public_ip_address
}

resource "azurerm_subnet_route_table_association" "ai_route_table_association" {
  subnet_id      = azurerm_subnet.subnet_cappenv.id
  route_table_id = azurerm_route_table.ai_route_table.id
}

resource "random_string" "route_table_suffix" {
  length  = var.spoke_ai_networking_route_table_random_suffix_length
  special = var.spoke_ai_networking_route_table_random_suffix_special
  upper   = var.spoke_ai_networking_route_table_random_suffix_upper
}
