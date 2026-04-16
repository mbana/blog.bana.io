---
title: "Run Visual Studio Code as root on Linux"
description: "Run `code` as root on Linux"
date: 2025-05-01
# slug: firecracker-microvm
tags:
  - Linux
  - vscode
  - IDE
type: blog
---

Ever wanted to open a file as root on Linux with Visual Studio Code? Here’s the command to do so:

```sh
$ xhost +local: && sudo code --no-sandbox --user-data-dir=/root/.config/code /
```
