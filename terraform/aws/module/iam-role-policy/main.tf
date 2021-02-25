data "aws_iam_policy_document" "role" {
  dynamic "statement" {
    for_each = var.assume_role_policy
    content {
      actions = ["sts:AssumeRole"]
      principals {
        type        = join("", statement.value["role_type"])
        identifiers = statement.value["identifiers"]
      }
    }
  }
}

resource "aws_iam_role" "role" {
  name                 = var.role_name
  assume_role_policy   = data.aws_iam_policy_document.role.json
  permissions_boundary = var.permissions_boundary_arn
  description          = var.description
  tags                 = var.tags
}

data "aws_iam_policy_document" "policy" {
  count = length(var.policy_details) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = var.policy_details
    content {
      actions   = statement.value["action"]
      resources = concat(statement.value["resources"], var.extra_resource)
    }
  }
}

resource "aws_iam_policy" "policy" {
  count = length(var.policy_details) > 0 ? 1 : 0

  name        = var.policy_name
  path        = var.path
  description = var.description
  policy      = data.aws_iam_policy_document.policy[0].json
}

# custom-policy or aws-policy attach one policy
resource "aws_iam_role_policy_attachment" "attach" {
  count = var.policy_arn == null && length(var.policy_details) == 0 ? 0 : 1

  role       = aws_iam_role.role.name
  policy_arn = var.policy_arn == null ? aws_iam_policy.policy[0].arn : var.policy_arn
}

# aws-policy list attach
resource "aws_iam_role_policy_attachment" "attach_policies" {
  count = length(var.policy_arn_list) > 0 ? length(var.policy_arn_list) : 0

  role       = aws_iam_role.role.name
  policy_arn = var.policy_arn_list[count.index]
}