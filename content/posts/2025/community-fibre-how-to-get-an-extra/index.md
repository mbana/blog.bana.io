---
title: "Community Fibre: How to get an extra ~123Mbps increase in download and upload speed"
description: "Bypassing the ISP issued ONT by using an SFP+ module that has 8311 Firmware."
date: 2025-11-01
# slug: firecracker-microvm
tags:
  - linux
  - ont
  - fibre
  - Community Fibre
type: blog
---

## Introduction

First thing’s first, big shout out to Community Fibre for providing me with (a business plan) GIGAFAST 1 Gbps package. Superb team and support! 10/10 so far. The average speed is advertised at 920 Mpbs, as below:

This is if you decide to use their equipment, which are:

1. A ADTRAN-SDX-631q for the ONT.
1. A Technicolor Dual-Band WiFi 6 (FGA5330) for the router.

If you decide to make matters into your own hands and decide you don’t need of any this and want to get the fibre direct to your PC, like what I did, it’s possible but you’ll need some equipment. Let’s start with that then. Any of the below should work as I’ve tested out both SFP+ sticks but I do prefer the pricing of the stick by Better Internet.

## XGSPON ONU Stick SFP+ Compatible 8311 Firmware

1. <https://store.betterinternet.ltd/product/x-onu-sfpp>: Great pricing but instructions could/should be as good as the one below by FiberMall. Although in all fairness Better Internet do offer to put in your ONT serial for so you don’t have to mess around with the configuration GUI.
1. <https://www.amazon.co.uk/dp/B0F2TBB4TD?ref=ppx_yo2ov_dt_b_fed_asin_title>, which I believe is effectively this, <https://www.fibermall.com/sale-462134-xgspon-onu-sfp-stick-i-temp.htm>: I don’t like the pricing on it but the instructions, in all fairness, are good.

### Configure your stick

1. Get your ISP issued ONT and get the serial number at the back of it and take note of it. It’s case sensitive. If it is like mine, it should be something like `ADTN25057FA8`. We’ll need this later on when we’re configuring the stick.
1. Insert the module into an SFP cage.
1. Assign the IP address of `192.168.11.2` to yourself. Since I am using Linux, the appropriate command to run is `ip address add 192.168.11.2/24 dev sfp0` as `root`, replacing `sfp0` with the correct device name, and you may also need to run `ip address flush dev sfp0 scope global`, again as `root`. Shortly after this, you should be receiving pings from `192.168.11.1` and should also be able to ping `192.168.11.1`. Wait a minute or then to and go to <https://192.168.11.1> or <http://192.168.11.1>. You should be greeted with a login page, the credentials of which depend on who supplied you the SFP stick.
1. Click on 8311 then Configuration. Enter the ONT serial number you gathered in step #1 as-is without modification. Do not make any further changes. As an example, all I had to do in my case was enter `ADTN25057FA8` under PON Serial Number (ONT ID), and hit save, then reboot.
1. Once it’s reboot under `PON Status` ensure that you see `O5.1, Associated state` there. It’s an indicator that it has established a connection with the OLT.
1. If you are on dynamic IP address plan, you should be all good to go. If you’re on the static plans, there’s some more manual configuration required. I’ll leave it to the reader as a exercise. If you can’t figure it out, just join the Discord channel and I’ll try to help you get working.

## Links

1. [8311 Community Firmware MOD](https://github.com/djGrrr/8311-was-110-firmware-builder) by [djGrrr](https://github.com/djGrrr)
1. [8311 Community Discord Server](https://discord.com/servers/8311-886329492438671420)
1. [https://pon.wiki/](https://pon.wiki/)
