# Set on the workspace by the customer-onboarding module.

variable "company_name" {
  description = "Customer company name."
  type        = string
}

variable "environment" {
  description = "Environment (dev, test, staging, prod)."
  type        = string
}

variable "account_name" {
  description = "Customer account name (dummy account). Prefix of every resource name."
  type        = string
}

variable "account_email" {
  description = "Root email the (dummy) AWS account would use."
  type        = string
}

variable "aws_region" {
  description = "Region to build the customer network in."
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the customer VPC. Split into /20s: public subnets from the bottom, private from the middle. Overlapping CIDRs across customers are allowed but block peering between them."
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Number of availability zones to spread subnets across."
  type        = number
  default     = 2

  validation {
    condition     = var.az_count >= 1 && var.az_count <= 4
    error_message = "az_count must be between 1 and 4."
  }
}

variable "tfc_hostname" {
  description = "HCP Terraform hostname. The OIDC issuer the deploy role trusts."
  type        = string
  default     = "app.terraform.io"
}

variable "tfc_organization" {
  description = "HCP Terraform organization. Part of the OIDC subject the deploy role trusts."
  type        = string
  default     = null
}

variable "tfc_project_name" {
  description = "HCP Terraform project whose workspaces may assume the deploy role."
  type        = string
  default     = null
}

variable "enable_nat_gateway" {
  description = "Create a NAT gateway (about $32/month plus data) so private subnets have outbound internet."
  type        = bool
  default     = false
}

variable "create_deploy_role" {
  description = "Create a per-customer IAM role for HCP Terraform dynamic credentials. Needs an existing IAM OIDC provider for tfc_hostname in the shared account."
  type        = bool
  default     = true
}

variable "deploy_role_policy_arns" {
  description = "Managed policies attached to the deploy role."
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/PowerUserAccess"]
}

# Injected by HCP Terraform into every run ("<organization>/<workspace>").
variable "TFC_WORKSPACE_SLUG" {
  description = "Set automatically by HCP Terraform. Leave empty."
  type        = string
  default     = ""
}
