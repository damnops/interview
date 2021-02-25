variable "role_name" {
  description = "the iam role name"
  type        = string
}

variable "path" {
  description = "The path of the policy in IAM"
  type        = string
  default     = "/"
}

variable "description" {
  description = "The description of the policy"
  type        = string
  default     = "IAM Policy"
}

variable "assume_role_policy" {
  description = "the role policy json file"
  type        = list(map(list(string)))
  default     = []
}

variable "policy_name" {
  description = "the new policy name"
  type        = string
  default     = null
}

variable "policy_details" {
  description = "the policy details"
  type        = list(map(list(string)))
  default     = []
}

variable "extra_resource" {
  description = ""
  type        = list(string)
  default     = []
}

variable "permissions_boundary_arn" {
  type    = string
  default = null
}

variable "tags" {
  description = "key common tags"
  type        = map(string)
  default     = {}
}

variable "policy_arn" {
  type    = string
  default = null
}

variable "policy_arn_list" {
  type    = list(string)
  default = []
}