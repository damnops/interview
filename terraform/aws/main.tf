locals {
  tags = {
    project = "interview"
  }
}


module "vpc" {
  source = "./module/vpc"

  name                 = "interview-vpc-${var.interviewee_name}"
  cidr                 = "10.195.144.0/25"
  public_subnet_cidr   = ["10.195.144.0/27", "10.195.144.32/27"]
  private_subnet_cidr  = ["10.195.144.64/27", "10.195.144.96/27"]
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.tags
}


module "ec2-sg" {
  source = "./module/security-group"

  name   = "interview-ec2-sg-${var.interviewee_name}"
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
  },
  {
    description = "allow ssh in",
    from_port   = 30000,
    to_port     = 32767,
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

  role_name   = "ec2-user-role-${var.interviewee_name}"
  policy_name = "ec2-user-policy-${var.interviewee_name}"

  assume_role_policy = [{
    role_type   = ["Service"]
    identifiers = ["ec2.amazonaws.com"]
  }]

  policy_details = [{
    action    = ["route53:*"],
    resources = ["*"]
    }
  ]

  tags = local.tags
}

resource "aws_key_pair" "this" {
  key_name   = "interview-ec2-key-${var.interviewee_name}"
  public_key = file("${path.module}/tmp/id_rsa.pub")
}

module "interview-ec2" {
  source = "./module/ec2"

  name                        = "interview-ec2-${var.interviewee_name}"
  subnet_ids                  = module.vpc.public_subnets
  vpc_security_group_ids      = module.ec2-sg.security_group_id
  associate_public_ip_address = true
  user_data                   = file("${path.module}/ec2-init.sh")
  ami_id                      = "ami-018c1c51c7a13e363"
  instance_type               = "t3a.medium"
  iam_instance_profile        = module.ec2-user-role.instance_profile_name
  key_name                    = aws_key_pair.this.key_name

  root_block_device = [
    {
      volume_type = "gp2"
      volume_size = 50
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

data "aws_route53_zone" "toc" {
  name           = "toc-platform.com."
}

resource "aws_route53_record" "interview" {
  zone_id = data.aws_route53_zone.toc.zone_id
  name    = "${var.interviewee_name}.devops.joi.toc-platform.com"
  type    = "A"
  ttl     = "300"
  records = module.interview-ec2.public_ip
  depends_on = [
    module.interview-ec2.public_ip
  ]
}
