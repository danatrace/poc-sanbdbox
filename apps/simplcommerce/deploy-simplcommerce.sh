#!/bin/bash

# Read the domain from CM
source ../util/loaddomain.sh

kubectl create ns simplcommerce

# Create deployment of simplcommerce with sqlite db inside container.
#kubectl -n simplcommerce create deploy simplcommerce --image=shinojosa/simplcommerce-coza

# Expose deployment of simplcommerce
#kubectl -n simplcommerce expose deployment simplcommerce --type=NodePort --port=80 --name simplcommerce

kubectl -n simplcommerce apply -f manifests/

sed 's~domain.placeholder~'"$DOMAIN"'~'  manifests/ingress/pgadmin-ingress.template > manifests/ingress/pgadmin-ingress-gen.yaml
sed 's~domain.placeholder~'"$DOMAIN"'~'  manifests/ingress/simplcommerce-ingress.template > manifests/ingress/simplcommerce-ingress-gen.yaml

kubectl -n simplcommerce apply -f manifests/ingress/

echo "The application is available in the following endpoints"
kubectl get ing -n simplcommerce

# Expose Easytravel via Loadbalancer (Eks aws)

kubectl expose service simplcommerce --type=LoadBalancer --name=simplcommerce-loadbalancer --port=80 --target-port=80 -n simplcommerce

# Get Loadbalancer address
until kubectl get service/simplcommerce-loadbalancer -n simplcommerce --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done

link=$(kubectl get services -n simplcommerce -o json | jq -r '.items[] | .status.loadBalancer?|.ingress[]?|.hostname')

echo "link to simplcommerce application http://$link will be up in 5 minutes"

