#Docker
apt-get update
apt-get install ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

export VERSION_STRING=5:20.10.7~3-0~ubuntu-xenial
apt-get install docker-ce=$VERSION_STRING docker-ce-cli=$VERSION_STRING containerd.io -y #docker-buildx-plugin docker-compose-plugin

#Kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

#K3d
wget https://github.com/rancher/k3d/releases/download/v3.0.0/k3d-linux-amd64 -O /usr/local/bin/k3d
chmod +x /usr/local/bin/k3d
k3d cluster create my-cluster --api-port 6443 -p 8888:80@loadbalancer --agents 2

chown vagrant $KUBECONFIG
chmod 600 $KUBECONFIG
echo "export KUBECONFIG=$KUBECONFIG" >> /etc/profile.d/myvar.sh

#Argocd
kubectl create namespace argocd

sleep 60

kubectl apply -f .confs/install.yaml -n argocd
kubectl apply -f .confs/ingress.yaml -n argocd
kubectl rollout status deployment.apps/argocd-server -n argocd

kubectl create namespace dev

kubectl apply -f .confs/project.yaml -n argocd
kubectl apply -f .confs/application.yaml -n argocd


