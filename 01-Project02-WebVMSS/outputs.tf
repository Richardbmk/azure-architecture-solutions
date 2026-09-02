# # Virtual Network Outputs
## Virtual Network Name
# output "virtual_network_name" {
#   description = "Virtual Network Name"
#   value       = azurerm_virtual_network.vnet.name
# }

# ## Virtual Network ID
# output "virtual_network_id" {
#   description = "Virtual Network ID"
#   value       = azurerm_virtual_network.vnet.id
# }

# # Subnet Outputs 
# ## Subnet Name 
# output "web_subnet_name" {
#   description = "WebTier Subnet Name"
#   value       = azurerm_subnet.websubnet.name
# }

# ## Subnet ID 
# output "web_subnet_id" {
#   description = "WebTier Subnet ID"
#   value       = azurerm_subnet.websubnet.id
# }

# # Network Security Outputs
# ## Web Subnet NSG Name 
# output "web_subnet_nsg_name" {
#   description = "WebTier Subnet NSG Name"
#   value       = azurerm_network_security_group.web_subnet_nsg.name
# }

# ## Web Subnet NSG ID 
# output "web_subnet_nsg_id" {
#   description = "WebTier Subnet NSG ID"
#   value       = azurerm_network_security_group.web_subnet_nsg.id
# }

# LB Public IP
output "web_lb_public_ip_address" {
  description = "Web Load Balancer Public Address"
  value       = azurerm_public_ip.web_lbpublicip.ip_address
}

# # Load Balancer ID
# output "web_lb_id" {
#   description = "Web Load Balancer ID."
#   value       = azurerm_lb.web_lb.id
# }

# # Load Balancer Frontend IP Configuration Block
# output "web_lb_frontend_ip_configuration" {
#   description = "Web LB frontend_ip_configuration Block"
#   value       = [azurerm_lb.web_lb.frontend_ip_configuration]
# }

## Bastion Host Public IP Output
output "bastion_host_linuxvm_public_ip_address" {
  description = "Bastion Host Linux VM Public Address"
  value       = azurerm_public_ip.bastion_host_public_ip.ip_address
}


# VM Scale Set Outputs

output "web_vmss_id" {
  description = "Web Virtual Machine Scale Set ID"
  value       = azurerm_linux_virtual_machine_scale_set.web_vmss.id
}

# Storage Account Outputs
output "storage_account_primary_access_key" {
  value     = azurerm_storage_account.storage_account.primary_access_key
  sensitive = true
}
output "storage_account_primary_web_endpoint" {
  value = azurerm_storage_account.storage_account.primary_web_endpoint
}
output "storage_account_primary_web_host" {
  value = azurerm_storage_account.storage_account.primary_web_host
}
output "storage_account_name" {
  value = azurerm_storage_account.storage_account.name
}

# NAT Gateway ID
output "nat_gw_id" {
  description = "Azure NAT Gateway ID"
  value       = azurerm_nat_gateway.web_natgw.id
}

# NAT Gateway Public IP
output "nat_gw_public_ip" {
  description = "Azure NAT Gateway Public IP Address"
  value       = azurerm_public_ip.web_natgw_publicip.ip_address
}

output "app_vmss_id" {
  description = "App Virtual Machine Scale Set ID"
  value       = azurerm_linux_virtual_machine_scale_set.app_vmss.id
}

# LB Private IP Address List
output "app_lb_private_ip_addresses" {
  description = "Load Balancer Public Address"
  value       = [azurerm_lb.app_lb.private_ip_addresses]
}

# Load Balancer ID
# output "app_lb_id" {
#   description = "The Internal Load Balancer ID."
#   value       = azurerm_lb.app_lb.id
# }

# Load Balancer Frontend IP Configuration Block
# output "app_lb_frontend_ip_configuration" {
#   description = "LB frontend_ip_configuration Block"
#   value       = [azurerm_lb.app_lb.frontend_ip_configuration]
# }

# FQDN Outputs
output "fqdn_app_lb" {
  description = "App LB FQDN"
  value       = azurerm_private_dns_a_record.app_lb_dns_record.fqdn
}

output "azure_dns_name_servers" {
  value = azurerm_dns_zone.public_dns_zone.name_servers
}

# DNS Zone Datasource Outputs
output "dns_zone_id" {
  value = azurerm_dns_zone.public_dns_zone.id
}
output "dns_zone_name" {
  value = azurerm_dns_zone.public_dns_zone.name
}


# FQDN 
output "fqdn_public_dns_1" {
  description = "FQDN Public DNS 1"
  value = azurerm_dns_a_record.dns_record.fqdn
}

output "fqdn_public_dns_2" {
  description = "FQDN Public DNS 2"
  value = azurerm_dns_a_record.dns_record_www.fqdn
}

output "fqdn_public_dns_3" {
  description = "FQDN Public DNS 3"
  value = azurerm_dns_a_record.dns_record_app1.fqdn
}