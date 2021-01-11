#===============================================================================
# Backend
#===============================================================================
# terraform {
#   backend "s3" {
#     region                      = "minio"
#     force_path_style            = true
#     skip_credentials_validation = true
#     skip_metadata_api_check     = true
#     skip_region_validation      = true
#     # skip_requesting_account_id  = true
#     # skip_get_ec2_platforms      = true
#   }
# }


#===============================================================================
# Provider
#===============================================================================
provider "alicloud" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}


#===============================================================================
# Data
#===============================================================================
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

data "alicloud_images" "images" {
  most_recent = true
  name_regex  = "^centos_7_*"
}


#===============================================================================
# Resources
#===============================================================================
resource "alicloud_security_group" "sg" {
  name        = var.project_name
  description = var.project_name
  vpc_id      = alicloud_vpc.vpc.id
}

resource "alicloud_vswitch" "vswitch" {
  name              = var.project_name
  cidr_block        = "172.16.1.0/24"
  availability_zone = data.alicloud_zones.default.zones[0].id
  vpc_id            = alicloud_vpc.vpc.id
}

resource "alicloud_vpc" "vpc" {
  name       = var.project_name
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_security_group_rule" "allow_all_tcp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "1/65535"
  priority          = 1
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_key_pair" "publickey" {
  key_name   = var.project_name
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDWiHmBfiZYcCSAGDkdcWwmduk2ZqptkRQEZEJ0YKla+orjh+0NElsJ0WBMAszc/WevDtyST90NiwhEYPYxyUCAZU+h6TXbaOoVVe8eGwBpEC3X6INFUUR7kVKK5K0mfOm3LalfJASLhSmKhyBGCZJ93bSfg8K0ky0qHIy9igbNLm9PcP6v58MD5wXf2W3bI+5kcj1mjuS8znjtznvwH6z43PfSwyZHpR66Ds/u+PyGiPOXnZIMvEDe3w+Ui/2anIqaN3f+iMbpmiJdzyvCBhMZzd+DKine+erBojAtHOw15yx/8q6v5lkGIYtJvbyTwcl7E85CefcJM6iY73BZQL/N root@MoMo"
}


resource "alicloud_instance" "instance" {
  availability_zone          = "cn-beijing-a"
  security_groups            = alicloud_security_group.sg.*.id
  instance_type              = "ecs.n4.large"
  system_disk_category       = "cloud_efficiency"
  system_disk_name           = "test_foo_system_disk_name"
  system_disk_description    = "test_foo_system_disk_description"
  image_id                   = data.alicloud_images.images.ids.0
  instance_name              = var.project_name
  vswitch_id                 = alicloud_vswitch.vswitch.id
  internet_max_bandwidth_out = 100
  key_name                   = alicloud_key_pair.publickey.id
  user_data                  = local.user_data
  private_ip                 = "172.16.1.2"
}


locals {
  user_data = <<EOF
#!/bin/bash
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
yum install git make vim -y
git clone https://gitee.com/buxiaomo/kube-ansible.git /usr/local/src/kube-ansible
pushd /usr/local/src/kube-ansible
cp group_vars/allinone.yml group_vars/all.yml
cp inventory/allinone.template inventory/hosts
make runtime
make install DOWNLOAD_WAY=qiniu | tee /tmp/kube-ansible.log
popd
EOF
}