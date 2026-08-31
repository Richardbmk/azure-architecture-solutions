variable "existing_resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
  default     = ""
}

# Generic Input Variables
# Business Division
variable "business_division" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "fin"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}

# Azure Resource Group Name 
variable "resource_group_name" {
  description = "Resource Group Name"
  type        = string
  default     = "rg-default"
}

# Azure Resources Location
variable "resource_group_location" {
  description = "Region in which Azure Resources to be created"
  type        = string
  default     = "eastus2"
}

# Virtual Network, Subnets and Subnet NSG's
## Virtual Network
variable "vnet_name" {
  description = "Virtual Network name"
  type        = string
  default     = "vnet-default"
}
variable "vnet_address_space" {
  description = "Virtual Network address_space"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# Web Subnet Name
variable "web_subnet_name" {
  description = "Virtual Network Web Subnet Name"
  type        = string
  default     = "websubnet"
}

# Web Subnet Address Space
variable "web_subnet_address" {
  description = "Virtual Network Web Subnet Address Spaces"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}


# App Subnet Name
variable "app_subnet_name" {
  description = "Virtual Network App Subnet Name"
  type        = string
  default     = "appsubnet"
}

# App Subnet Address Space
variable "app_subnet_address" {
  description = "Virtual Network App Subnet Address Spaces"
  type        = list(string)
  default     = ["10.0.2.0/24"]
}


# Database Subnet Name
variable "db_subnet_name" {
  description = "Virtual Network Database Subnet Name"
  type        = string
  default     = "dbsubnet"
}
# Database Subnet Address Space
variable "db_subnet_address" {
  description = "Virtual Network Database Subnet Address Spaces"
  type        = list(string)
  default     = ["10.0.3.0/24"]
}


# Bastion / Management Subnet Name
variable "bastion_subnet_name" {
  description = "Virtual Network Bastion Subnet Name"
  type        = string
  default     = "bastionsubnet"
}
# Bastion / Management Subnet Address Space
variable "bastion_subnet_address" {
  description = "Virtual Network Bastion Subnet Address Spaces"
  type        = list(string)
  default     = ["10.0.4.0/24"]
}

# Bastion Linux VM Input Variables Placeholder file.
variable "bastion_service_subnet_name" {
  description = "Bastion Service Subnet Name"
  default     = "AzureBastionSubnet"
}

variable "bastion_service_address_prefixes" {
  description = "Bastion Service Address Prefixes"
  default     = ["10.0.5.0/27"]
}

# Web Linux VM Instance Count
variable "web_linuxvm_instance_count" {
  description = "Web Linux VM Instance Count"
  type        = map(string)
  default = {
    "vm1" = "1022",
    "vm2" = "2022"
  }
}

variable "web_vmss_nsg_inbound_ports" {
  description = "Web VMSS NSG Inbound Ports"
  type        = list(string)
  default     = ["22", "80", "443"]
}







