# All of these are set on the workspace by the customer-onboarding module.
# Some only describe the account that would be created; the dummy landing
# zone accepts them so the module's interface doesn't change.

variable "company_name" {
  description = "Customer company name."
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, staging, prod)."
  type        = string
}

variable "account_name" {
  description = "Name of the (dummy) AWS account."
  type        = string
}

variable "account_email" {
  description = "Root email the (dummy) AWS account would use."
  type        = string
}

variable "parent_ou_id" {
  description = "AWS Organizations OU the account would be created in. Unused by the dummy landing zone."
  type        = string
  default     = null
}

variable "aws_region" {
  description = "Home region reported for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR reported for the landing zone VPC. Unused by the dummy landing zone."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of dummy public and private subnet IDs to generate."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 4
    error_message = "az_count must be between 1 and 4."
  }
}

variable "tfc_hostname" {
  description = "HCP Terraform hostname. Unused by the dummy landing zone."
  type        = string
  default     = "app.terraform.io"
}

variable "tfc_organization" {
  description = "HCP Terraform organization. Unused by the dummy landing zone."
  type        = string
  default     = null
}

variable "tfc_project_name" {
  description = "HCP Terraform project of the customer. Unused by the dummy landing zone."
  type        = string
  default     = null
}
