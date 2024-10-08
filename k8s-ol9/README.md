### 🚀 Cluster Kubernetes 1.31 com Oracle Linux 9.

Serão criadas quatro máquinas; certifique-se de que você tenha memória livre suficiente:

| Máquina | IP             | CPU | Memória |
|---------|----------------|-----|---------|
| control | 192.168.56.10 |   2 |    2048 |
| worker1 | 192.168.56.11 |   1 |    2048 |
| worker2 | 192.168.56.12 |   1 |    2048 |
| storage | 192.168.56.30 |   1 |     1024 |

Você pode alterar a memória/CPU padrão de cada máquina virtual, alterando o hash denominado `vms` dentro do `Vagrantfile`:

```ruby
vms = {
  'control' => {'memory' => '2048', 'cpus' => 2, 'ip' => '10', 'provision' => 'control.sh'},
  'worker1' => {'memory' => '2048', 'cpus' => 1, 'ip' => '11', 'provision' => 'worker.sh'},
  'worker2' => {'memory' => '2048', 'cpus' => 1, 'ip' => '12', 'provision' => 'worker.sh'},
  'storage' => {'memory' => '1024', 'cpus' => 1, 'ip' => '30', 'provision' => 'storage.sh'}
}
```

### ⚙ Provisionamento

Instale o Vagrant - e talvez algum [plugin](https://vagrant-lists.github.io/) - e um hypervisor, clone o repositório e execute `vagrant up`:

```bash
vagrant ssh control
sudo -i
kubectl get nodes
```

### 📚 Referências

Esse conteúdo foi adaptado do repositório do [Hector Vido](https://github.com/hector-vido/).

https://github.com/hector-vido/kubernetes/
