# How to use


```
# create ssh key
ssh-keygen -t rsa -P "" -f ./id_rsa

# reference terraform.tfvars.example create terraform.tfvars

# create vm
terraform apply -auto-approve

# reference output message add host

# check k8s
kubectl --kubeconfig kubeconfig get po -A

# destroy vm
terraform destroy -force
```