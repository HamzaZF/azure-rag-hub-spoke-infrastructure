/*
  outputs.tf

  This file exposes key outputs from the Kelix Azure Terraform root module.
  Outputs are grouped by logical scope:
    - Hub: Core network and services
    - Spoke API: API workloads
    - Spoke AI: AI workloads
  Each output is documented for clarity and maintainability.
*/

# -----------------------------------------------------------------------------
# Hub Outputs
# -----------------------------------------------------------------------------

# The name of the resource group for the hub
output "hub_resource_group_name" {
  description = "The name of the resource group for the hub."
  value       = module.hub.hub_resource_group_name
}

# The ID of the hub virtual network
output "hub_vnet_id" {
  description = "The ID of the hub virtual network."
  value       = module.hub.hub_vnet_id
}

# The resource ID of the Blob Storage account
output "hub_blob_storage_account_id" {
  description = "The resource ID of the Blob Storage account."
  value       = module.hub.hub_blob_storage_account_id
}

# The ID of the PostgreSQL Flexible Server
output "hub_postgresql_server_id" {
  description = "The ID of the PostgreSQL Flexible Server."
  value       = module.hub.hub_postgresql_server_id
}

# The ID of the AI Search service
output "hub_ai_search_service_id" {
  description = "The ID of the AI Search service."
  value       = module.hub.hub_ai_search_service_id
}

# The ID of the OpenAI Cognitive Service
output "hub_openai_cognitive_account_id" {
  description = "The ID of the OpenAI Cognitive Service."
  value       = module.hub.hub_openai_cognitive_account_id
}

# The name of the hub VM
output "hub_vm_name" {
  description = "The name of the hub VM."
  value       = module.hub.hub_vm_name
}

# -----------------------------------------------------------------------------
# Spoke API Outputs
# -----------------------------------------------------------------------------

# The name of the resource group for the API spoke
output "spoke_api_resource_group_name" {
  description = "The name of the resource group for the API spoke."
  value       = module.spoke_api.resource_group_name
}

# The ID of the API spoke virtual network
output "spoke_api_vnet_id" {
  description = "The ID of the API spoke virtual network."
  value       = module.spoke_api.spoke_api_vnet_id
}

# -----------------------------------------------------------------------------
# Service Names for Testing
# -----------------------------------------------------------------------------

# Blob Storage Account Name
output "hub_blob_storage_account_name" {
  description = "The name of the Blob Storage account."
  value       = module.hub.hub_blob_storage_account_name
}

# PostgreSQL Server Name
output "hub_postgresql_server_name" {
  description = "The name of the PostgreSQL Flexible Server."
  value       = module.hub.hub_postgresql_server_name
}

# AI Search Service Name
output "hub_ai_search_service_name" {
  description = "The name of the AI Search service."
  value       = module.hub.hub_ai_search_service_name
}

# OpenAI Cognitive Account Name
# output "hub_openai_cognitive_account_name" {
#   description = "The name of the OpenAI Cognitive Service."
#   value       = module.hub.hub_openai_cognitive_account_name
# }

# ACR Name
output "spoke_api_acr_name" {
  description = "The name of the Azure Container Registry."
  value       = module.spoke_api.spoke_api_acr_name
}

# Web App Name
output "spoke_api_web_app_name" {
  description = "The name of the Web App."
  value       = module.spoke_api.spoke_api_web_app_name
}

# Application Gateway Public IP
output "spoke_api_application_gateway_public_ip" {
  description = "The public IP address of the Application Gateway."
  value       = module.spoke_api.spoke_api_ag_frontend_ip
}

# -----------------------------------------------------------------------------
# Network Security Testing Outputs
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# Hub Private Endpoints for Network Security Testing
# -----------------------------------------------------------------------------

output "hub_blob_storage_private_endpoint_ip" {
  description = "The private IP address of the Blob Storage private endpoint for network security testing."
  value       = module.hub.hub_pe_blob_storage_private_endpoint_ip
}

