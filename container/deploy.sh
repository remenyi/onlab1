#!/bin/bash

IMAGE="node-hpa-example"
TAG="eu.gcr.io/trusty-server-307212/node-hpa-example"
HELMCHART=$IMAGE
SERVICE=$IMAGE
PORT=8080

echo "Building Docker Image: ${IMAGE}"
docker build -t $IMAGE .

echo "Tagging Docker Image ${IMAGE} with ${TAG}"
docker tag  $IMAGE $TAG

echo "Pushing Docker Image ${IMAGE} with ${TAG}"
docker push $TAG

echo "Updating helm chart ${HELMCHART}"
helm install $HELMCHART ../$HELMCHART || helm uninstall $HELMCHART && helm install $HELMCHART ../$HELMCHART

#echo "Port forwarding kubernetes service ${SERVICE} to port ${PORT}"
#sleep 10 # Waiting for pod running state
#kubectl port-forward services/$SERVICE $PORT