# Interview

This repo is used for devops interview.

## Prerequisite
* [docker](https://docs.docker.com/engine/installation/mac/#/docker-toolbox)
* [docker-compose](https://docs.docker.com/compose/install/)

## Instructions

**Init your new local environment**

  ```
  ./auto/run-local-env
  ```
  After the initialization process is successful done, you can access your local environment via [joi.local.toc-platform.com](http://joi.local.toc-platform.com) in your browser.

**Provision infrastucture**

  ```
  ./auto/provison-infra-via-terraform {CLOUD_PROVIDER}
  ```
  Use this script to provision infrastructure on the according cloud, create a provider dir and terraform configs in it, terraform will provision it.
  You can also use the extended script like 
  ```
  ./auto/provison-infra-on-alicloud
  ```
  to provision on the specific cloud.


**Provision infrastucture**

  ```
  ./auto/destroy-infra-via-terraform {CLOUD_PROVIDER}
  ```
  Destroy the infrastucture which created by the provision scripts, you can also use the extended script.