output "hub_blob_storage_private_endpoint_fqdn" {
  description = "The FQDN for the Blob Storage private endpoint (for DNS testing)."
  value       = "${module.hub.hub_blob_storage_account_name}.blob.core.windows.net"
}

# PostgreSQL Private Endpoint
output "hub_postgresql_private_endpoint_id" {
  description = "The ID of the PostgreSQL private endpoint for network security testing."
  value       = module.hub.hub_pe_postgresql_private_endpoint_id
}

output "hub_postgresql_private_endpoint_ip" {
  description = "The private IP address of the PostgreSQL private endpoint for network security testing."
  value       = module.hub.hub_pe_postgresql_private_endpoint_ip
}

output "hub_postgresql_private_endpoint_fqdn" {
  description = "The FQDN for the PostgreSQL private endpoint (for DNS testing)."
  value       = "${module.hub.hub_postgresql_server_name}.postgres.database.azure.com"
}

# AI Search Private Endpoint
output "hub_ai_search_private_endpoint_id" {
  description = "The ID of the AI Search private endpoint for network security testing."
  value       = module.hub.hub_pe_ai_search_private_endpoint_id
}

output "hub_ai_search_private_endpoint_ip" {
  description = "The private IP address of the AI Search private endpoint for network security testing."
  value       = module.hub.hub_pe_ai_search_private_endpoint_ip
}

output "hub_ai_search_private_endpoint_fqdn" {
  description = "The FQDN for the AI Search private endpoint (for DNS testing)."
  value       = "${module.hub.hub_ai_search_service_name}.search.windows.net"
}

output "hub_openai_private_endpoint_ip" {
  description = "The private IP address of the OpenAI private endpoint for network security testing."
  value       = module.hub.hub_pe_openai_private_endpoint_ip
}

# output "hub_openai_private_endpoint_fqdn" {
#   description = "The FQDN for the OpenAI private endpoint (for DNS testing)."
#   value       = "${module.hub.openai}.openai.azure.com"
# }

# -----------------------------------------------------------------------------
# Spoke API Private Endpoints for Network Security Testing
# -----------------------------------------------------------------------------

# ACR Private Endpoint
output "hub_acr_private_endpoint_id" {
  description = "The ID of the ACR private endpoint for network security testing (from hub)."
  value       = module.hub.hub_pe_acr_private_endpoint_id
}

output "hub_acr_private_endpoint_ip" {
  description = "The private IP address of the ACR private endpoint for network security testing (from hub)."
  value       = module.hub.hub_pe_acr_private_endpoint_ip
}

output "spoke_api_acr_private_endpoint_fqdn" {
  description = "The FQDN for the ACR private endpoint (for DNS testing)."
  value       = "${module.spoke_api.spoke_api_acr_name}.azurecr.io"
}

# Web App Private Endpoint
output "spoke_api_web_app_private_endpoint_id" {
  description = "The ID of the Web App private endpoint for network security testing."
  value       = module.spoke_api.spoke_api_pe_web_app_private_endpoint_id
}

output "spoke_api_web_app_private_endpoint_ip" {
  description = "The private IP address of the Web App private endpoint for network security testing."
  value       = module.spoke_api.spoke_api_pe_web_app_private_endpoint_ip
}

output "spoke_api_web_app_private_endpoint_fqdn" {
  description = "The FQDN for the Web App private endpoint (for DNS testing)."
  value       = "${module.spoke_api.spoke_api_web_app_name}.azurewebsites.net"
}

# -----------------------------------------------------------------------------
# Network Security Testing Summary Outputs
# -----------------------------------------------------------------------------

