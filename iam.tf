# ---------------------------------------------------------------------------
# Workspace access: HCP Terraform dynamic provider credentials (OIDC).
# Any workspace in the customer's HCP Terraform project can assume the deploy
# role for plan and apply. No long-lived keys.
# ---------------------------------------------------------------------------

locals {
  tfc_audience = "aws.workload.identity"
  tfc_subject  = "organization:${var.tfc_organization}:project:${var.tfc_project_name}:workspace:*:run_phase:*"
}

data "tls_certificate" "tfc" {
  url = "https://${var.tfc_hostname}"
}

resource "aws_iam_openid_connect_provider" "tfc" {
  provider = aws.account

  url             = "https://${var.tfc_hostname}"
  client_id_list  = [local.tfc_audience]
  thumbprint_list = [data.tls_certificate.tfc.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "deploy_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.tfc.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.tfc_hostname}:aud"
      values   = [local.tfc_audience]
    }

    condition {
      test     = "StringLike"
      variable = "${var.tfc_hostname}:sub"
      values   = [local.tfc_subject]
    }
  }
}

resource "aws_iam_role" "deploy" {
  provider = aws.account

  name                 = "tfc-deploy"
  description          = "Assumed by HCP Terraform workspaces in project ${var.tfc_project_name} via dynamic credentials."
  assume_role_policy   = data.aws_iam_policy_document.deploy_trust.json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "deploy" {
  provider = aws.account
  for_each = toset(var.deploy_role_policy_arns)

  role       = aws_iam_role.deploy.name
  policy_arn = each.value
}
