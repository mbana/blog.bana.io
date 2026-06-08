---
title: "Installing nerdctl (contaiNERD CTL) and BuildKit"
description: "A Docker-compatible CLI for Containerd."
date: 2024-10-12
# slug: installing-nerdctl-containerd-ctl-and-buildkit
tags:
  - docker
  - containers
  - containerization
  - nerdctl
  - linux
type: blog
---

## Introduction

More to come—such as using `eStargz`—but for now see below. Create a file with the contents in the following section, then simply execute it.

## The Code

```bash
# Credits to: https://www.guide2wsl.com/nerdctl/
mkdir /tmp/nerdctl || true
cd /tmp/nerdctl

set -x

ARCHITECTURE="$([ "$(uname -m)" = "x86_64" ] && echo "amd64" || echo "arm64")"

VERSION_NERDCTL_OFFICIAL="$(curl --silent 'https://api.github.com/repos/containerd/nerdctl/releases/latest' | jq '.tag_name')"
VERSION_NERDCTL="${VERSION_NERDCTL_OFFICIAL//v/}"
VERSION_CNI="$(curl --silent 'https://api.github.com/repos/containernetworking/plugins/releases/latest' | jq '.tag_name')"
VERSION_BUILDKIT="$(curl --silent 'https://api.github.com/repos/moby/buildkit/releases/latest' | jq '.tag_name')"

wget "https://github.com/containerd/nerdctl/releases/download/v${VERSION_NERDCTL}/nerdctl-${VERSION_NERDCTL}-linux-${ARCHITECTURE}.tar.gz"
tar -zxf nerdctl-${VERSION_NERDCTL}-linux-${ARCHITECTURE}.tar.gz nerdctl
sudo mv nerdctl /usr/bin/nerdctl
rm nerdctl-${VERSION_NERDCTL}-linux-${ARCHITECTURE}.tar.gz

wget "https://github.com/containernetworking/plugins/releases/download/${VERSION_CNI}/cni-plugins-linux-${ARCHITECTURE}-${VERSION_CNI}.tgz"
sudo mkdir -p /opt/cni/bin/
sudo tar -zxf cni-plugins-linux-${ARCHITECTURE}-${VERSION_CNI}.tgz -C /opt/cni/bin/
rm cni-plugins-linux-${ARCHITECTURE}-${VERSION_CNI}.tgz

  # https://github.com/moby/buildkit for building images
wget "https://github.com/moby/buildkit/releases/download/${VERSION_BUILDKIT}/buildkit-${VERSION_BUILDKIT}.linux-${ARCHITECTURE}.tar.gz"
tar -zxvf buildkit-${VERSION_BUILDKIT}.linux-${ARCHITECTURE}.tar.gz
sudo mv bin/* /usr/bin/
rm buildkit-${VERSION_BUILDKIT}.linux-${ARCHITECTURE}.tar.gz

chmod 700 ${HOME}/bin
cp "$(which nerdctl)" ${HOME}/bin
sudo chown root ${HOME}/bin/nerdctl
sudo chmod +s ${HOME}/bin/nerdctl

mkdir -pv ~/.local/bin || true
ln -sv "$(which nerdctl)" ~/.local/bin/docker
ln -sv "$(which nerdctl)" ~/bin/docker
ln -sv "$(which nerdctl)" ~/.bin/docker

sudo apt install containerd
  # sudo chgrp "$(id -gn)" /run/containerd/containerd.sock

wget https://raw.githubusercontent.com/containerd/nerdctl/main/extras/rootless/containerd-rootless-setuptool.sh
wget https://raw.githubusercontent.com/containerd/nerdctl/main/extras/rootless/containerd-rootless.sh
chmod +x containerd-rootless-setuptool.sh
chmod +x containerd-rootless.sh
PATH="$(pwd):${PATH}" ./containerd-rootless-setuptool.sh
systemctl --user enable containerd.service
systemctl --user start containerd.service

sudo loginctl enable-linger "$(whoami)"

# systemd-analyze --system unit-paths
# mkdir -pv ~/.local/share/systemd/user || true
# cd ~/.local/share/systemd/user
mkdir -pv ~/.config/systemd/user.control || true
cd ~/.config/systemd/user.control

wget https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/user/buildkit-proxy.service
wget https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/user/buildkit-proxy.socket
wget https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/user/buildkit.service

systemctl --user daemon-reload
systemctl enable --user --now buildkit-proxy.service
systemctl enable --user --now buildkit-proxy.socket
systemctl enable --user --now buildkit.service
systemctl start --user --now buildkit-proxy.service
systemctl start --user --now buildkit.service

# systemd-analyze --global unit-paths
# Probably /usr/lib/systemd/system
sudo mkdir -pv /usr/lib/systemd/system
cd /usr/lib/systemd/system
sudo wget https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/system/buildkit.service
sudo wget https://raw.githubusercontent.com/moby/buildkit/master/examples/systemd/system/buildkit.socket

sudo systemctl daemon-reload
```