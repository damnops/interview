# Interview

This repo is used for devops interview.

## Expectation

* The application couldn't start, fix the issue.
* There are many bad practices in this repo, try to make it better.
* Any further improvement in this repo, like infra, HA, etc.

## Prerequisite

* [docker](https://docs.docker.com/desktop/#download-and-install)
* [docker-compose](https://docs.docker.com/compose/install/)

## Instructions

### Init your new local environment

  ```
  ./auto/start-local-env
  ```
  After the initialization process is successful done, you can access your local environment via [127.0.0.1](http://127.0.0.1) in your browser.

### Provision infrastructure

  ```
  ./auto/provison-infra-via-terraform {CLOUD_PROVIDER}
  ```
  Use this script to provision infrastructure on the according cloud, create a provider dir and terraform configs in `terraform` dir, terraform will provision it. 
  You can also use the extended script like 
  ```
  ./auto/provison-infra-on-alicloud
  ```
  to provision on the specific cloud.

  Put your access id & secret key pair in `credentials.auto.tfvars` file, this filename is added in the .gitignore, or else it might be uploaded to remote repo.

### Setup kubectl config for aws k8s

  After the provision infrastructure step is done, we should have a workable k8s cluster. Aliyun provision step will copy the kubectl config to local, but for AWS, we need to run the following script to download the kube config file.
  ```
  ./auto/setup-kube-config-for-aws
  ```
  The config file will be set as `config/kube-config.txt`, if there are something wrong with k8s cluster control via kubectl, check this file.

### Build and release docker images

  Github action will be triggered to build and release the images to alicr and dockerhub once code is pushed into main branch. Please use following URLs to access the images.

  **Dockerhub**
  ```
  App: joidevops/app:{TAG}
  Migration: joidevops/migratino:{TAG}
  ```
  **Ali CR**
  ```
  App: registry.cn-hongkong.aliyuncs.com/joidevops/app:{TAG}
  Migration: registry.cn-hongkong.aliyuncs.com/joidevops/migratino:{TAG}
  ```
  
  If you want to push images to your own docker registry, update the docker registry credential in the `config/cr-credential` and run following script, it will push docker images to docker hub.
  ```
  ./auto/release-docker-images-to-dockerhub
  ```
  Accordingly, use `auto/release-docker-images-to-alicr` to push image to ali cr.

### Deploy application to k8s

  ```
  ./auto/deploy-to-k8s
  ```
  This script will generate the k8s relevant files and deploy it. We use [kustomize](https://kustomize.io/) to manage the configs.
  After deployment process is finished, you can access the application via [PUBLIC_IP:32100](http://PUBLIC_IP:32100/)

### Destroy infrastructure

  ```
  ./auto/destroy-infra-via-terraform {CLOUD_PROVIDER}
  ```
  Destroy the infrastructure which created by the provision scripts, you can also use the extended script.

### Stop and clean local environment

  ```
  ./auto/stop-local-env
  ```
