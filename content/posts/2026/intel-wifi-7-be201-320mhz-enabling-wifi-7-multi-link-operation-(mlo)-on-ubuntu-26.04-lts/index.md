---
title: "Intel Wi-Fi 7 BE201 320MHz: Enabling Wi-Fi 7 Multi-Link Operation (MLO) on Ubuntu 26.04 LTS"
description: "Connecting to a SSID/access point that supports MLO and as advertised by the `Banana Pi BPI-R4 Pro 4E` on Ubuntu 26.04 LTS only works on `wpa_supplicant@v2.12` or above."
date: 2026-08-15
tags:
  - Router
  - Linux
  - OpenWRT
  - Banana Pi
  - WiFi
type: blog
---

## Introduction

I thought this should work out of the box on Linux since it works out of the box on Windows 11, but it doesn't. One needs to compile and use `wpa_supplicant@v2.12`, otherwise it will fail to connect to to the MLO-enabled SSID/access point.

You can see the forum posts I made on certain good forums at [^3] [^4].

## Notes

1. I would strongly suggest that you do *NOT* try to update the firmware or use a custom-built Linux kernel unless you have tried the steps below and they fail even after rebooting, despite what [^1] [^2] might suggest.
2. You do *NOT* need to set the regulatory domain (e.g. `cfg80211.ieee80211_regdom=GB`) for this to work.
3. The instructions at [^1] suggest using <https://w1.fi/releases/wpa_supplicant-2.11.tar.gz> but this is already shipped with Ubuntu 26.04 LTS and that simply does not work, hence this blog post.

## Compile and install `wpa_supplicant`

Obtain all the dependencies:

```sh
sudo apt install libnl-3-200 libnl-3-200 libdbus-1-3 libdbus-1-dev libnl-genl-3-dev libssl-dev openssl build-essential pkg-config libnl-3-dev libnl-genl-3-dev libdbus-1-dev libssl-dev libreadline-dev libpcsclite-dev git build-essential pkg-config libnl-3-dev libnl-genl-3-dev libdbus-1-dev libssl-dev libreadline-dev libpcsclite-dev git libnl-route-3-dev
```

Begin building it:

```sh
mkdir ~/linux
cd ~/linux
wget https://w1.fi/releases/wpa_supplicant-2.12.tar.gz
tar xf wpa_supplicant-2.12.tar.gz
cd wpa_supplicant-2.12/wpa_supplicant
cp defconfig .config
echo "
CONFIG_DRIVER_NL80211=y
CONFIG_CTRL_IFACE=y
CONFIG_DBUS=y
CONFIG_CTRL_IFACE_DBUS_NEW=y
CONFIG_CTRL_IFACE_DBUS_INTRO=y
CONFIG_TLS=openssl
CONFIG_SAE=y
CONFIG_READLINE=y
" >> .config
cd ..
make
```

Install it:

```sh
sudo make install
sudo mv /usr/sbin/wpa_supplicant /usr/sbin/wpa_supplicant.distro
sudo ln -s /usr/local/sbin/wpa_supplicant /usr/sbin/wpa_supplicant
sudo pkill wpa_supplicant
sudo systemctl restart NetworkManager
```

Verify the below returns `/usr/local/sbin/wpa_supplicant`:

```sh
pidof wpa_supplicant
sudo readlink -f /proc/$(pidof wpa_supplicant)/exe
```

## Verify

1. Connect to the MLO-enabled SSID.
2. Run the command below and you should see similar output - you are expecting to see `MLD with links` in the output:

```sh
iw dev
phy#10
	Unnamed/non-netdev interface
		wdev 0xa00000003
		addr c0:a8:10:f4:5d:3b
		type P2P-device
	Interface wlan
		ifindex 15
		wdev 0xa00000001
		addr c0:a8:10:f4:5d:3a
		ssid 12-Rochford-Close_E6-1QR
		type managed
		multicast TXQ:
			qsz-byt	qsz-pkt	flows	drops	marks	overlmt	hashcol	tx-bytes	tx-packets
			0	0	0	0	0	0	0	0		0
		MLD with links:
		 - link ID  2 link addr aa:0b:b4:55:ad:1d
		   channel 37 (6135 MHz), width: 320 MHz, center1: 6105 MHz
		   txpower 22.00 dBm
```

Thanks for reading and good luck.

[^1]: <https://support.excentis.com/knowledge/article/1005>.
[^2]: <https://support.excentis.com/knowledge/article/1004>.
[^3]: <https://forum.level1techs.com/t/how-to-enable-wi-fi-7-multi-link-operation-mlo-on-ubuntu-or-linux-for-intel-be201>.
[^4]: <https://discussion.fedoraproject.org/t/how-to-enable-wi-fi-7-multi-link-operation-mlo-on-linux-for-intel-be201>.
