output "private_key_pem" {
  description = "private key pem"
  value       = tls_private_key.key.*.private_key_pem
  sensitive   = true
}

output "key_name" {
  value = aws_key_pair.this.*.key_name
}
