output "role_arn" {
  description = "The ARN assigned by AWS to this role"
  value       = aws_iam_role.role.arn
}

output "role_id" {
  description = "The id assigned by AWS to this role"
  value       = aws_iam_role.role.id
}

output "role_name" {
  description = "The name of the role"
  value       = aws_iam_role.role.name
}

output "policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = concat(aws_iam_policy.policy.*.arn, [""])[0]
}

output "policy_id" {
  description = "The id assigned by AWS to this policy"
  value       = concat(aws_iam_policy.policy.*.id, [""])[0]
}

output "policy_name" {
  description = "The name of the policy"
  value       = concat(aws_iam_policy.policy.*.name, [""])[0]
}