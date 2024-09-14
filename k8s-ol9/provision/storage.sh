#!/bin/bash

# Instalar NFS Server e dependencias
yum install -y nfs-utils chrony bash-completion tzdata

# Desativando o SElinux.
sed -i 's|^SELINUX=enforcing$|SELINUX=permissive|' /etc/selinux/config
setenforce 0

# Ajustar Time Zone
timedatectl set-timezone America/Sao_Paulo

# Ajustar ntp
sed -i 's|^pool|# pool|g' /etc/chrony.conf
echo "pool a.ntp.br iburst" >> /etc/chrony.conf
echo "pool b.ntp.br iburst" >> /etc/chrony.conf

# Criar diretorios para o NFS
mkdir -p /srv/nfs/v{0,1,2,3,4,5,6,7,8,9}

# Configurar o NFS Server
cat > /etc/exports <<EOF
/srv/nfs/v0 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v1 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v2 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v3 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v4 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v5 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v6 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v7 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v8 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
/srv/nfs/v9 192.168.56.0/24(rw,no_root_squash,no_subtree_check)
EOF

# Subir as configuracoes do NFS Server
exportfs -a

# Ajustar servicos
systemctl enable --now nfs-server
systemctl disable --now firewalld
systemctl enable --now chronyd
systemctl restart chronyd