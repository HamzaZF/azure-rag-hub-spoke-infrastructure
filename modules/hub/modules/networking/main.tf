/*
  main.tf (Hub Networking Submodule)

  This file provisions the core networking infrastructure for the Kelix Azure Hub environment.
*/

# -----------------------------------------------------------------------------
# Naming
# -----------------------------------------------------------------------------
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "0.4.1"
  prefix  = [var.naming_company, var.naming_product, var.naming_environment, "hub"]
  suffix  = [var.naming_region]
}

# -----------------------------------------------------------------------------
# Network Security Groups
# -----------------------------------------------------------------------------

# Private Endpoints NSG
resource "azurerm_network_security_group" "nsg_pe" {
  location            = var.hub_networking_location
  name                = "${module.naming.network_security_group.name}-pe-${random_string.nsg_pe_suffix.result}"
  resource_group_name = var.hub_networking_resource_group_name

  # Inbound Rules - Allow from VNet only
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "AllowInboundFromVNet"
    priority                   = 100
    protocol                   = "*"
    source_address_prefix      = "VirtualNetwork"
    source_port_range          = "*"
  }

  # Outbound Rules - Allow to VNet and Azure services
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "VirtualNetwork"
    destination_port_range     = "*"
    direction                  = "Outbound"
    name                       = "AllowOutboundToVNet"
    priority                   = 100
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

resource "random_string" "nsg_pe_suffix" {
  length  = var.hub_networking_nsg_pe_random_suffix_length
  special = var.hub_networking_nsg_pe_random_suffix_special
  upper   = var.hub_networking_nsg_pe_random_suffix_upper
}

# VM NSG
resource "azurerm_network_security_group" "nsg_vm" {
  location            = var.hub_networking_location
  name                = "${module.naming.network_security_group.name}-vm-${random_string.nsg_vm_suffix.result}"
  resource_group_name = var.hub_networking_resource_group_name

  # Inbound Rules - SSH access from allowed sources
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "22"
    direction                  = "Inbound"
    name                       = "AllowSSH"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  # Deny all inbound traffic that doesn't match allow rules
  security_rule {
    access                     = "Deny"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "DenyAllInbound"
    priority                   = 4096
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  # Outbound Rules - Allow to VNet, Azure services, and internet
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "Internet"
    destination_port_range     = "80"
    direction                  = "Outbound"
    name                       = "AllowOutboundHTTP"
    priority                   = 120
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "Internet"
    destination_port_range     = "443"
    direction                  = "Outbound"
    name                       = "AllowOutboundHTTPS"
    priority                   = 130
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = var.hub_networking_pe_subnet_prefix
    destination_port_range     = "*"
    direction                  = "Outbound"
    name                       = "AllowOutboundToHubPESubnet"
    priority                   = 140
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = var.spoke_api_networking_pe_subnet_prefix
    destination_port_range     = "*"
    direction                  = "Outbound"
    name                       = "AllowOutboundToApiSpokePESubnet"
    priority                   = 150
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = var.spoke_ai_networking_pe_subnet_prefix
    destination_port_range     = "*"
    direction                  = "Outbound"
    name                       = "AllowOutboundToAiSpokePESubnet"
    priority                   = 160
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = var.spoke_ai_networking_cappenv_subnet_prefix
    destination_port_range     = "*"
    direction                  = "Outbound"
    name                       = "AllowOutboundToAiSpokeCAppEnvSubnet"
    priority                   = 170
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  # Deny all outbound traffic that doesn't match allow rules
  security_rule {
    access                     = "Deny"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Outbound"
    name                       = "DenyAllOutbound"
    priority                   = 4096
    protocol                   = "*"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }
}

resource "random_string" "nsg_vm_suffix" {
  length  = var.hub_networking_nsg_vm_random_suffix_length
  special = var.hub_networking_nsg_vm_random_suffix_special
  upper   = var.hub_networking_nsg_vm_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Virtual Network
# -----------------------------------------------------------------------------
resource "azurerm_virtual_network" "vnet_hub" {
  name                = "${module.naming.virtual_network.name}-${random_string.vnet_suffix.result}"
  location            = var.hub_networking_location
  resource_group_name = var.hub_networking_resource_group_name
  address_space       = var.hub_networking_vnet_address_space
}

resource "random_string" "vnet_suffix" {
  length  = var.hub_networking_vnet_random_suffix_length
  special = var.hub_networking_vnet_random_suffix_special
  upper   = var.hub_networking_vnet_random_suffix_upper
}

# -----------------------------------------------------------------------------
# Subnets
# -----------------------------------------------------------------------------
resource "azurerm_subnet" "subnet_pe" {
  name                 = "${module.naming.subnet.name}-pe-${random_string.subnet_pe_suffix.result}"
  resource_group_name  = var.hub_networking_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = [var.hub_networking_pe_subnet_prefix]
}

resource "random_string" "subnet_pe_suffix" {
  length  = var.hub_networking_subnet_pe_random_suffix_length
  special = var.hub_networking_subnet_pe_random_suffix_special
  upper   = var.hub_networking_subnet_pe_random_suffix_upper
}

resource "azurerm_subnet" "subnet_vm" {
  name                 = "${module.naming.subnet.name}-vm-${random_string.subnet_vm_suffix.result}"
  resource_group_name  = var.hub_networking_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = [var.hub_networking_vm_subnet_prefix]

  service_endpoints = ["Microsoft.Storage"]
}

resource "random_string" "subnet_vm_suffix" {
  length  = var.hub_networking_subnet_vm_random_suffix_length
  special = var.hub_networking_subnet_vm_random_suffix_special
  upper   = var.hub_networking_subnet_vm_random_suffix_upper
}

//same but for the azure firewall (it needs a subnet too)
resource "azurerm_subnet" "subnet_azure_firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = var.hub_networking_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = [var.hub_networking_azure_firewall_subnet_prefix]
}

resource "random_string" "subnet_azure_firewall_suffix" {
  length  = var.hub_networking_subnet_azure_firewall_random_suffix_length
  special = var.hub_networking_subnet_azure_firewall_random_suffix_special
  upper   = var.hub_networking_subnet_azure_firewall_random_suffix_upper
}

# -----------------------------------------------------------------------------
# NSG Associations
# -----------------------------------------------------------------------------
resource "azurerm_subnet_network_security_group_association" "nsg_pe_association" {
  subnet_id                 = azurerm_subnet.subnet_pe.id
  network_security_group_id = azurerm_network_security_group.nsg_pe.id
}

resource "azurerm_subnet_network_security_group_association" "nsg_vm_association" {
  subnet_id                 = azurerm_subnet.subnet_vm.id
  network_security_group_id = azurerm_network_security_group.nsg_vm.id
}
