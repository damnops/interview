output "public_ip" {
  value = module.kube-ec2.public_ip
}

output "public_dns" {
  value = module.kube-ec2.public_dns
}