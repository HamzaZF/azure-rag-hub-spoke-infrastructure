module "naming" {
  source = "Azure/naming/azurerm"
  prefix = [var.naming_company, var.naming_product, var.naming_environment, "api"]
  suffix = [var.naming_region]
}

# -----------------------------------------------------------------------------
# Public IP for Application Gateway (when public-facing)
# -----------------------------------------------------------------------------
resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "${module.naming.public_ip.name}-appgw"
  resource_group_name = var.spoke_api_ag_resource_group_name
  location            = var.spoke_api_ag_location
  allocation_method   = "Static"
  sku                 = "Standard"
  
  tags = {
    Purpose = "Application Gateway Public IP"
    Environment = var.naming_environment
  }
}

# -----------------------------------------------------------------------------
# Application Gateway with WAF (Public-facing with SSL Termination)
# -----------------------------------------------------------------------------
resource "azurerm_application_gateway" "appgw_waf" {
  name                = "${module.naming.application_gateway.name}-${random_string.appgw_suffix.result}"

  resource_group_name = var.spoke_api_ag_resource_group_name
  location            = var.spoke_api_ag_location

  # WAF policy reference
  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id

  autoscale_configuration {
    min_capacity = var.spoke_api_ag_autoscale_min_capacity
    max_capacity = var.spoke_api_ag_autoscale_max_capacity
  }

  # WAF_v2 SKU
  sku {
    name = var.spoke_api_ag_waf_sku_name
    tier = var.spoke_api_ag_waf_sku_tier
  }

  gateway_ip_configuration {
    name      = var.spoke_api_ag_gateway_ip_configuration_name
    subnet_id = var.spoke_api_ag_subnet_id
  }

  # HTTPS Frontend Port (443)
  frontend_port {
    name = var.spoke_api_ag_frontend_port_name
    port = var.spoke_api_ag_frontend_port
  }

  # HTTP Frontend Port (80) for redirect to HTTPS
  frontend_port {
    name = "frontend-http-port-redirect"
    port = var.spoke_api_ag_frontend_port_http
  }

  # HTTPS Listener with SSL Certificate
  http_listener {
    name                           = var.spoke_api_ag_listener_name
    frontend_ip_configuration_name = var.spoke_api_ag_frontend_ip_configuration_name
    frontend_port_name             = var.spoke_api_ag_frontend_port_name
    protocol                       = var.spoke_api_ag_frontend_protocol
    ssl_certificate_name           = var.spoke_api_ag_ssl_certificate_name
  }

  # HTTP Listener for redirect to HTTPS
  http_listener {
    name                           = "listener-http-redirect"
    frontend_ip_configuration_name = var.spoke_api_ag_frontend_ip_configuration_name
    frontend_port_name             = "frontend-http-port-redirect"
    protocol                       = "Http"
  }

  # SSL Certificate for HTTPS termination
  # ssl_certificate {
  #   name     = var.spoke_api_ag_ssl_certificate_name
  #   data     = filebase64(var.spoke_api_ag_ssl_certificate_path)
  #   password = var.spoke_api_ag_ssl_certificate_password
  # }
  ssl_certificate {
    name     = var.spoke_api_ag_ssl_certificate_name
    # key_vault_secret_id = var.spoke_api_ag_ssl_certificate_key_vault_secret_id
    data     = filebase64(var.spoke_api_ag_ssl_certificate_path)
    password = var.spoke_api_ag_ssl_certificate_password
  }

  # Frontend IP Configuration - Public IP
  frontend_ip_configuration {
    name                 = var.spoke_api_ag_frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }

  backend_address_pool {
    name  = var.spoke_api_ag_backend_address_pool_name
    fqdns = [var.web_app_fqdn]
  }

  backend_http_settings {
    name                                = var.spoke_api_ag_http_setting_name
    cookie_based_affinity               = var.spoke_api_ag_cookie_based_affinity
    port                                = var.spoke_api_ag_backend_port
    protocol                            = var.spoke_api_ag_backend_protocol
    request_timeout                     = var.spoke_api_ag_request_timeout
    pick_host_name_from_backend_address = var.spoke_api_ag_pick_host_name_from_backend_address
    host_name                           = var.web_app_fqdn
    probe_name                          = var.spoke_api_ag_probe_name
  }

  # HTTPS Request Routing Rule
  request_routing_rule {
    name                       = var.spoke_api_ag_request_routing_rule_name
    priority                   = var.spoke_api_ag_request_routing_rule_priority
    rule_type                  = var.spoke_api_ag_request_routing_rule_type
    http_listener_name         = var.spoke_api_ag_listener_name
    backend_address_pool_name  = var.spoke_api_ag_backend_address_pool_name
    backend_http_settings_name = var.spoke_api_ag_http_setting_name
  }

  # HTTP to HTTPS Redirect Rule
  request_routing_rule {
    name                        = "rule-http-redirect"
    priority                    = 10
    rule_type                   = "Basic"
    http_listener_name          = "listener-http-redirect"
    redirect_configuration_name = "redirect-http-to-https"
  }

  # Redirect Configuration for HTTP to HTTPS
  redirect_configuration {
    name                 = "redirect-http-to-https"
    redirect_type        = "Permanent"
    target_listener_name = var.spoke_api_ag_listener_name
    include_path         = true
    include_query_string = true
  }

  probe {
    name                                      = var.spoke_api_ag_probe_name
    protocol                                  = var.spoke_api_ag_probe_protocol
    port                                      = var.spoke_api_ag_backend_port
    path                                      = var.spoke_api_ag_probe_path
    interval                                  = var.spoke_api_ag_probe_interval # seconds
    timeout                                   = var.spoke_api_ag_probe_timeout
    unhealthy_threshold                       = var.spoke_api_ag_probe_unhealthy_threshold
    pick_host_name_from_backend_http_settings = var.spoke_api_ag_pick_host_name_from_backend_http_settings

    match {
      status_code = var.spoke_api_ag_probe_status_codes
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [var.app_gateway_identity_id]
  }
}

resource "random_string" "appgw_suffix" {
  length  = var.spoke_api_ag_random_suffix_length
  special = var.spoke_api_ag_random_suffix_special
  upper   = var.spoke_api_ag_random_suffix_upper
}

# -----------------------------------------------------------------------------
# WAF Policy with Custom Rules
# -----------------------------------------------------------------------------
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "api-gateway-waf-policy"
  resource_group_name = var.spoke_api_ag_resource_group_name
  location            = var.spoke_api_ag_location

  policy_settings {
    enabled            = var.spoke_api_ag_waf_policy_enabled
    mode               = var.spoke_api_ag_waf_policy_mode
    request_body_check = var.spoke_api_ag_waf_policy_request_body_check
  }

  managed_rules {
    managed_rule_set {
      type    = var.spoke_api_ag_waf_policy_managed_rule_set_type
      version = var.spoke_api_ag_waf_policy_managed_rule_set_version
    }
  }
}
