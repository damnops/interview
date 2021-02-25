# How to use

```
# create vm
terraform init
terraform apply -auto-approve

# reference output message to get host and key

# check k8s
kubectl --kubeconfig kubeconfig get po -A

# destroy vm
terraform destroy -force
```