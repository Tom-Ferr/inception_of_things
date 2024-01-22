#Docker
apt-get update
apt-get install ca-certificates curl gnupg git
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
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
chmod +x /usr/local/bin/k3d
k3d cluster create my-cluster --api-port 6443 -p 8888:80@loadbalancer --agents 2  --k3s-arg "--disable=traefik@server:0"

chown vagrant $KUBECONFIG
chmod 600 $KUBECONFIG
echo "export KUBECONFIG=$KUBECONFIG" >> /etc/profile.d/myvar.sh

#Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

sleep 60

# #Nginx
kubectl create namespace nginx-ingress
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-ingress nginx-stable/nginx-ingress -n nginx-ingress --set rbac.create=true,controller.service.externalIPs={172.18.0.2} #,controller.service.loadBalancerIP=192.168.56.110 

# #Gitlab
kubectl create namespace gitlab
helm repo add gitlab https://charts.gitlab.io/
helm repo update
helm install gitlab -f .confs/gitlab_values.yaml -n gitlab gitlab/gitlab
kubectl get secret gitlab-gitlab-initial-root-password -n gitlab -o jsonpath="{.data.password}" | base64 -d > .confs/gitlab_root.secret


# Argocd
kubectl create namespace argocd
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm install my-argo-cd -f .confs/argocd_values.yaml argo/argo-cd -n argocd
kubectl rollout status deployment.apps/my-argo-cd-argocd-server -n argocd

kubectl create namespace dev

kubectl apply -f .confs/project.yaml -n argocd
kubectl apply -f .confs/application.yaml -n argocd
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d > .confs/argocd_admin.secret

echo "172.18.0.2 gitlab.tdecama.io" >> /etc/hosts 
echo "172.18.0.2 tdecama.io" >> /etc/hosts 

git config --global http.sslVerify false


