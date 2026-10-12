# Read by the customer-onboarding module (data "tfe_outputs") and copied into
# the Azure DevOps variable group. Keep these non-sensitive.

output "account_id" {
  description = "ID of the customer AWS account."
  value       = aws_organizations_account.this.id
}

output "aws_region" {
  description = "Home region of the landing zone."
  value       = var.aws_region
}

output "deploy_role_arn" {
  description = "Role Azure DevOps pipelines assume via OIDC."
  value       = aws_iam_role.deploy.arn
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider for the Azure DevOps organization."
  value       = aws_iam_openid_connect_provider.azdo.arn
}

output "vpc_id" {
  description = "Landing zone VPC ID."
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
