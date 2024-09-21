#!/bin/bash

mkdir -p /root/.ssh
cp /vagrant/files/id_ed25519* /root/.ssh
chmod 400 /root/.ssh/id_ed25519*
cp /vagrant/files/id_ed25519.pub /root/.ssh/authorized_keys

HOSTS=$(head -n7 /etc/hosts)
echo -e "$HOSTS" > /etc/hosts
echo '192.168.56.100 control.k8s.local' >> /etc/hosts
echo '192.168.56.111 worker1.k8s.local' >> /etc/hosts
echo '192.168.56.112 worker2.k8s.local' >> /etc/hosts
echo '192.168.56.50 storage.k8s.local' >> /etc/hosts

if [ "$HOSTNAME" != "storage" ]; then
  sed -Ei 's/(.*swap.*)/#\1/g' /etc/fstab
  swapoff -a
fi
