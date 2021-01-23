# Interview

This repo is used for devops interview.

## Prerequisite
* [docker](https://docs.docker.com/engine/installation/mac/#/docker-toolbox)
* [docker-compose](https://docs.docker.com/compose/install/)

## Instructions

**Init your new local environment**

  ```
  ./auto/run-local-env
  echo "127.0.0.1  devops.joi.toc-platform.com" >> /etc/hosts
  ```
  After the initialization process is successful done, you can access your local environment via [devops.joi.toc-platform.com](http://devops.joi.toc-platform.com) in your browser.

**Provision infrastructure**

  ```
  ./auto/provison-infra-via-terraform {CLOUD_PROVIDER}
  ```
  Use this script to provision infrastructure on the according cloud, create a provider dir and terraform configs in it, terraform will provision it. 
  You can also use the extended script like 
  ```
  ./auto/provison-infra-on-alicloud
  ```
  to provision on the specific cloud.

  Remember to put your access id & secret key pair in `credentials.auto.tfvars` file, this filename is added in the .gitignore, or else it might be uploaded to remote repo.

**Setup kubectl config for aws k8s**

  After the provision infrastructure step is done, we should have a workable k8s cluster. Aliyun provision step will do this, but for AWS, we need to run the following script to download the kube config file.
  ```
  ./auto/setup-kube-config-for-aws
  ```
  The config file will be set as `config/kube-config.txt`, if there are something wrong with k8s cluster control via kubectl, check this file.

**Build and release docker images**

  Update the docker registry credential in the `config/cr-credential` and run following script, it will push docker images to docker hub.
  ```
  ./auto/auth-with-dockerhub
  ```
  Since it's very slow to pull image from docker hub with China networking, we have an ali docker registry, use `auto/auth-with-ali-cr` to auth.

**Deploy application to k8s**

  ```
  ./auto/deploy-to-k8s
  ```
  This script will generate the k8s relevant files and deploy it. We use [kustomize](https://kustomize.io/) to manage the configs.
  After deployment process is finished, you can access the application via [devops.joi.toc-platform.com:32100](http://devops.joi.toc-platform.com:32100/)

**Destroy infrastructure**

  ```
  ./auto/destroy-infra-via-terraform {CLOUD_PROVIDER}
  ```
  Destroy the infrastructure which created by the provision scripts, you can also use the extended script.
