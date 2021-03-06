#!/bin/bash
ufw disable
swapoff -a
cat >> /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl -p /etc/sysctl.d/k8s.conf
apt-get install -y -q socat ebtables ethtool
dpkg -i kubernetes-cni_0.5.1-00_amd64.deb
dpkg -i kubelet_1.8.7-00_amd64.deb
dpkg -i kubectl_1.8.7-00_amd64.deb
dpkg -i kubeadm_1.8.7-00_amd64.deb
systemctl enable kubelet
systemctl start kubelet

images=(kube-proxy-amd64:v1.8.7 \
pause-amd64:3.0 \
kubernetes-dashboard-amd64:1.8.1)
for imageName in ${images[@]} ; do
  docker pull andylo25/$imageName
  docker tag andylo25/$imageName gcr.io/google_containers/$imageName
  docker rmi andylo25/$imageName
done
kubeadm join --token 34fb5a.87ec418b32857c65 192.168.129.133:6443 --discovery-token-ca-cert-hash sha256:da4765f5721db7ed2130c265a71e849005f0334aeb821cd05ec9c9020e036919
