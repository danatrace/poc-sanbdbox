aws eks --region us-east-1 update-kubeconfig --name eks-sandbox
wget https://github.com/chaosblade-io/chaosblade-operator/releases/download/v1.7.1/chaosblade-operator-1.7.1.tgz
kubectl create namespace chaosblade
helm install chaosblade-operator chaosblade-operator-1.7.1.tgz --namespace chaosblade
