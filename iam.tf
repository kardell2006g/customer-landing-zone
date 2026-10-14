# ---------------------------------------------------------------------------
# Per-customer deploy role in the shared account, for HCP Terraform dynamic
# credentials. Only workspaces in the customer's HCP Terraform project can
# assume it.
#
# An account can have only one OIDC provider per issuer URL, so this looks up
# the existing HCP Terraform provider instead of creating one per customer.
# It exists already if the global variable set uses dynamic credentials.
# ---------------------------------------------------------------------------

locals {
  tfc_audience = "aws.workload.identity"
  tfc_subject  = "organization:${coalesce(var.tfc_organization, "unset")}:project:${coalesce(var.tfc_project_name, "unset")}:workspace:*:run_phase:*"
}

data "aws_iam_openid_connect_provider" "tfc" {
  count = var.create_deploy_role ? 1 : 0

  url = "https://${var.tfc_hostname}"
}

data "aws_iam_policy_document" "deploy_trust" {
  count = var.create_deploy_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [data.aws_iam_openid_connect_provider.tfc[0].arn]
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
  count = var.create_deploy_role ? 1 : 0

  # IAM role names are unique per account, so each customer gets its own.
  name                 = "tfc-deploy-${var.account_name}"
  description          = "Assumed by HCP Terraform workspaces in project ${coalesce(var.tfc_project_name, "unset")} via dynamic credentials."
  assume_role_policy   = data.aws_iam_policy_document.deploy_trust[0].json
  max_session_duration = 3600
}

resource "aws_iam_role_policy_attachment" "deploy" {
  for_each = var.create_deploy_role ? toset(var.deploy_role_policy_arns) : toset([])

  role       = aws_iam_role.deploy[0].name
  policy_arn = each.value
}
