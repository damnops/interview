# https://github.com/terraform-aws-modules/terraform-aws-security-group
##########################
# Security group with name
##########################
resource "aws_security_group" "this" {
  count = var.create_sg ? 1 : 0

  name        = var.name
  description = var.description
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = format("%s", var.name)
    },
  )
}

###################################
# Ingress - List of rules (simple)
###################################
resource "aws_security_group_rule" "ingress_with_cidr_blocks" {
  count = var.create_sg ? length(var.ingress_with_cidr_blocks) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "ingress"

  cidr_blocks = split(
    ",",
    lookup(
      var.ingress_with_cidr_blocks[count.index],
      "cidr_blocks",
      join(",", var.ingress_cidr_blocks),
    ),
  )
  prefix_list_ids = var.ingress_prefix_list_ids
  description = lookup(
    var.ingress_with_cidr_blocks[count.index],
    "description",
    "Ingress Rule",
  )
  from_port = lookup(
    var.ingress_with_cidr_blocks[count.index],
    "from_port",
  )
  to_port = lookup(
    var.ingress_with_cidr_blocks[count.index],
    "to_port",
  )
  protocol = lookup(
    var.ingress_with_cidr_blocks[count.index],
    "protocol",
  )
}

resource "aws_security_group_rule" "ingress_with_ipv6_cidr_blocks" {
  count = var.create_sg ? length(var.ingress_with_ipv6_cidr_blocks) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "ingress"

  ipv6_cidr_blocks = split(
  ",",
  lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "cidr_blocks",
    join(",", []),
  ),
  )
  prefix_list_ids = var.ingress_prefix_list_ids
  description = lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "description",
    "Ingress Rule",
  )
  from_port = lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "from_port",
  )
  to_port = lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "to_port",
  )
  protocol = lookup(
    var.ingress_with_ipv6_cidr_blocks[count.index],
    "protocol",
  )
}

###################################
# egress - List of rules (simple)
###################################
# Security group rules with "cidr_blocks", but without "ipv6_cidr_blocks", "source_security_group_id" and "self"
resource "aws_security_group_rule" "egress_with_cidr_blocks" {
  count = var.create_sg ? length(var.egress_with_cidr_blocks) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "egress"

  cidr_blocks = split(
    ",",
    lookup(
      var.egress_with_cidr_blocks[count.index],
      "cidr_blocks",
      join(",", var.egress_cidr_blocks),
    ),
  )
  prefix_list_ids = var.egress_prefix_list_ids
  description = lookup(
    var.egress_with_cidr_blocks[count.index],
    "description",
    "Egress Rule",
  )
  from_port = lookup(
    var.egress_with_cidr_blocks[count.index],
    "from_port",
  )
  to_port = lookup(
    var.egress_with_cidr_blocks[count.index],
    "to_port",
  )
  protocol = lookup(
    var.egress_with_cidr_blocks[count.index],
    "protocol",
  )
}

###################################
# egress - List of rules (simple)
###################################
resource "aws_security_group_rule" "egress_with_prefix_blocks" {
  count = var.create_sg ? length(var.egress_with_prefix_blocks) : 0

  security_group_id = aws_security_group.this[0].id
  type              = "egress"

  prefix_list_ids = split(
    ",",
    lookup(
      var.egress_with_prefix_blocks[count.index],
      "prefix_list_ids",
      join(",", []),
    ),
  )
  description = lookup(
    var.egress_with_prefix_blocks[count.index],
    "description",
    "Egress Rule",
  )
  from_port = lookup(
    var.egress_with_prefix_blocks[count.index],
    "from_port",
  )
  to_port = lookup(
    var.egress_with_prefix_blocks[count.index],
    "to_port",
  )
  protocol = lookup(
    var.egress_with_prefix_blocks[count.index],
    "protocol",
  )
}
