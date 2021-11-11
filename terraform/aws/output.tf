output "ec2_public_ip" {
  value = module.interview-ec2.public_ip
}

output "friendly_dns" {
  value = aws_route53_record.interview.name
}