# # All Private Endpoints for External Testing (from external VM)
# output "external_test_targets" {
#   description = "All private endpoints and services for external network security testing."
#   value = {
#     hub_services = {
#       blob_storage = {
#         service_name = module.hub.hub_blob_storage_account_name
#         private_ip   = module.hub.hub_pe_blob_storage_private_endpoint_ip
#         fqdn         = "${module.hub.hub_blob_storage_account_name}.blob.core.windows.net"
#         port         = 443
#         protocol     = "HTTPS"
#       }
#       postgresql = {
#         service_name = module.hub.hub_postgresql_server_name
#         private_ip   = module.hub.hub_pe_postgresql_private_endpoint_ip
#         fqdn         = "${module.hub.hub_postgresql_server_name}.postgres.database.azure.com"
#         port         = 5432
#         protocol     = "TCP"
#       }
#       ai_search = {
#         service_name = module.hub.hub_ai_search_service_name
#         private_ip   = module.hub.hub_pe_ai_search_private_endpoint_ip
#         fqdn         = "${module.hub.hub_ai_search_service_name}.search.windows.net"
#         port         = 443
#         protocol     = "HTTPS"
#       }
#       openai = {
#         service_name = module.hub.hub_openai_cognitive_account_name
#         private_ip   = module.hub.hub_pe_openai_private_endpoint_ip
#         fqdn         = "${module.hub.hub_openai_cognitive_account_name}.openai.azure.com"
#         port         = 443
#         protocol     = "HTTPS"
#       }
#     }
#     spoke_api_services = {
#       acr = {
#         service_name = module.hub.hub_acr_name
#         private_ip   = module.hub.hub_pe_acr_private_endpoint_ip
#         fqdn         = "${module.hub.hub_acr_name}.azurecr.io"
#         port         = 443
#         protocol     = "HTTPS"
#       }
#       web_app = {
#         service_name = module.spoke_api.spoke_api_web_app_name
#         private_ip   = module.spoke_api.spoke_api_pe_web_app_private_endpoint_ip
#         fqdn         = "${module.spoke_api.spoke_api_web_app_name}.azurewebsites.net"
#         port         = 443
#         protocol     = "HTTPS"
#       }
#     }
#   }
# }

# # All Private Endpoints for Internal Testing (from hub VM)
# output "internal_test_targets" {
#   description = "All private endpoints and services for internal network security testing from hub VM."
#   value = {
#     hub_services = {
#       blob_storage = {
#         service_name = module.hub.hub_blob_storage_account_name
#         private_ip   = module.hub.hub_pe_blob_storage_private_endpoint_ip
#         fqdn         = "${module.hub.hub_blob_storage_account_name}.blob.core.windows.net"
#         port         = 443
#         protocol     = "HTTPS"
#         subnet       = "hub-private-endpoint-subnet"
#       }
#       postgresql = {
#         service_name = module.hub.hub_postgresql_server_name
#         private_ip   = module.hub.hub_pe_postgresql_private_endpoint_ip
#         fqdn         = "${module.hub.hub_postgresql_server_name}.postgres.database.azure.com"
#         port         = 5432
#         protocol     = "TCP"
#         subnet       = "hub-private-endpoint-subnet"
#       }
#       ai_search = {
#         service_name = module.hub.hub_ai_search_service_name
#         private_ip   = module.hub.hub_pe_ai_search_private_endpoint_ip
#         fqdn         = "${module.hub.hub_ai_search_service_name}.search.windows.net"
#         port         = 443
#         protocol     = "HTTPS"
#         subnet       = "hub-private-endpoint-subnet"
#       }
#       openai = {
#         service_name = module.hub.hub_openai_cognitive_account_name
#         private_ip   = module.hub.hub_pe_openai_private_endpoint_ip
#         fqdn         = "${module.hub.hub_openai_cognitive_account_name}.openai.azure.com"
#         port         = 443
#         protocol     = "HTTPS"
#         subnet       = "hub-private-endpoint-subnet"
#       }
#     }
#     spoke_api_services = {
#       acr = {
#         service_name = module.hub.hub_acr_name
#         private_ip   = module.hub.hub_pe_acr_private_endpoint_ip
#         fqdn         = "${module.hub.hub_acr_name}.azurecr.io"
#         port         = 443
#         protocol     = "HTTPS"
#         subnet       = "hub-private-endpoint-subnet"
#       }
#       web_app = {
#         service_name = module.spoke_api.spoke_api_web_app_name
#         private_ip   = module.spoke_api.spoke_api_pe_web_app_private_endpoint_ip
#         fqdn         = "${module.spoke_api.spoke_api_web_app_name}.azurewebsites.net"
#         port         = 443
#         protocol     = "HTTPS"
#         subnet       = "spoke-api-private-endpoint-subnet"
#       }
#     }
#   }
# }

