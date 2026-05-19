---
title: "Android 16: Android Linux Terminal Customisations"
description: "How to customise the Linux distribution that comes with the Android Linux Terminal even further."
date: 2026-05-17
tags:
  - Android
  - Linux
  - Terminal
  - AVF
type: blog
---

## Introduction

**NOTE:** I will be updating this post as I learn more about the Android Linux Terminal and AVF so be sure to bookmark it or something.

I purchased the [POCO X8 PRO MAX](https://www.amazon.co.uk/dp/B0GHN3P6X1?ref=ppx_yo2ov_dt_b_fed_asin_title&th=1) so I could play around with AVF. Please do leave a comment, or email me on m@bana.io, with your experiences, links, ideas and thoughts on this rather useful feature.

## Steps

### Host

On the host, that is, the device running the quest VM run:

```sh
# Add Terminal app to deviceidle whitelist (prevents doze killing)
adb shell cmd deviceidle whitelist +com.android.virtualization.terminal
# Set app standby bucket to active (prevents Android from deprioritizing)
adb shell am set-standby-bucket com.android.virtualization.terminal active
# Grant background run permissions
adb shell cmd appops set com.android.virtualization.terminal RUN_IN_BACKGROUND allow
adb shell cmd appops set com.android.virtualization.terminal RUN_ANY_IN_BACKGROUND allow
# Exempt from power restrictions
adb shell cmd appops set com.android.virtualization.terminal SYSTEM_EXEMPT_FROM_POWER_RESTRICTIONS allow
```

### Guest

In the Android Linux Terminal application increase the size of the disk allocated to the VM to something reasonable, and add the following listening ports to `Port control`:

1. `1986`.
2. `41641`.

The last step isn't, strictly speaking, required but it just prevents annoy notifications on the device. See the screenshots section for an example configuration.

Once you've done the above download [`./droid.sh`](./droid.sh) and put into the `Downloads/dev` folder of the host Android device, then create the following files on the Android device all under the `Downloads/dev` folder:

1. `Downloads/dev/TAILSCALE_KEY`: This should be the key used to connect to the tailnet, i.e., the one generated via the admin console.
2. `Downloads/dev/id_ed25519`: This should be your SSH private key.
3. `Downloads/dev/id_ed25519.pub`: This should be the corresponding SSH public key.

Finally, run the below within the Android Linux Terminal guest VM to set everything up:

```sh
$ bash /mnt/shared/dev/droid.sh --help
$ bash /mnt/shared/dev/droid.sh --verbose --install-nix
```

The above script---[`./droid.sh`](./droid.sh)---does many things but most notable are:

1. It installs Tailscale, so we can SSH into the VM on local network.
2. Install OpenSSH and makes it use port 1986 instead of the default 22.
3. Sets the hostname to `droid` so that on another machine---that has Tailscale installed---can issue the command `ssh -p 1986 droid@droid` to remote into the VM.
4. Optionally installs Nix the package manager, Home Manger and Rust, if `--install-nix` is passed in as a flag.

In the event that the VM does not appear in Tailscale, please execute `~/start-tailscale.sh` and wait for it appear again. You might need to run this each time the VM starts up, if and only if, you do not see it in your Tailscale. In running the script, you will find that duplicate machines with the name `driod` appear. Unfortunately, I could not find an _easy_ workaround for this.

#### Failed attempt to update Debian 13 (Trixie)

**This does not work at the moment.**

Most of the steps were taken from <https://datashelter.tech/blog/upgrade-debian-12-to-debian-13> with some adjustments:

```sh
sudo apt update -y
sudo apt upgrade -y
sudo apt full-upgrade -y
# sudo apt autoremove --purge -y
sudo cp -av /etc/apt/sources.list /etc/apt/sources.list.bak
sudo cp -av /etc/apt/sources.list.d /etc/apt/sources.list.d.bak
sudo sed -i 's/bookworm/trixie/g' /etc/apt/sources.list
sudo sed -i 's/bookworm/trixie/g' /etc/apt/sources.list.d/debian.sources
# Do the actual update now, then reboot if required.
sudo apt update -y
sudo apt upgrade -y
sudo apt full-upgrade -y
if [ -f /var/run/reboot-required ]; then sudo reboot; fi
```

### Screenshots

#### Final result

**Note:** You are able to access the host device at `/mnt/shared`.

![image-00.jpg](./image-00.jpg)

#### Disk resize

![image-01.jpg](./image-01.jpg)

#### Assigned ports

![image-02.jpg](./image-02.jpg)

## Issues found or questions I have

I have a huge lists of TODOs so I can't document everything I've found so far but below are some:

1. Without a rooted phone how does one go about debugging issues?
2. Sometime the VM randomly terminates in a middle of a, I think, a command that consumes a lot of IO.
3. Without using Tailscale, or a similar technology, I cannot directly SSH into the VM from within the same network. I can obviously ping the VM from the host Android phone from within Termux without a problem. I don't want to have to setup an additional piece of software just to forward to the guest VM, that's rather annoying.

Again, I would love to hear back from people using this and how they've overcome the issues they are facing.

Thanks for reading,
\- Bana
