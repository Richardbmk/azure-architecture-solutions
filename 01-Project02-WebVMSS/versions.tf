# Terraform Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0"
    }
  }

# # Terraform State Storage to Azure Storage Container
#   backend "azurerm" {
#     resource_group_name   = "kml_rg_main-1883c24aa0fc4ef8"
#     storage_account_name  = "rdobmkterraformstate201"
#     container_name        = "tfstatefiles"
#     key                   = "project-02-eastus2-terraform.tfstate"
#   }

# Terraform State Storage using an AWS S3 Bucket that I control
  backend "s3" {
    bucket       = "rdobmk-azure-terraformbackend"
    key          = "azure-architecture/project-02.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}