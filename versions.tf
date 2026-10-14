terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40, < 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

locals {
  # Links every resource back to its customer, dummy account and workspace.
  common_tags = merge(
    {
      "Company"           = var.company_name
      "Environment"       = var.environment
      "Customer Account"  = var.account_name
      "Terraform Managed" = "true"
    },
    var.TFC_WORKSPACE_SLUG != "" ? { "TFC Workspace" = var.TFC_WORKSPACE_SLUG } : {},
  )
}

# The customer AWS account is a dummy (see main.tf). Real resources go into
# the shared account whose credentials come from the global variable set
# (dynamic credentials or access keys). No account is created.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}
