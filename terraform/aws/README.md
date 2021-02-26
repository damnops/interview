# How to use

```
# before create
change backend.tf s3 bucket
Ip is only allowd from tw, you can add your ip at main locals

# create vm
terraform init
terraform apply -auto-approve


# reference output message to get host and key

# check k8s
kubectl --kubeconfig kubeconfig get po -A

# destroy vm
terraform destroy -force
```