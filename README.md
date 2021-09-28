# Kubernetes the Hard Way on Azure
This repo contains the resources necessary to build and follow along with the well known tutorial/lab series [Kubernetes The Hard Way](https://github.com/kelseyhightower/kubernetes-the-hard-way) while using Azure as the hosting cloud provider.

## What's included
This repo has a terrform definition that will provision all of the baseline infrastructure need to complete the tutorial. It also includes a decontainer definition that has all of the prerequisite tools you will need to build and configure your K8s cluster.

## How to use
* Launch a codespace from this repository
  * or you can use a local devcontainer from visual studio
* Run [deploy.sh](infrastructure/deploy.sh) to create the baseline infrastructure
* Start from "[04 - Provisioning a CA and Generating TLS Certificates](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/04-certificate-authority.md)"