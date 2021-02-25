locals {
  vpc_id = var.vpc_id != null ? var.vpc_id : element(aws_vpc.this.*.id, 0)

  vpce_tags = merge(
    var.tags,
  )
}

######
# VPC
######
resource "aws_vpc" "this" {
  count = var.create_vpc && var.vpc_id == null ? 1 : 0

  cidr_block                     = var.cidr
  instance_tenancy               = var.instance_tenancy
  enable_dns_hostnames           = var.enable_dns_hostnames
  enable_dns_support             = var.enable_dns_support
  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink_dns_support

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
  )
}

###################
# Internet Gateway
###################
resource "aws_internet_gateway" "this" {
  count = var.create_vpc && length(var.public_subnet_cidr) > 0 && var.internet_gateway_id == null ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format("internet-gateway-%s", count.index)
    },
    var.tags,
  )
}

################
# Public subnet
################
resource "aws_subnet" "public" {
  count = var.create_vpc && length(var.public_subnet_cidr) > 0 ? length(var.public_subnet_cidr) : 0

  vpc_id               = local.vpc_id
  cidr_block           = var.public_subnet_cidr[count.index]
  availability_zone_id = lookup(element(var.azs, count.index), "az")

  tags = merge(
    {
      "Name" = format(
        "sub-public-%s",
        count.index
      )
    },
    var.tags,
  )
}

#################
# Private subnet
#################
resource "aws_subnet" "private" {
  count = var.create_vpc && length(var.private_subnet_cidr) > 0 ? length(var.private_subnet_cidr) : 0

  vpc_id               = local.vpc_id
  cidr_block           = var.private_subnet_cidr[count.index]
  availability_zone_id = lookup(element(var.azs, count.index), "az")

  tags = merge(
    {
      "Name" = format(
        "sub-private-%s",
        count.index
      )
    },
    var.tags,
  )
}

##############
# NAT Gateway
##############
resource "aws_route" "gut_nat_gateway" {
  count = var.create_vpc && var.enable_nat_gateway ? length(var.private_subnet_cidr) : 0

  route_table_id         = element(aws_route_table.private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(var.nat_gateway_ids, count.index)

  timeouts {
    create = "5m"
  }
}

################
# Publiс routes
################
resource "aws_route_table" "public" {
  count = var.create_vpc && length(var.public_subnet_cidr) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    {
      "Name" = format(
        "${var.public_subnet_suffix}-%s",
        count.index
      )
    },
    var.tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = var.create_vpc && length(var.public_subnet_cidr) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = var.internet_gateway_id != null ? var.internet_gateway_id : aws_internet_gateway.this[0].id

  timeouts {
    create = "5m"
  }
}

#################
# Private routes
#################
resource "aws_route_table" "private" {
  count = var.create_vpc && length(var.private_subnet_cidr) > 0 ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
  {
    "Name" = format(
    "${var.private_subnet_suffix}-%s",
    count.index
    )
  },
  var.tags,
  )
}

##########################
# Route table association
##########################
resource "aws_route_table_association" "private" {
  count = var.create_vpc && length(var.private_subnet_cidr) > 0 ? length(var.private_subnet_cidr) : 0

  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = element(aws_route_table.private.*.id, 0)
}

resource "aws_route_table_association" "public" {
  count = var.create_vpc && length(var.public_subnet_cidr) > 0 ? length(var.public_subnet_cidr) : 0

  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public[0].id
}
