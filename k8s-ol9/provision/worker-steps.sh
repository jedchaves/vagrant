#!/bin/bash

while [ -z "$(ssh -o StrictHostKeyChecking=no 192.168.56.10 stat /root/.kube)" ]; do
    sleep 5
done

bash /vagrant/provision/k8s.sh
echo "KUBELET_EXTRA_ARGS='--node-ip=192.168.56.$1'" > /etc/sysconfig/kubelet

while [ -z "$(ssh -o StrictHostKeyChecking=no 192.168.56.10 stat /root/.kube/config)" ]; do
    sleep 5
done

$(ssh -o StrictHostKeyChecking=no 192.168.56.10 kubeadm token create --print-join-command) --node-name $(hostname -s)
ssh -o StrictHostKeyChecking=no 192.168.56.10 "kubectl label node $(hostname -s) node-role.kubernetes.io/worker="
