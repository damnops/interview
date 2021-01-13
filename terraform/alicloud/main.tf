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
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDgqFwa0kxsOITam1IGwVOTNbqV+DSRKZBmBzpo/zaJFkm5SuiZoY+uAJD0vSCZ4EbSNcvAiosIHm+DP7+1ajWRpSKieAtxcW5dfFA6SBSWbQSxe0Ldk6ntIzR40gz+/0sV3/Nh14qncoOocEOWGCwlNHmo+VngSmuU3ulpTQvk8dvYFUSDkcb0BgKfrtBTgZNTfP91w2XJqJfto05KmfdQDKzbhxOkQIISEDF6Fqout8gK9/1NlFJ38TfIfjuNLrGVcFV3T1M0REyI8pUBn5NEEIkWMO5Gec3KojqUAWD52+IgOOoBUB4ktj/7Xy3DNCIBx09vTjFaDYhC2sx8Eoc/"
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
  # provisioner "remote-exec" {
  #   connection {
  #     type = "ssh"
  #     user = "root"
  #     host = self.public_ip
  #     timeout = "25m"
  #   }
  #   inline = [
  #     "cloud-init status --wait"
  #   ]
  # }
  # provisioner "file" {
  #   connection {
  #     type = "ssh"
  #     user = "root"
  #     host = self.public_ip
  #   }
  #   source      = "/etc/kubernetes/admin.kubeconfig"
  #   destination = "./kubeconfig"
  # }
}


locals {
  user_data = <<EOF
#!/bin/bash
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
yum install git make vim -y
git clone https://gitee.com/toc-lib/kube-ansible.git /usr/local/src/kube-ansible
pushd /usr/local/src/kube-ansible
cp group_vars/allinone.yml group_vars/all.yml
cp inventory/allinone.template inventory/hosts
make runtime
make install DOWNLOAD_WAY=qiniu | tee /tmp/kube-ansible.log
popd
EOF
}
