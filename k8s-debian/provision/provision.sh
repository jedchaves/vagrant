#!/bin/bash

mkdir -p /root/.ssh
cp /vagrant/files/id_ed25519* /root/.ssh
chmod 400 /root/.ssh/id_ed25519*

# These seds avoids the problem of git adding \r on Windows
sed -i 's,\r$,,' /root/.ssh/id_ed25519-lab
sed 's,\r$,,' /vagrant/files/id_ed25519-lab.pub > /root/.ssh/authorized_keys

HOSTS=$(head -n7 /etc/hosts)
echo -e "$HOSTS" > /etc/hosts
echo '192.168.56.100 control.k8s.local' >> /etc/hosts
echo '192.168.56.111 node1.k8s.local' >> /etc/hosts
echo '192.168.56.112 node2.k8s.local' >> /etc/hosts
echo '192.168.56.50 storage.k8s.local' >> /etc/hosts

if [ "$HOSTNAME" != "storage" ]; then
  sed -Ei 's/(.*swap.*)/#\1/g' /etc/fstab
  swapoff -a
fi
