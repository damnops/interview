#!/bin/bash
sudo yum update -y

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
