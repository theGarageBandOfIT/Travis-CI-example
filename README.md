# Travis-CI-example
A small example about how to use Travis-CI

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