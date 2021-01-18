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
  public_key = file("${path.module}/tmp/id_rsa.pub")
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

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "root"
      host        = self.public_ip
      timeout     = "15m"
      private_key = file("${path.module}/tmp/id_rsa")
    }
    inline = [
      "time cloud-init status -w -l",
      "cp /etc/kubernetes/admin.kubeconfig /tmp/admin.kubeconfig",
      "sed -i \"s/172.16.1.2/${self.public_ip}/g\" /tmp/admin.kubeconfig"
    ]
  }
  provisioner "local-exec" {
    command = "scp -i ./tmp/id_rsa -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@${self.public_ip}:/tmp/admin.kubeconfig ./tmp/kube-config.txt"
  }
}


locals {
  user_data = <<EOF
#!/bin/bash
wget http://artifact.splunk.org.cn/yq/releases/download/v4.3.2/yq_linux_amd64 -O /usr/bin/yq
chmod +x /usr/bin/yq
ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
yum install git make vim -y
git clone https://gitee.com/toc-lib/kube-ansible.git /usr/local/src/kube-ansible
pushd /usr/local/src/kube-ansible
cp group_vars/template.yml group_vars/all.yml
IP=$(curl -s www.pubyun.com/dyndns/getip)
yq eval --inplace "(.kubernetes.ssl.extension.[0]) = \"$IP\"" group_vars/all.yml
yq eval --inplace '(.kubernetes.addon.image.metrics) = "registry.cn-beijing.aliyuncs.com/kubernetes_mirror_2021/metrics-server-amd64:v0.3.6"' group_vars/all.yml
yq eval --inplace '(.kubernetes.addon.image.flannel) = "registry.cn-beijing.aliyuncs.com/kubernetes_mirror_2021/flannel:v0.12.0"' group_vars/all.yml
yq eval --inplace '(.kubernetes.addon.image.canal.flannel) = "registry.cn-beijing.aliyuncs.com/kubernetes_mirror_2021/flannel:v0.12.0"' group_vars/all.yml
yq eval --inplace '(.kubernetes.settings.master_run_pod) = "true"' group_vars/all.yml
cp inventory/allinone.template inventory/hosts
make runtime
make install DOWNLOAD_WAY=qiniu | tee /tmp/kube-ansible.log
popd
EOF
}

#===============================================================================
# Output
#===============================================================================
output "public_ip" {
  value = alicloud_instance.instance.public_ip
}
