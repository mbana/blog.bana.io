---
title: "Galaxy S26 Ultra (SM-S948B): Local Privilege Escalation"
description: "This post details how to get `root` on newer Samsung phones where unlocking the bootloader is no longer an option."
date: 2026-09-01
tags:
  - Android
  - Linux
  - Samsung
  - Exploit
  - LPE
  - root
type: blog
---

## Introduction

**WIP:** Place-holder blog post which I will complete in due course.

Getting `root` on newer Samsung devices is no longer easy since Samsung have removed the option to unlock the bootloader, however there are ways around this.

## Device details

### Firmware

```
Android 16
Released: 7/2/2026

PDA: S948BXXS4AZG5
CSC: S948BOXM4AZG5
Country: EEA (Europe)
Region: EUX

Upload date: 7/2/2026
Package size: 22.5 GB (24177658339 bytes)
File name: EUX-S948BXXS4AZG5-20260702135802.zip
```

Download available at <https://www.sammobile.com/samsung/galaxy-s26-ultra/firmware/SM-S948B/EUX/download/S948BXXS4AZG5/1996077/> or using <https://samloader.com/>:

```sh
$ samloader download --model 'SM-S948B' --region 'EUX' --version 'S948BXXS4AZG5/S948BOXM4AZG5/S948BXXS4AZG5'
```
$(shell $(TARGET_CC) -print-file-name=libzstd.so)
You should find `SM-S948B_1_20260702135802_gcoaqtp276_fac.zip` in the current working directory.

### Kernel

```sh
Build: BP4A.251205.006.S948BXXS4AZG5
Build fingerprint: 'samsung/m3qxeea/m3q:16/BP4A.251205.006/S948BXXS4AZG5_OXM4AZG5:user/release-keys'
Bootloader: S948BXXS4AZG5
Radio: S948BXXS4AZG5,S948BXXS4AZG5
Network: ,O2 - UK
Module Metadata version: 371559000
Android SDK version: 36
SDK extensions: [ad_services=22, b=22, c=<not set>, r=22, s=22, t=22, u=22, v=22]
Kernel: Linux version 6.12.30-android16-5-pd30ff70-abogkiS948BXXS4AZG5-4k (kleaf@build-host) (Android (14043575, +pgo, +bolt, +lto, +mlgo, based on r536225) clang version 19.0.1 (https://android.googlesource.com/toolchain/llvm-project b3a530ec6537146650e42be89f1089e9a3588460), LLD 19.0.1) #1 SMP PREEMPT Thu Jul  2 00:16:21 UTC 2026
```

## Mandatory photos

## Quick Guide on becoming `root`

## The details

Thanks for reading and good luck.

[^1]: <>.