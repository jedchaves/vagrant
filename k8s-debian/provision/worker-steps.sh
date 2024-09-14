#!/bin/bash

# ssh < /dev/null will avoid ssh to exit when bash is reading from stdin

while [ -z "$(ssh -o stricthostkeychecking=no 192.168.56.100 stat /root/.kube < /dev/null)" ]; do
    sleep 5
done

scp -r root@192.168.56.100:/var/cache/apt/archives /var/cache/apt/

# This sed avoids the problem of git adding \r on Windows
sed 's,\r$,,' /vagrant/provision/k8s.sh | bash
echo "KUBELET_EXTRA_ARGS='--node-ip=192.168.56.$1'" > /etc/default/kubelet

while [ -z "$(ssh 192.168.56.100 stat /root/.kube/config < /dev/null)" ]; do
    sleep 5
done

$(ssh -o StrictHostKeyChecking=no 192.168.56.100 kubeadm token create --print-join-command) --node-name $(hostname -s)
ssh -o StrictHostKeyChecking=no 192.168.56.100 "kubectl label node $(hostname -s) node-role.kubernetes.io/worker="
apt-get clean
