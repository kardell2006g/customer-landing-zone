# ---------------------------------------------------------------------------
# Pipeline access: Azure DevOps workload identity federation (OIDC).
# A service connection named var.azdo_service_connection_name in
# var.azdo_project_name can assume the deploy role. No long-lived keys.
# ---------------------------------------------------------------------------

locals {
  azdo_issuer_host = "vstoken.dev.azure.com/${var.azdo_organization_id}"
  azdo_audience    = "api://AzureADTokenExchange"
  azdo_subject     = "sc://${var.azdo_organization_name}/${var.azdo_project_name}/${var.azdo_service_connection_name}"
}

data "tls_certificate" "azdo" {
  url = "https://vstoken.dev.azure.com"
}

resource "aws_iam_openid_connect_provider" "azdo" {
  provider = aws.account

  url             = "https://${local.azdo_issuer_host}"
  client_id_list  = [local.azdo_audience]
  thumbprint_list = [data.tls_certificate.azdo.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "deploy_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.azdo.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.azdo_issuer_host}:aud"
      values   = [local.azdo_audience]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.azdo_issuer_host}:sub"
      values   = [local.azdo_subject]
    }
  }
}

resource "aws_iam_role" "deploy" {
  provider = aws.account

  name                 = "azdo-deploy"
  description          = "Assumed by Azure DevOps pipelines in ${var.azdo_project_name} via OIDC."
  assume_role_policy   = data.aws_iam_policy_document.deploy_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "deploy" {
  provider = aws.account
  for_each = toset(var.deploy_role_policy_arns)

  role       = aws_iam_role.deploy.name
  policy_arn = each.value
}
