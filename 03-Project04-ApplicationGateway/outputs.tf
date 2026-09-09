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

output "web_ag_id" {
  description = "Azure Application Gateway ID"
  value       = azurerm_application_gateway.web_ag.id
}

output "web_ag_public_ip_1" {
  description = "Azure Application Gateway Public IP 1"
  value       = azurerm_public_ip.web_ag_publicip.ip_address
}

output "app1_web_vmss_id" {
  description = "App1 Web Virtual Machine Scale Set ID"
  value       = azurerm_linux_virtual_machine_scale_set.app1_web_vmss.id
}

output "app2_web_vmss_id" {
  description = "App2 Web Virtual Machine Scale Set ID"
  value       = azurerm_linux_virtual_machine_scale_set.app2_web_vmss.id
}

# FQDN 
output "fqdn_public_dns_1" {
  description = "FQDN Public DNS 1"
  value       = azurerm_dns_a_record.dns_record_app1.fqdn
}

output "fqdn_public_dns_2" {
  description = "FQDN Public DNS 2"
  value       = azurerm_dns_a_record.dns_record_app2.fqdn
}