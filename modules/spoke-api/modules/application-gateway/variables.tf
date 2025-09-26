/*
  variables.tf (Spoke API Application Gateway Submodule)

  This file defines all input variables for the Kelix Azure Spoke API Application Gateway submodule.
*/

# -----------------------------------------------------------------------------
# Core Configuration
# -----------------------------------------------------------------------------

# The Azure region where the Application Gateway will be deployed.
variable "spoke_api_ag_location" {
  description = "The Azure region where the Application Gateway will be deployed."
  type        = string
}

# The name of the resource group where the Application Gateway will be deployed.
variable "spoke_api_ag_resource_group_name" {
  description = "The name of the resource group where the Application Gateway will be deployed."
  type        = string
}

# The ID of the subnet where the Application Gateway will be deployed.
variable "spoke_api_ag_subnet_id" {
  description = "The ID of the subnet where the Application Gateway will be deployed."
  type        = string
}

# The private IP address for the Application Gateway frontend (internal access only)
variable "spoke_api_ag_private_ip_address" {
  description = "The private IP address for the Application Gateway frontend configuration."
  type        = string
  default     = "10.1.0.10"
}

# Application Gateway is configured for public IP with SSL termination
# No longer configurable - always uses public IP

# The FQDN of the web app for the backend pool
variable "web_app_fqdn" {
  description = "The FQDN of the web app for the backend pool."
  type        = string
}

# The private IP address of the web app private endpoint for the backend pool
variable "web_app_private_ip" {
  description = "The private IP address of the web app private endpoint for the backend pool."
  type        = string
}

# Random suffix configuration for application gateway
variable "spoke_api_ag_random_suffix_length" {
  description = "The length of the random suffix for the application gateway name."
  type        = number
  default     = 4
}

variable "spoke_api_ag_random_suffix_special" {
  description = "Whether to include special characters in the application gateway random suffix."
  type        = bool
  default     = false
}

variable "spoke_api_ag_random_suffix_upper" {
  description = "Whether to include uppercase letters in the application gateway random suffix."
  type        = bool
  default     = false
}

# -----------------------------------------------------------------------------
# Application Gateway Configuration
# -----------------------------------------------------------------------------

variable "spoke_api_ag_autoscale_min_capacity" {
  description = "The minimum capacity for Application Gateway autoscaling."
  type        = number
  default     = 1
}

variable "spoke_api_ag_autoscale_max_capacity" {
  description = "The maximum capacity for Application Gateway autoscaling."
  type        = number
  default     = 2
}

variable "spoke_api_ag_frontend_port" {
  description = "The frontend port for the Application Gateway (HTTPS)."
  type        = number
  default     = 443
}

variable "spoke_api_ag_frontend_port_http" {
  description = "The HTTP frontend port for the Application Gateway (for redirect)."
  type        = number
  default     = 80
}

variable "spoke_api_ag_backend_port" {
  description = "The backend port for the Application Gateway."
  type        = number
  default     = 443
}

variable "spoke_api_ag_backend_protocol" {
  description = "The backend protocol for the Application Gateway."
  type        = string
  default     = "Https"
}

variable "spoke_api_ag_request_timeout" {
  description = "The request timeout for the Application Gateway backend settings."
  type        = number
  default     = 60
}

variable "spoke_api_ag_probe_interval" {
  description = "The interval for Application Gateway health probe."
  type        = number
  default     = 30
}

variable "spoke_api_ag_probe_timeout" {
  description = "The timeout for Application Gateway health probe."
  type        = number
  default     = 30
}

variable "spoke_api_ag_probe_unhealthy_threshold" {
  description = "The unhealthy threshold for Application Gateway health probe."
  type        = number
  default     = 3
}

variable "spoke_api_ag_probe_path" {
  description = "The path for Application Gateway health probe."
  type        = string
  default     = "/healthcheck"
}

variable "spoke_api_ag_cookie_based_affinity" {
  description = "The cookie-based affinity setting for Application Gateway backend settings."
  type        = string
  default     = "Disabled"
}

variable "spoke_api_ag_probe_protocol" {
  description = "The protocol for Application Gateway health probe."
  type        = string
  default     = "Https"
}

variable "spoke_api_ag_probe_status_codes" {
  description = "The status codes for Application Gateway health probe match."
  type        = list(string)
  default     = ["200-399"]
}

variable "spoke_api_ag_frontend_protocol" {
  description = "The frontend protocol for Application Gateway HTTP listener."
  type        = string
  default     = "Https"
}

