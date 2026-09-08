# Terraform Block
terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
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

  # Terraform State Storage using an AWS S3 Bucket that I control
  backend "s3" {
    bucket       = "rdobmk-azure-terraformbackend"
    key          = "azure-architecture/project-04-application-gateway01.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}