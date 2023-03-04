#!/bin/bash

# Read the domain from CM
source ../util/loaddomain.sh

# Create namespace workshop
kubectl create ns easytravel

## Create Ingress Rules
sed 's~domain.placeholder~'"$DOMAIN"'~' manifests/ingress.template > manifests/ingress-gen.yaml

kubectl -n easytravel apply -f manifests/

echo "Easytravel is available here:"
kubectl get ing -n easytravel

# Expose Easytravel via Loadbalancer (Eks aws)

kubectl expose service easytravel-www --type=LoadBalancer --name=easytravel-loadbalancer --port=80 --target-port=80 -n easytravel

# Get Loadbalancer address
until kubectl get service/easytravel-loadbalancer -n easytravel --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done

easytravel=$(kubectl get services -n easytravel -o json | jq -r '.items[] | .status.loadBalancer?|.ingress[]?|.hostname')

echo "link to easytravel application http://$easytravel will be up in 5 minutes"
