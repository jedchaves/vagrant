#!/bin/bash

bash /vagrant/provision/k8s.sh

# Definicao das redes
POD_CIDR='172.20.0.0/16'
SERVICE_CIDR='172.19.0.0/16'

# The presence of ~/.kube indicate to workers that they 
# can download the packages from control
mkdir -p ~/.kube

echo "KUBELET_EXTRA_ARGS='--node-ip=192.168.56.$1'" > /etc/sysconfig/kubelet

# Ensure pause image is the same for kubeadm and crictl
PAUSE=`kubeadm config images list | grep pause`
sed -Ei "s,(signature.*),\1\npause_image = \"$PAUSE\"," /etc/crio/crio.conf.d/10-crio.conf
sed -i "s|10.85.0.0/16|$POD_CIDR|g" /etc/cni/net.d/11-crio-ipv4-bridge.conflist
systemctl restart crio

# Baixar imagens usadas pelo Control Plane
kubeadm config images pull

# Criar o cluster
kubeadm init --apiserver-advertise-address=192.168.56."$1" --node-name `hostname -s` --pod-network-cidr="$POD_CIDR" --service-cidr="$SERVICE_CIDR"

# The presence of ~/.kube/config indicate to workers that they
# can join the cluster
cp /etc/kubernetes/admin.conf ~/.kube/config

# Instalar CNI Calico
curl -sL https://docs.projectcalico.org/manifests/calico.yaml | sed 's,docker,quay,' > calico.yml
kubectl create -f calico.yml
rm -f calico.yml

# Enable colorful "ls"
sed -Ei 's/# (export LS)/\1/' /root/.bashrc
sed -Ei 's/# (eval ")/\1/' /root/.bashrc
sed -Ei 's/# (alias ls=)/\1/' /root/.bashrc

# Completion e alias para o kubectl
echo -e "\n# Kubectl\nsource <(kubectl completion bash)\nalias k=kubectl\ncomplete -o default -F __start_kubectl k" >> /root/.bashrc

# Force bash to save history after each command
echo "export PROMPT_COMMAND='history -a'" >> /root/.bashrc