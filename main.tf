##############################################
# Terraform Configuration
# - Defines required Terraform version
# - Specifies AWS provider and version constraint
##############################################
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"        # Use AWS provider v5.x
    }
  }
}

##############################################
# AWS Provider
# - Region value comes from variable "region"
# - Actual value provided via terraform.tfvars
##############################################
provider "aws" {
  region = var.region
}
