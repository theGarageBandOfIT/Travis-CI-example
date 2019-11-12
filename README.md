# Travis-CI-example

![Travis-CI build status](https://travis-ci.com/theGarageBandOfIT/Travis-CI-example.svg?branch=master)

A small example about how to use Travis-CI

- [Travis-CI-example](#travis-ci-example)
  - [the Application](#the-application)
  - [the Google Compute Kubernetes Cluster](#the-google-compute-kubernetes-cluster)
  - [Integration to Travis-CI](#integration-to-travis-ci)
    - [Using a runner with a docker container including all the tools](#using-a-runner-with-a-docker-container-including-all-the-tools)
    - [Managing secrets](#managing-secrets)
- [Demo time](#demo-time)
- [Cleanup](#cleanup)

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

### Managing secrets

To manage secrets in `Travis-CI` the solution is to store secrets directly into your `Github` _repository_ in an **encrypted** version.  
The `Travis-CI` platform will keep the **encryption private key** into the platform.  
_Runners_ have the ability to get the matching **encryption public key** to **decrypt** secrets in order to use them.

We will then **encrypt** our `JSON` key file (used by `gcloud` _CLI_) and store the **encrypted** version into our `Github` _repository_.

```sh
$ travis login --com
We need your GitHub login to identify you.
This information will not be sent to Travis CI, only to api.github.com.
The password will not be displayed.

Try running with --github-token or --auto if you dont want to enter your password anyway.

Username: lpiot
Password for lpiot: *******
Two-factor authentication code for lpiot: 787939

$ travis encrypt-file ./secrets/gcp-keyfile.json --com
encrypting ./secrets/gcp-keyfile.json for theGarageBandOfIT/Travis-CI-example
storing result as gcp-keyfile.json.enc
storing secure env variables for decryption

Please add the following to your build script (before_install stage in your .travis.yml, for instance):

    openssl aes-256-cbc -K $encrypted_f735c1e13263_key -iv $encrypted_f735c1e13263_iv -in gcp-keyfile.json.enc -out ./secrets/gcp-keyfile.json -d

Pro Tip: You can add it automatically by running with --add.

Make sure to add gcp-keyfile.json.enc to the git repository.
Make sure not to add ./secrets/gcp-keyfile.json to the git repository.
Commit all changes to your .travis.yml.
```

Now we can use this **encrypted** file into our _CI/CD pipeline_…


First, the **encrypted** file is **decrypted** in the `travis.yml` file…

```YAML
before_install:
- openssl aes-256-cbc -K $encrypted_f735c1e13263_key -iv $encrypted_f735c1e13263_iv -in ./secrets/gcp-keyfile.json.enc -out ./secrets/gcp-keyfile.json -d
```

Then, the **decrypted** file is made available into the docker container in the `travis.yml` file…

```YAML
docker run
      --volume "$(pwd)/secrets":/secrets
```

At last, the **decrypted** file is used by the `deploy.sh` script…

```sh
echo "Retrieve credentials so that Gcloud is able to request the right GCP project…"
gcloud auth activate-service-account --key-file=/secrets/gcp-keyfile.json --project=travis-ci-example-258722
```

:tada: You have got a fully functionnal _CI/CD pipeline_ that is able to interacts with both:

* the `GCP` platform
* **and** the `Kubernetes` _cluster_.

# Demo time

```sh
# to get the external IP of the node
$ gcloud compute instances list
NAME                                        ZONE           MACHINE_TYPE  PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
gke-travis-ci-cluster-pool-1-b75ec2b2-29r9  us-central1-a  g1-small                   10.128.0.3   34.68.171.171  RUNNING

# to get the port of the WebUI service
$ kubectl get svc webui
NAME    TYPE       CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
webui   NodePort   10.0.15.244   <none>        80:32621/TCP   9s
```

* WebUI: <http://34.68.171.171:32621/index.html>
* Travis-CI: <https://travis-ci.com/theGarageBandOfIT/Travis-CI-example>

# Cleanup

```sh
kubectl delete --recursive -f ./k8s-resources/
```
