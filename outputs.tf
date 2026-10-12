# Read by the customer-onboarding module (data "tfe_outputs") and copied into
# the customer variable set. Keep these non-sensitive.

output "account_id" {
  description = "ID of the customer AWS account."
  value       = aws_organizations_account.this.id
}

output "aws_region" {
  description = "Home region of the landing zone."
  value       = var.aws_region
}

output "deploy_role_arn" {
  description = "Role HCP Terraform workspaces in the customer project assume via dynamic credentials."
  value       = aws_iam_role.deploy.arn
}

output "oidc_provider_arn" {
  description = "IAM OIDC provider for HCP Terraform."
  value       = aws_iam_openid_connect_provider.tfc.arn
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
