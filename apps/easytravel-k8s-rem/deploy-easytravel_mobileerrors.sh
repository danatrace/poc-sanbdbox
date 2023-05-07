#!/bin/bash
echo "*************************************************************************************"
echo "*                       Deploying Easytravel with Remediation                       *"
echo "*************************************************************************************"
# Read the domain from CM
source ../util/loaddomain.sh

# Create namespace workshop
kubectl create ns easytravel

## Create Ingress Rules
sed 's~domain.placeholder~'"$DOMAIN"'~' manifests_mobileerrors/ingress.template > manifests_mobileerrors/ingress-gen.yaml

kubectl -n easytravel apply -f manifests_mobileerrors/

echo "Easytravel is available here:"
kubectl get ing -n easytravel

# Expose Easytravel via Loadbalancer (Eks aws)

kubectl expose service easytravel-www --type=LoadBalancer --name=easytravel-loadbalancer --port=80 --target-port=80 -n easytravel

# Get Loadbalancer address
until kubectl get service/easytravel-loadbalancer -n easytravel --output=jsonpath='{.status.loadBalancer}' | grep "ingress"; do : ; done

easytravel=$(kubectl get services -n easytravel -o json | jq -r '.items[] | .status.loadBalancer?|.ingress[]?|.hostname')

UP=$(curl --write-out %{http_code} --silent --output /dev/null http://$easytravel/)
while [[  $(($UP)) != 200 ]]
do
      echo "Waiting for Loadbalancer (Check again in 30 sec)"
      UP=$(curl --write-out %{http_code} --silent --output /dev/null http://$easytravel/)
      sleep 30
done

echo "****************************************************************************************************************************************************************************"
echo "                link to easytravel application http://$easytravel                                                                                                           "
echo "****************************************************************************************************************************************************************************"
