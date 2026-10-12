# depends_on defers this read to apply on the first run, so it runs against
# the new account rather than with the not-yet-configured provider.
data "aws_availability_zones" "available" {
  provider = aws.account

  state = "available"

  depends_on = [time_sleep.account_ready]
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "this" {
  provider = aws.account

  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.account_name}-vpc"
  }
}

# Strip the rules from the default security group so nothing lands in it
# with open access by accident.
resource "aws_default_security_group" "this" {
  provider = aws.account

  vpc_id = aws_vpc.this.id
}

resource "aws_internet_gateway" "this" {
  provider = aws.account

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.account_name}-igw"
  }
}

# ---------------------------------------------------------------------------
# Subnets: /20s, public at index 0..n, private at index 8..8+n.
# ---------------------------------------------------------------------------

resource "aws_subnet" "public" {
  provider = aws.account
  count    = var.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index)

  tags = {
    Name = "${var.account_name}-public-${count.index + 1}"
    Tier = "public"
  }
}

resource "aws_subnet" "private" {
  provider = aws.account
  count    = var.az_count

  vpc_id            = aws_vpc.this.id
  availability_zone = local.azs[count.index]
  cidr_block        = cidrsubnet(var.vpc_cidr, 4, count.index + 8)

  tags = {
    Name = "${var.account_name}-private-${count.index + 1}"
    Tier = "private"
  }
}

resource "aws_route_table" "public" {
  provider = aws.account

  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "${var.account_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  provider = aws.account
  count    = var.az_count

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------------------------------------------
# Private egress: one NAT gateway. Use one per AZ for prod-grade resilience.
# ---------------------------------------------------------------------------

resource "aws_eip" "nat" {
  provider = aws.account
  count    = var.enable_nat_gateway ? 1 : 0

  domain = "vpc"

  tags = {
    Name = "${var.account_name}-nat"
  }
}

resource "aws_nat_gateway" "this" {
  provider = aws.account
  count    = var.enable_nat_gateway ? 1 : 0

  allocation_id = aws_eip.nat[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "${var.account_name}-nat"
  }

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route_table" "private" {
  provider = aws.account

  vpc_id = aws_vpc.this.id

  dynamic "route" {
    for_each = aws_nat_gateway.this

    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value.id
    }
  }

  tags = {
    Name = "${var.account_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  provider = aws.account
  count    = var.az_count

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}
