#!/bin/bash
echo "*************************************************************************************"
echo "*                           Deploying Dynabank                                *"
echo "*************************************************************************************"

#curl https://raw.githubusercontent.com/suchcodewow/dbic/main/deploy/dbic.yaml > ~/dbic.yaml
#kubectl apply -f ~/dbic.yaml
kubectl apply -f manifests/

dbic=$(kubectl get services -n dbic -o json | jq -r '.items[] | .status.loadBalancer?|.ingress[]?|.hostname')

UP=$(curl --write-out %{http_code} --silent --output /dev/null http://$dbic/)
while [[  $(($UP)) != 200 ]]
do
      dbic=$(kubectl get services -n dbic -o json | jq -r '.items[] | .status.loadBalancer?|.ingress[]?|.hostname')
      echo "Waiting for Loadbalancer (Check again in 30 sec)"
      UP=$(curl --write-out %{http_code} --silent --output /dev/null http://$dbic/)
      sleep 30
done



echo "****************************************************************************************************************************************************************************"
echo "                link to dynabank application http://$dbic                                                                                                                   "
echo "****************************************************************************************************************************************************************************"
