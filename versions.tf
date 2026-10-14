terraform {
  required_version = ">= 1.5.0"

  # Dummy landing zone: no AWS provider, so no AWS credentials are needed and
  # nothing is created in AWS.
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}
