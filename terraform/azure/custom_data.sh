#!/bin/bash
sudo -i
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

wget https://github.com/mikefarah/yq/releases/download/v4.4.1/yq_linux_amd64 -O /usr/bin/yq

chmod +x /usr/bin/yq

ssh-keygen -t rsa -P "" -f ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

apt-get update
apt-get install git make python3 python3-pip sshpass curl rsync -y

pip3 install --upgrade pip
pip3 install ansible==2.10.4

git clone https://gitee.com/toc-lib/kube-ansible.git /usr/local/src/kube-ansible
pushd /usr/local/src/kube-ansible
cp group_vars/template.yml group_vars/all.yml

PUBLIC_IP=$(curl -s www.pubyun.com/dyndns/getip)
yq eval --inplace "(.kubernetes.ssl.extension.[0]) = \"$PUBLIC_IP\"" group_vars/all.yml

yq eval --inplace '(.ansible_python_interpreter) = "/usr/bin/python3"' group_vars/all.yml
yq eval --inplace '(.kubernetes.kubelet.pod_infra_container_image) = "k8s.gcr.io/pause:3.2"' group_vars/all.yml
yq eval --inplace '(.kubernetes.settings.master_run_pod) = "true"' group_vars/all.yml

PRIVATE_IP=$(hostname -i)

# init inventory file
echo "[master]" > inventory/hosts
echo "$PRIVATE_IP" >> inventory/hosts
echo "[worker]" >> inventory/hosts
echo "[kubernetes:children]" >> inventory/hosts
echo "master" >> inventory/hosts
echo "worker" >> inventory/hosts

make install DOWNLOAD_WAY=qiniu | tee /tmp/kube-ansible.log
popd
