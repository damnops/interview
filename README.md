# Interview

This repo is used for devops interview.

## Expectations

* There are many bad practices in this repo, try to make it better.
* Any further improvement in this repo, like infra, HA, etc.

## Prerequisite

* [docker](https://docs.docker.com/desktop/#download-and-install)
* [docker-compose](https://docs.docker.com/compose/install/)

## Instruction

### Start local environment

  ```
  ./auto/start-local-env
  ```
  After the initialization process is successful done, you can access your local environment via [127.0.0.1](http://127.0.0.1) in your browser.


### Stop and clean local environment

  ```
  ./auto/stop-local-env
  ```

### Build and release docker images

  Github action will be triggered to build and release the images to dockerhub once code is pushed into main branch or any branch start with `joi-`. Please use following URLs to access the images.

  **Dockerhub**
  ```
  App: joidevops/app:{TAG}
  Migration: joidevops/migratino:{TAG}
  ```
  
  If you want to push images to your own docker registry, update the docker registry credential in the `config/cr-credential` and set the right repo path for each image, then run the following script, it will push docker images to your docker hub.
  ```
  ./auto/release-docker-images-to-dockerhub
  ```

###  Setup interviewee name

  Put the interviewee name in the file `interviewee_name` under the repo root, it will use `date +%s` output if the file is not found. This name will be used part of the domain, so please make it following a valid domain name pattern. The final domain will look like `{INTERVIEWEE_NAME}.devops.joi.toc-platform.com`.


### Provision infrastructure

  [Set AWS environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html#envvars-set) and run following script to provision infrastructure on AWS.
  ```
  ./auto/provison-infra-on-aws
  ```

### Setup kubectl config for k8s

  After the infrastructure provision is done, we should have a workable k8s cluster.
  
  Use `./auto/get-kubeconfig-for-interview` to retrive the kubectl config to `config/kube-config.txt` from remote. Kubectl in scripts has been already set with this config file to work. Use following command for your local kubectl.
  ```
  export KUBECONFIG=${PWD}/config/kube-config.txt
  ```

  Check the above files if there are something wrong.

### Deploy application to k8s

  ```
  ./auto/deploy-app-to-k8s
  ```
  This script will generate the k8s relevant files and deploy it. We use [kustomize](https://kustomize.io/) to manage the configs.
  After deployment process is finished, you can access the application via `http://{INTERVIEWEE_NAME}.devops.joi.toc-platform.com:32100`

### Destroy infrastructure

  ```
  ./auto/destroy-infra-on-aws
  ```
  Destroy the resources which created by the provision scripts.
