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

# Linux VM Outputs

# # Output List - Single Input to for loop
# output "web_linuxvm_private_ip_address_list" {
#   description = "Web Linux Virtual Machine Private IP"
#   #value = azurerm_linux_virtual_machine.web_linuxvm.private_ip_address
#   value = [for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.private_ip_address ]
# }

output "web_linuxvm_private_ip_address_map" {
  description = "Web Linux Virtual Machine Private IP"
  #value = azurerm_linux_virtual_machine.web_linuxvm.private_ip_address
  value = { for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.name => vm.private_ip_address }
}

# output "web_linuxvm_private_ip_address_keys_function" {
#   description = "Web Linux Virtual Machine Private IP"
#   value = keys({for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.name => vm.private_ip_address })
# }

# output "web_linuxvm_private_ip_address_values_function" {
#   description = "Web Linux Virtual Machine Private IP"
#   value = values({for vm in azurerm_linux_virtual_machine.web_linuxvm: vm.name => vm.private_ip_address})
# }

# # Network Interface Outputs
# output "web_linuxvm_network_interface_id_list" {
#   description = "Web Linux VM Network Interface ID"
#   #value = azurerm_network_interface.web_linuxvm_nic.id
#   value = [for vm, nic in azurerm_network_interface.web_linuxvm_nic: nic.id ]
# }

# output "web_linuxvm_network_interface_id_map" {
#   description = "Web Linux VM Network Interface ID"
#   #value = azurerm_network_interface.web_linuxvm_nic.id
#   value = {for vm, nic in azurerm_network_interface.web_linuxvm_nic: vm => nic.id }
# }

## Bastion Host Public IP Output
output "bastion_host_linuxvm_public_ip_address" {
  description = "Bastion Host Linux VM Public Address"
  value = azurerm_public_ip.bastion_host_public_ip.ip_address
}

