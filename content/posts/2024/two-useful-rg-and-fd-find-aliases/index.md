---
title: "Two useful `rg` and `fd` aliases"
description: "Often needed parameters to these useful tools."
date: 2024-10-01
# slug: two-useful-rg-and-fd-find-aliases
tags:
  - utils
  - rust
  - grep
  - find
  - Linux
type: blog
---

Often when searching you want to exclude certain directories. If you are using `ripgrep` and `fd` (tools written in Rust), you can exclude directories by doing something like this:

```bash
alias rg='rg --no-follow --glob "!{/proc,/sys,$(go env GOPATH),**/.git/*}"'
alias fd='fd --exclude /proc --exclude /sys --exclude $(go env GOPATH)'
```

Remember to add `--hidden` to both aliases if you want to search for hidden files.