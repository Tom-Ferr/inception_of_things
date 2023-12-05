apt update
apt install -y curl wget systemd
export K3S_MASTER_TOKEN=$(cat /home/vagrant/.confs/node.token)
curl -sfL https://get.k3s.io | K3S_URL=${K3S_MASTER_URL} K3S_TOKEN=${K3S_MASTER_TOKEN} sh -s - --flannel-iface=enp0s8