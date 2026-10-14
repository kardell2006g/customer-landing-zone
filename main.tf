# ---------------------------------------------------------------------------
# Dummy customer account
#
# No AWS account is created. The account ID is generated and kept in this
# workspace's state, so it stays the same on every run. It starts with "0000"
# so it's easy to recognize as fake. The customer's real resources (network,
# deploy role) live in the shared account; see network.tf and iam.tf.
# ---------------------------------------------------------------------------

resource "random_integer" "account_id" {
  min = 0
  max = 99999999
}

data "aws_caller_identity" "current" {}

locals {
  account_id = format("0000%08d", random_integer.account_id.result)
}
