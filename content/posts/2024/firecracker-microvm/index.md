---
title: "Firecracker microVM"
date: 2024-01-01
# slug: firecracker-microvm
description: "Getting started with Firecracker microVM."
# cover: https://cdn.hashnode.com/uploads/covers/66c63e90f3f170bad73e8656/fcb6d10d-f703-44d1-bf77-d03311ebf601.png
tags:
  - linux
  - virtualization
  - kvm
  - microvm
  - firecracker
type: blog
---

## Introduction

{{< callout type="important" >}}
**WIP**
{{< /callout >}}

This is part one of the Fireracker microVM guide.

## Create/Build Kernel

Get the Linux source code at `v6.19` using the recommended guest Kernel configuration (see: [https://github.com/firecracker-microvm/firecracker/tree/main/resources/guest\_configs](https://github.com/firecracker-microvm/firecracker/tree/main/resources/guest_configs)).

```shell
$ git clone https://github.com/torvalds/linux.git
$ cd linux
$ git checkout -b v6.19 v6.19
$ wget 'https://raw.githubusercontent.com/firecracker-microvm/firecracker/refs/heads/main/resources/guest_configs/microvm-kernel-ci-x86_64-6.1.config' -O .config
$ make olddefconfig
$ make vmlinux
```

If the above fails at any point, please try either `yes "" | make oldconfig` or `make silentoldconfig` before `make vmlinux`.

# Create Linux rootfs image

## Download pre-built Linux Kernel and rootfs

If you prefer a pre-built solution then execute the below:

```shell
# Download a linux kernel binary
$ wget https://s3.amazonaws.com/spec.ccfc.min/firecracker-ci/v1.7/x86_64/vmlinux-5.10.204
# Download a rootfs
$ wget https://s3.amazonaws.com/spec.ccfc.min/firecracker-ci/v1.7/x86_64/ubuntu-22.04.ext4
# Download the ssh key for the rootfs
$ wget https://s3.amazonaws.com/spec.ccfc.min/firecracker-ci/v1.7/x86_64/ubuntu-22.04.id_rsa
# Set user read permission on the ssh key
$ chmod 400 ./ubuntu-22.04.id_rsa
```

## Internet within guest

Extra reading material.

1. [https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md#in-the-guest](https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md#in-the-guest).
1. [https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md#on-the-host](https://github.com/firecracker-microvm/firecracker/blob/main/docs/network-setup.md#on-the-host).
1. [https://github.com/firecracker-microvm/firecracker/issues/1585](https://github.com/firecracker-microvm/firecracker/issues/1585).
1. [https://github.com/firecracker-microvm/firecracker/blob/1afbacadfa7e9891e654928044ecfb322642c179/docs/network-setup.md?plain=1#L19](https://github.com/firecracker-microvm/firecracker/blob/1afbacadfa7e9891e654928044ecfb322642c179/docs/network-setup.md?plain=1#L19).

## Demo

[https://github.com/firecracker-microvm/firecracker-demo/blob/main/start-firecracker.sh](https://github.com/firecracker-microvm/firecracker-demo/blob/main/start-firecracker.sh)

# **References**

1. [https://firecracker-microvm.github.io](https://firecracker-microvm.github.io).
1. [https://github.com/firecracker-microvm/firecracker](https://github.com/firecracker-microvm/firecracker).
1. [https://jvns.ca/blog/2021/01/23/firecracker--start-a-vm-in-less-than-a-second](https://jvns.ca/blog/2021/01/23/firecracker--start-a-vm-in-less-than-a-second).
1. [https://fly.io/blog/fly-machines](https://fly.io/blog/fly-machines).
1. [https://stanislas.blog/2021/08/firecracker](https://stanislas.blog/2021/08/firecracker).