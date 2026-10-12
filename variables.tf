# All of these are set on the workspace by the customer-onboarding module.

variable "company_name" {
  description = "Customer company name."
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, staging, prod)."
  type        = string
}

variable "account_name" {
  description = "Name of the new AWS account."
  type        = string
}

variable "account_email" {
  description = "Root email for the new AWS account. Must be unique across all of AWS."
  type        = string
}

variable "parent_ou_id" {
  description = "AWS Organizations OU (ou-...) or root (r-...) to create the account in."
  type        = string
}

variable "aws_region" {
  description = "Home region for the landing zone."
  type        = string
  default     = "us-east-1"
}

variable "account_access_role_name" {
  description = "Role Organizations creates in the new account for the management account to assume."
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "vpc_cidr" {
  description = "CIDR block for the landing zone VPC. Split into /20s: public subnets from the bottom, private from the middle."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 2 && var.az_count <= 4
    error_message = "az_count must be between 2 and 4."
  }
}

variable "enable_nat_gateway" {
  description = "Create a single NAT gateway so private subnets have outbound internet."
  type        = bool
  default     = true
}

variable "azdo_organization_name" {
  description = "Azure DevOps organization name. Part of the OIDC subject the deploy role trusts."
  type        = string
}

variable "azdo_organization_id" {
  description = "Azure DevOps organization ID (GUID). Part of the OIDC issuer URL."
  type        = string
}

variable "azdo_project_name" {
  description = "Azure DevOps project whose service connection may assume the deploy role."
  type        = string
}

variable "azdo_service_connection_name" {
  description = "Name of the AWS service connection in azdo_project_name that may assume the deploy role."
  type        = string
}

variable "deploy_role_policy_arns" {
  description = "Managed policies attached to the pipeline deploy role."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}
