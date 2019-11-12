# Travis-CI-example

A small example about how to use Travis-CI

## the Application

Demo application is **DockerCoins** forked from <https://github.com/jpetazzo/dockercoins/> (see: [this folder](https://github.com/theGarageBandOfIT/Travis-CI-example/tree/master/docker-compose-original-resources)).

Since it is available as a `Docker Compose` stack, it has been [converted](https://kubernetes.io/docs/tasks/configure-pod-container/translate-compose-kubernetes/) to be deployed into a `kubernetes` _cluster_ thanks to [kompose](http://kompose.io/).  
To do so, simply apply the following command from the folder where the `docker-compose` file is located…

```sh
$ cd docker-compose-original-resources/
.
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

## the Google Compute Kubernetes Cluster

Create a new project (here named `travis-ci-example`).  

Activate `Kubernetes Engine` services.

Create a _service account_ named `travisci` with the following roles:

* Kubernetes Engine Admin
* Service Account User

Generate and save its Key as a `JSON` file. It will look like this…

```JSON
{
  "type": "service_account",
  "project_id": "travis-ci-example-258722",
  "private_key_id": "***",
  "private_key": "-----BEGIN PRIVATE KEY-----***\n-----END PRIVATE KEY-----\n",
  "client_email": "travisci@travis-ci-example-258722.iam.gserviceaccount.com",
  "client_id": "***",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/travisci%40travis-ci-example-258722.iam.gserviceaccount.com"
}
```
