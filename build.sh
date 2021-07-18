#!/bin/bash

docker build \
    -t scottcrossen/kube-node-labels:latest \
    -t scottcrossen/kube-node-labels:"$(git rev-parse --short HEAD)" \
    .
docker push \
    scottcrossen/kube-node-labels:latest
docker push \
    scottcrossen/kube-node-labels:"$(git rev-parse --short HEAD)"
echo "Pushed $(git rev-parse --short HEAD)"