# # Network Security Testing Commands
# output "network_security_test_commands" {
#   description = "Pre-built commands for network security testing from external and internal VMs."
#   value = {
#     external_vm_commands = {
#       # Test connectivity to hub services from external VM
#       test_hub_blob_storage = "curl -k -I https://${module.hub.hub_blob_storage_account_name}.blob.core.windows.net"
#       test_hub_postgresql   = "nc -zv ${module.hub.hub_pe_postgresql_private_endpoint_ip} 5432"
#       test_hub_ai_search    = "curl -k -I https://${module.hub.hub_ai_search_service_name}.search.windows.net"
#       test_hub_openai       = "curl -k -I https://${module.hub.hub_openai_cognitive_account_name}.openai.azure.com"

#       # Test connectivity to spoke API services from external VM
#       test_spoke_api_acr    = "curl -k -I https://${module.spoke_api.spoke_api_acr_name}.azurecr.io"
#       test_spoke_api_webapp = "curl -k -I https://${module.spoke_api.spoke_api_web_app_name}.azurewebsites.net"
#     }
#     internal_vm_commands = {
#       # Test connectivity to hub services from internal VM (should succeed)
#       test_hub_blob_storage = "curl -I https://${module.hub.hub_blob_storage_account_name}.blob.core.windows.net"
#       test_hub_postgresql   = "nc -zv ${module.hub.hub_pe_postgresql_private_endpoint_ip} 5432"
#       test_hub_ai_search    = "curl -I https://${module.hub.hub_ai_search_service_name}.search.windows.net"
#       test_hub_openai       = "curl -I https://${module.hub.hub_openai_cognitive_account_name}.openai.azure.com"

#       # Test connectivity to spoke API services from internal VM
#       test_spoke_api_acr    = "curl -I https://${module.spoke_api.spoke_api_acr_name}.azurecr.io"
#       test_spoke_api_webapp = "curl -I https://${module.spoke_api.spoke_api_web_app_name}.azurewebsites.net"
#     }
#   }
# }

# # DNS Resolution Testing Information
# output "dns_testing_info" {
#   description = "DNS zones and resolution information for network security testing."
#   value = {
#     hub_dns_zones = {
#       blob_storage = {
#         zone_id   = module.hub.hub_pe_blob_storage_private_dns_zone_id
#         zone_name = module.hub.hub_pe_blob_storage_private_dns_zone_name
#         fqdn      = "${module.hub.hub_blob_storage_account_name}.blob.core.windows.net"
#       }
#       postgresql = {
#         zone_id   = module.hub.hub_pe_postgresql_private_dns_zone_id
#         zone_name = module.hub.hub_pe_postgresql_private_dns_zone_name
#         fqdn      = "${module.hub.hub_postgresql_server_name}.postgres.database.azure.com"
#       }
#       ai_search = {
#         zone_id   = module.hub.hub_pe_ai_search_private_dns_zone_id
#         zone_name = module.hub.hub_pe_ai_search_private_dns_zone_name
#         fqdn      = "${module.hub.hub_ai_search_service_name}.search.windows.net"
#       }
#       openai = {
#         zone_id   = module.hub.hub_pe_openai_private_dns_zone_id
#         zone_name = module.hub.hub_pe_openai_private_dns_zone_name
#         fqdn      = "${module.hub.hub_openai_cognitive_account_name}.openai.azure.com"
#       }
#     }
#     spoke_api_dns_zones = {
#       acr = {
#         zone_id = module.hub.hub_pe_acr_private_dns_zone_id
#         fqdn    = "${module.hub.hub_acr_name}.azurecr.io"
#       }
#       web_app = {
#         zone_id = module.spoke_api.spoke_api_web_app_dns_zone_id
#         fqdn    = "${module.spoke_api.spoke_api_web_app_name}.azurewebsites.net"
#       }
#     }
#   }
# }

