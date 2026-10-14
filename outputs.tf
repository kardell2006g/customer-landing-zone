# Read by the customer-onboarding module (data "tfe_outputs") and copied into
# the customer variable set. Keep these non-sensitive. All values are dummies.

output "is_dummy" {
  description = "True: no AWS account or resources exist behind these values."
  value       = true
}

output "account_id" {
  description = "Dummy AWS account ID (starts with 0000)."
  value       = local.account_id
}

output "account_name" {
  description = "Name the AWS account would have."
  value       = var.account_name
}

output "account_email" {
  description = "Root email the AWS account would use."
  value       = var.account_email
}

output "aws_region" {
  description = "Home region of the landing zone."
  value       = var.aws_region
}

output "deploy_role_arn" {
  description = "Dummy deploy role ARN. Nothing can assume it."
  value       = "arn:aws:iam::${local.account_id}:role/tfc-deploy"
}

output "vpc_id" {
  description = "Dummy VPC ID."
  value       = local.vpc_id
}

output "public_subnet_ids" {
  description = "Dummy public subnet IDs, one per AZ."
  value       = local.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Dummy private subnet IDs, one per AZ."
  value       = local.private_subnet_ids
}
