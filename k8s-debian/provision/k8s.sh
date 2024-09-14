#!/bin/bash

# Adicionar modulos do kernel
cat << EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
nf_nat
xt_REDIRECT
xt_owner
iptable_nat
iptable_mangle
iptable_filter
EOF

# Subir os modulos do kernel
modprobe overlay
modprobe br_netfilter
modprobe nf_nat
modprobe xt_REDIRECT
modprobe xt_owner
modprobe iptable_nat
modprobe iptable_mangle
modprobe iptable_filter

# Ajustar parametros do kernel
cat << EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

# Subir novos parametros do kernel
sysctl --system

# Instalar dependencias
apt-get update
apt-get install -y apt-transport-https ca-certificates curl gnupg2 vim nfs-common chrony bash-completion tzdata

# Ajustar Time Zone
timedatectl set-timezone America/Sao_Paulo

# Ajustar ntp
sed -i 's|^pool|# pool|g' /etc/chrony/chrony.conf
echo -e "\npool a.ntp.br iburst\npool b.ntp.br iburst" >> /etc/chrony/chrony.conf

export K8S_VERSION='v1.31'
export CRIO_VERSION='v1.31'

# Kubernetes
curl -fsSL https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/kubernetes.list

# CRI-O
curl -fsSL https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/Release.key |
    gpg --dearmor -o /etc/apt/keyrings/cri-o-apt-keyring.gpg

echo "deb [signed-by=/etc/apt/keyrings/cri-o-apt-keyring.gpg] https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/deb/ /" |
    tee /etc/apt/sources.list.d/cri-o.list

apt-get update
apt-get install -y cri-o kubelet kubeadm kubectl
apt-mark hold kubelet kubeadm kubectl cri-o

# Ajustar servicos
systemctl enable --now chrony
systemctl restart chronyd
systemctl enable --now crio
systemctl enable --now kubelet
