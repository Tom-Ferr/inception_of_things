apt update
apt install -y curl wget systemd
curl -sfL https://get.k3s.io | sh -s - --disable=traefik
mkdir /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml $KUBECONFIG && chown vagrant $KUBECONFIG
chmod 600 $KUBECONFIG
echo "export KUBECONFIG=$KUBECONFIG" >> /etc/profile.d/myvar.sh
echo "192.168.56.110 app1.com" >> /etc/hosts
echo "192.168.56.110 app2.com" >> /etc/hosts
echo "192.168.56.110 app3.com" >> /etc/hosts
kubectl apply -f .confs/nginx-controller.yaml
echo waiting for nginx-controller to be ready
kubectl wait --for=condition=Ready=True deployment.apps/ingress-nginx-controller -n ingress-nginx --timeout=120s
kubectl apply -f .confs/load-balancer.yaml
kubectl apply -f .confs/app-one.yaml
kubectl apply -f .confs/app-two.yaml
kubectl apply -f .confs/app-three.yaml
kubectl apply -f .confs/ingress.yaml