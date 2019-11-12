#!/bin/sh

echo "Retrieve credentials so that Gcloud is able to request the right GCP project…"
gcloud auth activate-service-account --key-file=/secrets/gcp-keyfile.json --project=travis-ci-example-258722

echo "Check that a Kubernetes cluster is there…"
gcloud container clusters list

echo "Retrieve credentials so that kubectl is able to request the Kubernetes cluster"
gcloud container clusters get-credentials travis-ci-cluster --zone=us-central1-a
kubectl get nodes

echo "Deploy DockerCoins app"
kubectl apply --recursive=true -f /k8s-resources
