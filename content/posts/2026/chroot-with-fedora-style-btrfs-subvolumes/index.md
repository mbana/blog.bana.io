---
title: "chroot with Fedora-style BTRFS subvolumes"
description: "When you are trying to fix broken system you often have to `chroot` into it. This blog post shows how to use `chroot` with the default Fedora-style BTRFS layout."
date: 2026-07-12
tags:
  - Linux
  - Fedora
  - BTRFS
type: blog
---

# Introduction

I have done this enough times that I thought I'd just write about so I can easily get that commands I need to run to `chroot` for a Fedora-style BTRFS partition layout. At present there isn't an equilevant version of `arch-chroot` (see <https://github.com/archlinux/arch-install-scripts>) for Fedora which automates all of the below.

## Partition layout

Consult <https://docs.fedoraproject.org/en-US/workstation-docs/disk-config/> for more information on how things are layed out in Fedora. Here is a summary:

| Role                 | Filesystem | Mount Point |
| ---------------------| ---------- | ----------- |
| EFI System Partition | FAT32      | `/boot/efi` |
| Boot Partition       | ext4       | `/boot`     |
| Root Subvolume       | BTRFS      | `/`         |
| Var Subvolume        | BTRFS      | `/var`      |
| Home Subvolume       | BTRFS      | `/home`     |

## The actual commands to run before `chroot`

```sh
sudo mount -v /dev/sde1 /mnt/fedora/boot/efi
sudo mount -v /dev/sde2 /mnt/fedora/boot
sudo mount -v /dev/sde3 /mnt/fedora -t btrfs -o subvol=root
sudo mount -v /dev/sde3 /mnt/fedora/var -t btrfs -o subvol=var
sudo mount -v /dev/sde3 /mnt/fedora/home -t btrfs -o subvol=home

sudo mount -v --bind /dev /mnt/fedora/dev
sudo mount -v --bind /dev/pts/ /mnt/fedora/dev/pts/
sudo mount -v -t proc /proc /mnt/fedora/proc
sudo mount -v -t sysfs /sys /mnt/fedora/sys
sudo mount -v -t tmpfs tmpfs /mnt/fedora/run
sudo mkdir -pv /mnt/fedora/run/systemd/resolve/
echo 'nameserver 1.1.1.1' | sudo tee -a /mnt/fedora/run/systemd/resolve/stub-resolv.conf

sudo chroot /mnt/fedora
```

Then unmount the partitions using:

```sh
sudo umount -v /mnt/fedora/dev /mnt/fedora/dev/pts/ /mnt/fedora/proc /mnt/fedora/sys /mnt/fedora/run
```

Done.