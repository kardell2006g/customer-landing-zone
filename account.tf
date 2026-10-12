data "aws_partition" "current" {}

resource "aws_organizations_account" "this" {
  name      = var.account_name
  email     = var.account_email
  parent_id = var.parent_ou_id
  role_name = var.account_access_role_name

  iam_user_access_to_billing = "DENY"

  # Without this, destroy only removes the account from the org, which fails
  # unless the account has its own payment method. Closed accounts are
  # recoverable for 90 days.
  close_on_deletion = true

  lifecycle {
    # role_name is only used at creation and isn't returned by the API.
    ignore_changes = [role_name]
  }
}

# A brand-new account's access role isn't assumable for a short while.
resource "time_sleep" "account_ready" {
  create_duration = "90s"

  triggers = {
    account_id = aws_organizations_account.this.id
  }
}

# ---------------------------------------------------------------------------
# Account security baseline
# ---------------------------------------------------------------------------

resource "aws_ebs_encryption_by_default" "this" {
  provider = aws.account

  enabled = true
}

resource "aws_s3_account_public_access_block" "this" {
  provider = aws.account

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_account_password_policy" "this" {
  provider = aws.account

  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
  max_password_age               = 90
}

resource "aws_accessanalyzer_analyzer" "this" {
  provider = aws.account

  analyzer_name = "${var.account_name}-account"
  type          = "ACCOUNT"
}
