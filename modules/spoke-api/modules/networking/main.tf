module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "api"]
  suffix = [var.naming_region]
}

# -----------------------------------------------------------------------------
# Network Security Groups
# -----------------------------------------------------------------------------

# Application Gateway NSG
resource "azurerm_network_security_group" "nsg_ag" {
  location            = var.spoke_api_networking_location
  name                = "${module.naming.network_security_group.name}-ag-${random_string.nsg_ag_suffix.result}"
  resource_group_name = var.spoke_api_networking_resource_group_name

  # Inbound Rules
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "80"
    direction                  = "Inbound"
    name                       = "AllowInboundHTTPFromStaticWebApp"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefixes    = var.static_web_app_allowed_ips
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "AllowInboundHTTPSFromStaticWebApp"
    priority                   = 110
    protocol                   = "Tcp"
    source_address_prefixes    = var.static_web_app_allowed_ips
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "65200-65535"
    direction                  = "Inbound"
    name                       = "AllowGatewayManager"
    priority                   = 120
    protocol                   = "Tcp"
    source_address_prefix      = "GatewayManager"
    source_port_range          = "*"
  }
  //

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "*"
    direction                  = "Inbound"
    name                       = "AllowInboundHTTPFromAzureLoadBalancer"
    priority                   = 121
    protocol                   = "*"
    source_address_prefix      = "AzureLoadBalancer"
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

  # Outbound Rules
  security_rule {
    access                     = "Allow"
    destination_address_prefix = var.spoke_api_networking_pe_subnet_prefix
    destination_port_range     = "80"
    direction                  = "Outbound"
    name                       = "AllowOutboundToWebAppHTTP"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = var.spoke_api_networking_pe_subnet_prefix
    destination_port_range     = "443"
    direction                  = "Outbound"
    name                       = "AllowOutboundToWebAppHTTPS"
    priority                   = 110
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "AzureMonitor"
    destination_port_range     = "443"
    direction                  = "Outbound"
    name                       = "AllowOutboundToAzureMonitor"
    priority                   = 140
    protocol                   = "Tcp"
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

resource "random_string" "nsg_ag_suffix" {
  length  = var.spoke_api_networking_nsg_ag_random_suffix_length
  special = var.spoke_api_networking_nsg_ag_random_suffix_special
  upper   = var.spoke_api_networking_nsg_ag_random_suffix_upper
}

# Private Endpoints NSG
resource "azurerm_network_security_group" "nsg_pe" {
  location            = var.spoke_api_networking_location
  name                = "${module.naming.network_security_group.name}-pe-${random_string.nsg_pe_suffix.result}"
  resource_group_name = var.spoke_api_networking_resource_group_name

  # Inbound Rules - Specific access for each service

  # Web App Private Endpoint - Allow Application Gateway to access private endpoints
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "AllowInboundFromAppGateway"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = var.spoke_api_networking_ag_subnet_prefix
    source_port_range          = "*"
  }

  # Web App Private Endpoint - Allow Application Gateway HTTP access
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "80"
    direction                  = "Inbound"
    name                       = "AllowInboundWebAppHTTPFromAppGateway"
    priority                   = 110
    protocol                   = "Tcp"
    source_address_prefix      = "AzureLoadBalancer"
    source_port_range          = "*"
  }

  # Web App Private Endpoint - Allow Application Gateway HTTPS access
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "AllowInboundWebAppHTTPSFromAppGateway"
    priority                   = 120
    protocol                   = "Tcp"
    source_address_prefix      = "AzureLoadBalancer"
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

resource "random_string" "nsg_pe_suffix" {
  length  = var.spoke_api_networking_nsg_pe_random_suffix_length
  special = var.spoke_api_networking_nsg_pe_random_suffix_special
  upper   = var.spoke_api_networking_nsg_pe_random_suffix_upper
}

