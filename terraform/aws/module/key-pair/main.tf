resource "tls_private_key" "key" {
  count     = length(var.key_pair_names)
  algorithm = "RSA"
}

resource "aws_key_pair" "this" {
  count = length(var.key_pair_names)

  key_name   = var.key_pair_names[count.index]
  public_key = tls_private_key.key[count.index].public_key_openssh

  tags = merge(var.tags, {
    Name = var.key_pair_names[count.index]
  })
}
