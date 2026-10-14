# ---------------------------------------------------------------------------
# Dummy landing zone
#
# Nothing is created in AWS. This stack generates placeholder values shaped
# like a real landing zone's (account ID, role ARN, VPC and subnet IDs) and
# keeps them in this workspace's state, so they stay the same on every run
# and the onboarding module's handoff works unchanged.
#
# Account IDs start with "0000" so they're easy to recognize as fake.
# ---------------------------------------------------------------------------

resource "random_integer" "account_id" {
  min = 0
  max = 99999999
}

resource "random_id" "vpc" {
  byte_length = 9
}

resource "random_id" "public_subnet" {
  count = var.az_count

  byte_length = 9
}

resource "random_id" "private_subnet" {
  count = var.az_count

  byte_length = 9
}

locals {
  account_id = format("0000%08d", random_integer.account_id.result)

  # Real VPC and subnet IDs are 17 hex characters after the prefix.
  vpc_id             = "vpc-${substr(random_id.vpc.hex, 0, 17)}"
  public_subnet_ids  = [for r in random_id.public_subnet : "subnet-${substr(r.hex, 0, 17)}"]
  private_subnet_ids = [for r in random_id.private_subnet : "subnet-${substr(r.hex, 0, 17)}"]
}
