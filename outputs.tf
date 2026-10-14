# Read by the customer-onboarding module (data "tfe_outputs") and copied into
# the customer variable set. Keep these non-sensitive.

# --- Dummy customer account ------------------------------------------------

output "is_dummy" {
  description = "True: the customer AWS account (account_id/name/email) doesn't exist. Network and role are real, in the shared account."
  value       = true
}

output "account_id" {
  description = "Dummy customer AWS account ID (starts with 0000)."
  value       = local.account_id
}

output "account_name" {
  description = "Customer account name. Also the prefix of every real resource name."
  value       = var.account_name
}

output "account_email" {
  description = "Root email the customer account would use."
  value       = var.account_email
}

# --- Real resources in the shared account ------------------------------------

output "deployment_account_id" {
  description = "Real AWS account the network and deploy role were built in (from the global variable set's credentials)."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "Region of the customer network."
  value       = var.aws_region
}

output "deploy_role_arn" {
  description = "Deploy role for HCP Terraform dynamic credentials, or null when create_deploy_role is false."
  value       = one(aws_iam_role.deploy[*].arn)
}

output "vpc_id" {
  description = "Customer VPC ID."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "Public subnet IDs, one per AZ."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "Private subnet IDs, one per AZ."
  value       = aws_subnet.private[*].id
}
