terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.40, < 7.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.11"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0"
    }
  }
}

locals {
  common_tags = {
    "Company"           = var.company_name
    "Environment"       = var.environment
    "Terraform Managed" = "true"
  }
}

# Management (Organizations) account. Credentials come from the variable set
# the customer-onboarding module attaches to this workspace.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# The new customer account, reached through the role Organizations creates in
# it. The account ID is routed through time_sleep so the provider is only
# configured once the account exists and the role has had time to propagate.
# On the first plan the ARN is unknown; resources using this provider are
# planned without API calls and the provider is configured for real at apply.
provider "aws" {
  alias  = "account"
  region = var.aws_region

  assume_role {
    role_arn     = "arn:${data.aws_partition.current.partition}:iam::${time_sleep.account_ready.triggers["account_id"]}:role/${var.account_access_role_name}"
    session_name = "terraform-landing-zone"
  }

  default_tags {
    tags = local.common_tags
  }
}
