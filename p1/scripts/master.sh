apt update
apt install -y curl wget systemd
curl -sfL https://get.k3s.io |  sh -s - --flannel-iface=enp0s8
mkdir /home/vagrant/.kube
cp /etc/rancher/k3s/k3s.yaml $KUBECONFIG && chown vagrant $KUBECONFIG
chmod 600 $KUBECONFIG
echo "export KUBECONFIG=$KUBECONFIG" >> /etc/profile.d/myvar.sh
cp /var/lib/rancher/k3s/server/node-token /home/vagrant/.confs/node.token