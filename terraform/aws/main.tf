locals {
  tags = {
    project = "kube"
  }
}


module "vpc" {
  source = "./module/vpc"

  name                 = "kube-vpc"
  cidr                 = "10.195.144.0/25"
  public_subnet_cidr   = ["10.195.144.0/27", "10.195.144.32/27"]
  private_subnet_cidr  = ["10.195.144.64/27", "10.195.144.96/27"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}


module "ec2-sg" {
  source = "./module/security-group"

  name   = "kube-ec2-sg"
  vpc_id = module.vpc.vpc_id

  ingress_with_cidr_blocks = [{
    description = "allow ssh in",
    from_port   = 22,
    to_port     = 22,
    protocol    = "tcp",
    cidr_blocks = var.customize_ip
  },
  {
    description = "allow ssh in",
    from_port   = 6443,
    to_port     = 6443,
    protocol    = "tcp",
    cidr_blocks = "0.0.0.0/0"
  }
  ]

  egress_with_cidr_blocks = [{
    from_port   = 0,
    to_port     = 0,
    protocol    = "-1",
    cidr_blocks = "0.0.0.0/0"
  }]

  tags = local.tags
}

module "ec2-user-role" {
  source = "./module/iam-role-policy"

  role_name   = "ec2-user-role"
  policy_name = "ec2-user-policy"

  assume_role_policy = [{
    role_type   = ["Service"]
    identifiers = ["ec2.amazonaws.com"]
  }]

  policy_details = [{
    action    = ["*"],
    resources = ["*"]
    }
  ]

  tags = local.tags
}

resource "aws_key_pair" "this" {
  key_name   = "kube-ec2-key"
  public_key = file("${path.module}/tmp/id_rsa.pub")
}

module "kube-ec2" {
  source = "./module/ec2"

  name                        = "kube-ec2"
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = module.ec2-sg.security_group_id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/ec2-init.sh")
  ami_id                      = "ami-0ae3e6717dc99c62b"
  instance_type               = "t2.medium"
  key_name                    = aws_key_pair.this.key_name

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 120
      encrypted   = false
    }
  ]

  ebs_block_device = [
    {
      device_name               = "/dev/sdf"
      volume_type               = "gp2"
      volume_size               = 50
      encrypted                 = false
      ebs_delete_on_termination = true
    }
  ]

  tags        = local.tags
  volume_tags = local.tags
}