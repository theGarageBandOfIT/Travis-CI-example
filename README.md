# Travis-CI-example
A small example about how to use Travis-CI

- [Travis-CI-example](#travis-ci-example)
  - [the Application](#the-application)
  - [Integration to Travis-CI](#integration-to-travis-ci)
    - [Using a runner with a docker container including all the tools](#using-a-runner-with-a-docker-container-including-all-the-tools)

## the Application

Demo application is **DockerCoins** forked from https://github.com/jpetazzo/dockercoins/ (see: [this folder](https://github.com/theGarageBandOfIT/Travis-CI-example/tree/master/docker-compose%20original%20resources)).

Since it is available as a `Docker Compose` stack, it has been [converted](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/) to be deployed into a `kubernetes` _cluster_ thanks to [kompose](http://kompose.io/).  
To do so, simply apply the following command from the folder where the `docker-compose` file is located…

```sh
$ cd docker-compose\ original\ resources/
$ kompose convert
WARN Volume mount on the host "./webui/files/" isn t supported - ignoring path on the host 
INFO Kubernetes file "hasher-service.yaml" created 
INFO Kubernetes file "rng-service.yaml" created   
INFO Kubernetes file "webui-service.yaml" created 
INFO Kubernetes file "hasher-deployment.yaml" created 
INFO Kubernetes file "redis-deployment.yaml" created 
INFO Kubernetes file "rng-deployment.yaml" created 
INFO Kubernetes file "webui-deployment.yaml" created 
INFO Kubernetes file "webui-claim0-persistentvolumeclaim.yaml" created 
INFO Kubernetes file "worker-deployment.yaml" created 
```
(see [commit #30f25ef](https://github.com/theGarageBandOfIT/Travis-CI-example/commit/30f25efd05d3b354976bfaa9a18b08b97de503b6)).  

Small modifications are made to pull `Docker` images from the following **Docker Hub** organization: [lpiot](https://hub.docker.com/u/lpiot) (see [commit #cf44588](https://github.com/theGarageBandOfIT/Travis-CI-example/commit/cf4458832e16ac917820199669d23b4b765aebf7)).  
Service port configuration has also to be fix to make auto-discovery works fine in k8s (see [commit #7079500](https://github.com/theGarageBandOfIT/Travis-CI-example/commit/7079500f418608f24b5e06ef32cf17fb038da360)).

## Integration to Travis-CI

We build a `.travis.yml` file that will automate our _CI/CD pipeline_.  

What we have to do:

1. connect to the `GCP` platform, thanks to `gcloud` _CLI_ tool
2. authenticate with the right `JSON` key file (in the folder named `secret`)
3. retrieve the right `Kubernetes` credentials so that the `kubectl` _CLI_ tool is able to manipulate the `Kubernetes` _cluster_.

### Using a runner with a docker container including all the tools

To do so, we will use:

* a generic _Linux_ _runner_ on `Travis-CI` platform
* and a `Docker` _container_ that already has the right tools (`gcloud` and `kubectl`)
    * this `Docker` container is built from this source: <https://github.com/theGarageBandOfIT/infra-as-code-tools>
    * … and published in the `Docker Hub`: <https://hub.docker.com/r/thegaragebandofit/infra-as-code-tools/tags>
    * … by the way, the `Docker Hub` offers its own _CI/CD pipeline_ that integrates to `Github`.

> :bulb: Using a `Docker` container makes it easy to debug your `Travis-CI` _pipeline_ since you can run the same container on your laptop.
