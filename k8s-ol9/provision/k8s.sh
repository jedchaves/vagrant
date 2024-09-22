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

# Desativando o SElinux.
sed -i 's|^SELINUX=enforcing$|SELINUX=permissive|' /etc/selinux/config
setenforce 0

# Instalar dependencias
yum install -y nfs-utils chrony bash-completion tzdata podman vim

# Ajustar Time Zone
timedatectl set-timezone America/Sao_Paulo

# Ajustar ntp
sed -i 's|^pool|# pool|g' /etc/chrony.conf
echo "pool a.ntp.br iburst" >> /etc/chrony.conf
echo "pool b.ntp.br iburst" >> /etc/chrony.conf

# Versao do K8s
export K8S_VERSION='v1.30'
export CRIO_VERSION='v1.30'

# Adicionar K8s Repo
cat << EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/$K8S_VERSION/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Adicionar CRI-O Repo
cat <<EOF | tee /etc/yum.repos.d/cri-o.repo
[cri-o]
name=CRI-O
baseurl=https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/addons:/cri-o:/stable:/$CRIO_VERSION/rpm/repodata/repomd.xml.key
exclude=cri-o
EOF

# Instalar CRI-O e K8s
yum install -y cri-o --disableexcludes=cri-o
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Ajustar servicos
systemctl disable --now firewalld
systemctl enable --now chronyd
systemctl restart chronyd
systemctl enable --now crio
systemctl enable --now kubelet
