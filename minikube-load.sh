#!/bin/bash
eval $(minikube docker-env)
docker image load -i $1
