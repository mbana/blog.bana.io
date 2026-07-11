---
title: "Multi-node k3s cluster using Vagrant with the virtualbox provider"
description: "Every wanted to bring up multi-node K3S cluster up? This post covers how to do."
date: 2024-10-01
# slug: multi-node-k3s-cluster-using-vagrant-with-the-virtualbox-provider
tags:
  - vagrant
  - Linux
  - Kubernetes
  - Virtual Machine
  - virtualbox
  - k3s
type: blog
---

## Prerequisites

1. VirtualBox is required.
1. Vagrant is required.
1. The `server_ip` (`192.168.56.10`) was obtained from host by running the command that follows.
1. I do know that you can automate this by using `jq` to get the IP range to use by using the `-color` option to the `ip` command. This, [https://blog.lazy-evaluation.net/posts/linux/ifconfig-ip-json-jq.html](https://blog.lazy-evaluation.net/posts/linux/ifconfig-ip-json-jq.html), provides an example of how to do so. Essentially, it’s something like `ip -json address | jq -r '.[] | select(.ifname == "vboxnet0") | .addr_info[].local'`.
    

```plaintext
$ ip addr show | grep vbox
35: vboxnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    inet 192.168.56.1/24 brd 192.168.56.255 scope global vboxnet
```

## Bring up

This script below—remember to replace `server_ip` with the result of the previously mentioned IP—allows me to bring a multi-node k3s cluster running on Alpine:

```ruby
server_ip = "192.168.56.10"

workers = {
  "k3s-worker1" => "192.168.56.11",
  "k3s-worker2" => "192.168.56.12",
  "k3s-worker3" => "192.168.56.13",
  "k3s-worker4" => "192.168.56.14",
}

Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine318"
  config.vm.box_check_update = false

  config.vm.define "k3s-server", primary: true do |server|
    server.vm.network "private_network", ip: server_ip
    server.vm.synced_folder "./shared", "/vagrant_shared"
    server.vm.hostname = "k3s-server"

    server.vm.provider "virtualbox" do |vb|
      vb.memory = "8192"
      vb.cpus = "16"
    end

    server.vm.provision "shell", inline: <<-SHELL
sudo -i
apk add iptables ip6tables
ip addr show

export INSTALL_K3S_EXEC="--bind-address=#{server_ip} --node-external-ip=#{server_ip} --node-ip=#{server_ip} --disable=metrics-server,servicelb,traefik --flannel-iface=eth1 --snapshotter=stargz"
curl -sfL https://get.k3s.io | sh -

until cp -v /var/lib/rancher/k3s/server/token /vagrant_shared/; do echo 'sleeping for 2 seconds before try'; sleep 2; done
until cp -v /etc/rancher/k3s/k3s.yaml /vagrant_shared/; do echo 'sleeping for 2 seconds before try'; sleep 2; done

cat /etc/rancher/k3s/k3s.yaml
SHELL
  end

  workers.each do |worker_name, worker_ip|
    config.vm.define worker_name do |worker|
      worker.vm.network "private_network", ip: worker_ip
      worker.vm.synced_folder "./shared", "/vagrant_shared"
      worker.vm.hostname = worker_name

      worker.vm.provider "virtualbox" do |vb|
        vb.memory = "8192"
        vb.cpus = "16"
      end

      worker.vm.provision "shell", inline: <<-SHELL
sudo -i
apk add iptables ip6tables
ip addr show

export K3S_TOKEN_FILE=/vagrant_shared/token
export K3S_URL=https://#{server_ip}:6443
export INSTALL_K3S_EXEC="--bind-address=#{worker_ip} --node-external-ip=#{worker_ip} --node-ip=#{worker_ip} --flannel-iface=eth1 --snapshotter=stargz"
curl -sfL https://get.k3s.io | sh -
SHELL
    end
  end
end
```