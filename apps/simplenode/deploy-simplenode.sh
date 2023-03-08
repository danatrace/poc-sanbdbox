#!/bin/bash
echo "*************************************************************************************"
echo "*                           Deploying Simplenode                                    *"
echo "*************************************************************************************"
# Read the domain from CM
source ../util/loaddomain.sh

# Create namespace workshop
kubectl create ns simplenode

# Create deployment of simplenode
kubectl -n simplenode create deploy simplenode --image=grabnerandi/simplenodeservice:1.0.0 

# Expose deployment of simplenode
kubectl -n simplenode expose deployment simplenode --type=NodePort --port=8080 --name simplenode

## Create Ingress Rules
sed 's~domain.placeholder~'"$DOMAIN"'~' manifests/ingress.template > manifests/ingress-gen.yaml

kubectl -n simplenode apply -f manifests/ingress-gen.yaml

echo "Simplnode is available here:"
kubectl get ing -n simplenode

# Expose Easytravel via Loadbalancer (Eks aws)

kubectl expose service simplenode --type=LoadBalancer --name=simplenode-loadbalancer --port=80 --target-port=8080 -n simplenode

# Get Loadbalancer address
until kubectl get service/simplenode-loadbalancer -n simplenode --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done

link=$(kubectl get services -n simplenode -o json | jq -r '.items[] | .status.loadBalancer?|.ingress[]?|.hostname')

UP=$(curl --write-out %{http_code} --silent --output /dev/null http://$link/)
while [[  $(($UP)) != 200 ]]
do
      echo "Waiting for Loadbalancer (Check again in 30 sec)"
      UP=$(curl --write-out %{http_code} --silent --output /dev/null http://$link)
      sleep 30
done

echo "****************************************************************************************************************************************************************************"
echo "*                         link to simplcommerce application http://$link will be up in 5 minutes                                                                           *"
echo "****************************************************************************************************************************************************************************"

