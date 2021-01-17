# How to use


```
# create ssh key
ssh-keygen -t rsa -P "" -f ./id_rsa_azure

# create vm
terraform apply -auto-approve

# destroy vm
terraform destroy -force
```