# Web App NSG
resource "azurerm_network_security_group" "nsg_wa" {
  location            = var.spoke_api_networking_location
  name                = "${module.naming.network_security_group.name}-wa-${random_string.nsg_wa_suffix.result}"
  resource_group_name = var.spoke_api_networking_resource_group_name

  # Inbound Rules - Only from Application Gateway
  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "80"
    direction                  = "Inbound"
    name                       = "AllowInboundHTTPFromAppGateway"
    priority                   = 100
    protocol                   = "Tcp"
    source_address_prefix      = var.spoke_api_networking_ag_subnet_prefix
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "*"
    destination_port_range     = "443"
    direction                  = "Inbound"
    name                       = "AllowInboundHTTPSFromAppGateway"
    priority                   = 110
    protocol                   = "Tcp"
    source_address_prefix      = var.spoke_api_networking_ag_subnet_prefix
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

  # Outbound Rules - Allow to private endpoints and Azure services
  security_rule {
    access = "Allow"
    destination_address_prefixes = [
      var.spoke_api_networking_pe_subnet_prefix, # Local private endpoints
      var.hub_networking_pe_subnet_prefix        # Hub private endpoints (ACR, etc.)
    ]
    destination_port_range = "443"
    direction              = "Outbound"
    name                   = "AllowOutboundToPrivateEndpoints"
    priority               = 100
    protocol               = "Tcp"
    source_address_prefix  = "*"
    source_port_range      = "*"
  }

  # Allow outbound to AI spoke for cross-spoke communication
  security_rule {
    access                       = "Allow"
    destination_address_prefixes = var.spoke_ai_vnet_address_space
    destination_port_range       = "443"
    direction                    = "Outbound"
    name                         = "AllowOutboundToAISpoke"
    priority                     = 110
    protocol                     = "Tcp"
    source_address_prefix        = "*"
    source_port_range            = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "AzureMonitor"
    destination_port_range     = "443"
    direction                  = "Outbound"
    name                       = "AllowOutboundToAzureMonitor"
    priority                   = 120
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

  security_rule {
    access                     = "Allow"
    destination_address_prefix = "AzureActiveDirectory"
    destination_port_range     = "443"
    direction                  = "Outbound"
    name                       = "AllowOutboundToAzureAD"
    priority                   = 150
    protocol                   = "Tcp"
    source_address_prefix      = "*"
    source_port_range          = "*"
  }

   security_rule {
    access                     = "Allow"
    destination_address_prefix = var.hub_networking_pe_subnet_prefix
    destination_port_range     = "5432"
    direction                  = "Outbound"
    name                       = "AllowOutboundToPGSQL"
    priority                   = 130
    protocol                   = "Tcp"
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

resource "random_string" "nsg_wa_suffix" {
  length  = var.spoke_api_networking_nsg_wa_random_suffix_length
  special = var.spoke_api_networking_nsg_wa_random_suffix_special
  upper   = var.spoke_api_networking_nsg_wa_random_suffix_upper
}

resource "azurerm_virtual_network" "vnet_api" {
  name                = "${module.naming.virtual_network.name}-${random_string.vnet_suffix.result}"
  location            = var.spoke_api_networking_location
  resource_group_name = var.spoke_api_networking_resource_group_name
  address_space       = var.spoke_api_networking_vnet_address_space
}

resource "random_string" "vnet_suffix" {
  length  = var.spoke_api_networking_vnet_random_suffix_length
  special = var.spoke_api_networking_vnet_random_suffix_special
  upper   = var.spoke_api_networking_vnet_random_suffix_upper
}

resource "azurerm_subnet" "subnet_ag" {
  name                 = "${module.naming.subnet.name}-ag-${random_string.subnet_ag_suffix.result}"
  resource_group_name  = var.spoke_api_networking_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_api.name
  address_prefixes     = [var.spoke_api_networking_ag_subnet_prefix]

  delegation {
    name = "appgw-delegation"
    service_delegation {
      name = "Microsoft.Network/applicationGateways"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }
}

resource "random_string" "subnet_ag_suffix" {
  length  = var.spoke_api_networking_subnet_ag_random_suffix_length
  special = var.spoke_api_networking_subnet_ag_random_suffix_special
  upper   = var.spoke_api_networking_subnet_ag_random_suffix_upper
}

resource "azurerm_subnet" "subnet_pe" {
  name                 = "${module.naming.subnet.name}-pe-${random_string.subnet_pe_suffix.result}"
  resource_group_name  = var.spoke_api_networking_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_api.name
  address_prefixes     = [var.spoke_api_networking_pe_subnet_prefix]
}

resource "random_string" "subnet_pe_suffix" {
  length  = var.spoke_api_networking_subnet_pe_random_suffix_length
  special = var.spoke_api_networking_subnet_pe_random_suffix_special
  upper   = var.spoke_api_networking_subnet_pe_random_suffix_upper
}

resource "azurerm_subnet" "subnet_wa" {
  name                 = "${module.naming.subnet.name}-wa-${random_string.subnet_wa_suffix.result}"
  resource_group_name  = var.spoke_api_networking_resource_group_name
  virtual_network_name = azurerm_virtual_network.vnet_api.name
  address_prefixes     = [var.spoke_api_networking_wa_subnet_prefix]

  delegation {
    name = "webapp-delegation"

    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action"
      ]
    }
  }

  service_endpoints = ["Microsoft.Storage"]
}

resource "random_string" "subnet_wa_suffix" {
  length  = var.spoke_api_networking_subnet_wa_random_suffix_length
  special = var.spoke_api_networking_subnet_wa_random_suffix_special
  upper   = var.spoke_api_networking_subnet_wa_random_suffix_upper
}

resource "azurerm_subnet_network_security_group_association" "ag" {
  subnet_id                 = azurerm_subnet.subnet_ag.id
  network_security_group_id = azurerm_network_security_group.nsg_ag.id
}

resource "azurerm_subnet_network_security_group_association" "pe" {
  subnet_id                 = azurerm_subnet.subnet_pe.id
  network_security_group_id = azurerm_network_security_group.nsg_pe.id
}

resource "azurerm_subnet_network_security_group_association" "wa" {
  subnet_id                 = azurerm_subnet.subnet_wa.id
  network_security_group_id = azurerm_network_security_group.nsg_wa.id
}

resource "azurerm_route_table" "api_route_table" {
  name                = "${module.naming.route_table.name}-${random_string.route_table_suffix.result}"
  location            = var.spoke_api_networking_location
  resource_group_name = var.spoke_api_networking_resource_group_name
}

resource "azurerm_route" "api_route" {
  name                = "to-spoke-ai"
  resource_group_name = var.spoke_api_networking_resource_group_name
  route_table_name    = azurerm_route_table.api_route_table.name
  address_prefix      = "0.0.0.0/0"
  next_hop_type       = "VirtualAppliance"
  next_hop_in_ip_address = var.hub_azure_firewall_public_ip_address
}

resource "azurerm_subnet_route_table_association" "api_route_table_association" {
  subnet_id      = azurerm_subnet.subnet_wa.id
  route_table_id = azurerm_route_table.api_route_table.id
}

resource "random_string" "route_table_suffix" {
  length  = var.spoke_api_networking_route_table_random_suffix_length
  special = var.spoke_api_networking_route_table_random_suffix_special
  upper   = var.spoke_api_networking_route_table_random_suffix_upper
}