# SSL Certificate Configuration
variable "spoke_api_ag_ssl_certificate_name" {
  description = "The name for the SSL certificate in Application Gateway."
  type        = string
  default     = "api-gateway-ssl-cert"
}

variable "spoke_api_ag_ssl_certificate_path" {
  description = "The path to the SSL certificate PFX file."
  type        = string
}

variable "spoke_api_ag_ssl_certificate_password" {
  description = "The password for the SSL certificate PFX file."
  type        = string
  sensitive   = true
}

# SSL termination is always enabled - no longer configurable

variable "spoke_api_ag_request_routing_rule_type" {
  description = "The rule type for Application Gateway request routing rule."
  type        = string
  default     = "Basic"
}

variable "spoke_api_ag_waf_sku_name" {
  description = "The SKU name for Application Gateway with WAF."
  type        = string
  default     = "WAF_v2"
}

variable "spoke_api_ag_waf_sku_tier" {
  description = "The SKU tier for Application Gateway with WAF."
  type        = string
  default     = "WAF_v2"
}

variable "spoke_api_ag_standard_sku_name" {
  description = "The SKU name for Application Gateway without WAF."
  type        = string
  default     = "Standard_v2"
}

variable "spoke_api_ag_standard_sku_tier" {
  description = "The SKU tier for Application Gateway without WAF."
  type        = string
  default     = "Standard_v2"
}

variable "spoke_api_ag_gateway_ip_configuration_name" {
  description = "The name for Application Gateway IP configuration."
  type        = string
  default     = "gateway-ip-configuration-api"
}

variable "spoke_api_ag_probe_name" {
  description = "The name for Application Gateway health probe."
  type        = string
  default     = "health-probe"
}

variable "spoke_api_ag_backend_address_pool_name" {
  description = "The name for Application Gateway backend address pool."
  type        = string
  default     = "backend--pool-api"
}

variable "spoke_api_ag_frontend_port_name" {
  description = "The name for Application Gateway frontend port."
  type        = string
  default     = "frontend-http-port-api"
}

variable "spoke_api_ag_frontend_ip_configuration_name" {
  description = "The name for Application Gateway frontend IP configuration."
  type        = string
  default     = "frontend-ip-configuration-api"
}

variable "spoke_api_ag_http_setting_name" {
  description = "The name for Application Gateway HTTP settings."
  type        = string
  default     = "backkend-settings-api"
}

variable "spoke_api_ag_listener_name" {
  description = "The name for Application Gateway HTTP listener."
  type        = string
  default     = "listener-api"
}

variable "spoke_api_ag_request_routing_rule_name" {
  description = "The name for Application Gateway request routing rule."
  type        = string
  default     = "rule-api"
}

variable "spoke_api_ag_request_routing_rule_priority" {
  description = "The priority for the Application Gateway request routing rule."
  type        = number
  default     = 9
}

variable "spoke_api_ag_pick_host_name_from_backend_address" {
  description = "Whether to pick host name from backend address in Application Gateway backend settings."
  type        = bool
  default     = false
}

variable "spoke_api_ag_pick_host_name_from_backend_http_settings" {
  description = "Whether to pick host name from backend HTTP settings in Application Gateway probe."
  type        = bool
  default     = true
}

variable "spoke_api_ag_waf_policy_enabled" {
  description = "Whether the WAF policy is enabled."
  type        = bool
  default     = true
}

variable "spoke_api_ag_waf_policy_request_body_check" {
  description = "Whether to enable request body check in WAF policy."
  type        = bool
  default     = true
}

variable "spoke_api_ag_waf_policy_mode" {
  description = "The mode for the WAF policy."
  type        = string
  default     = "Prevention"
}

variable "spoke_api_ag_waf_policy_managed_rule_set_type" {
  description = "The managed rule set type for the WAF policy."
  type        = string
  default     = "OWASP"
}

variable "spoke_api_ag_waf_policy_managed_rule_set_version" {
  description = "The managed rule set version for the WAF policy."
  type        = string
  default     = "3.2"
}

# Naming Convention
variable "naming_company" {
  description = "Company or organization name for resource naming."
  type        = string
}

variable "naming_product" {
  description = "Product or application name for resource naming."
  type        = string
}

variable "naming_environment" {
  description = "Deployment environment (e.g., dev, staging, prod) for resource naming."
  type        = string
}

variable "naming_region" {
  description = "Azure region for resource naming."
  type        = string
}

variable "app_gateway_identity_id" {
  description = "The ID of the user assigned identity for the Application Gateway."
  type        = string
}
