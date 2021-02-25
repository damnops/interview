variable "key_pair_names" {
  description = "Name of the key pair"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "key common tags"
  default     = {}
  type        = map(string)
}