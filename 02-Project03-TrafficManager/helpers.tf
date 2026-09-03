# Random String Resource
resource "random_string" "default" {
  length  = 6
  special = false
  upper   = false
  numeric = false
}

data "azurerm_resource_group" "rg" {
  name = var.existing_resource_group_name
}

##############################
# Remote State Configuration #
##############################

# Project: East US Datasource
data "terraform_remote_state" "project_eastus" {
  backend = "s3"
  config = {
    bucket = "rdobmk-azure-terraformbackend"
    key    = "azure-architecture/project-03-vmss-eastus.tfstate"
    region = "us-east-1"
  }
}

# Project: West US Datasource
data "terraform_remote_state" "project_westus" {
  backend = "s3"
  config = {
    bucket = "rdobmk-azure-terraformbackend"
    key    = "azure-architecture/project-03-vmss-westus.tfstate"
    region = "us-east-1"
  }
}


