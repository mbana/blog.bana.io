---
title: "Envoy Proxy: Compiling on Fedora 38"
description: "It took me a while to get Envoy Proxy to compile natively on Fedora 38 so I am documenting it in order that I don't forget."
date: 2023-11-01
# slug: metallb-configuration-for-minikube
tags:
  - proxy
  - envoy
  - linux
type: blog
---

For some reason compiling Envoy Proxy was slighty harder or more complicated than I imagined so I thought I'd document the process.

## Installing Prerequisites

```sh
sudo dnf groupinstall -y "Development Tools"
sudo dnf update -y
sudo dnf install -y \
  aspell-en \
  binutils-gold \
  ccache \
  cmake \
  ncurses-compat-libs \
  ninja-build \
  python3-pip \
  jq \
  wget \
  curl \
  git \
  libcxx libcxx-devel \
  libatomic \
  libstdc++ \
  libstdc++-static \
  libtool \
  lld \
  patch \
  python3-pip
wget "https://github.com/llvm/llvm-project/releases/download/llvmorg-14.0.0/clang+llvm-11.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz"
mkdir ~/llvm
tar -xvf clang+llvm-11.0.1-x86_64-linux-gnu-ubuntu-16.04.tar.xz -C ~/llvm
~/llvm/clang+llvm-11.0.1-x86_64-linux-gnu-ubuntu-16.04/bin/llvm-config --version # Output: 11.0.1
```

Download Bazelisk\Bazel:

```sh
curl -Lo /tmp/bazelisk "https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-$([ $(uname -m) = "aarch64" ] && echo "arm64" || echo "amd64")"
chmod +x /tmp/bazelisk
sudo mkdir -pv /usr/local/bin
sudo install -o root -g root -m 0755 /tmp/bazelisk /usr/local/bin/bazel
export PATH="/usr/local/bin:${PATH}" # If required
bazel version # Output: Bazelisk version: v1.18.0
```

## Get Envoy Proxy source code

```sh
mkdir -pv ~/src
cd ~/src
git clone git@github.com:envoyproxy/envoy.git # Or https://github.com/envoyproxy/envoy.git
cd envoy
git checkout release/v1.23
```

## Compile Envoy Proxy

Configure it:

```sh
cd ~/src/envoy
export PATH="${HOME}/llvm/clang+llvm-11.0.1-x86_64-linux-gnu-ubuntu-16.04/bin:${PATH}"
bazel/setup_clang.sh ~/llvm/clang+llvm-11.0.1-x86_64-linux-gnu-ubuntu-16.04
echo "build --config=clang" > user.bazelrc
echo "build --config=libc++" >> user.bazelrc
echo "build --copt=-fno-limit-debug-info" >> user.bazelrc
```

Build it:

```sh
bazel build --jobs=64 -c fastbuild --verbose_failures --sandbox_debug --spawn_strategy=local //source/exe:envoy-static
```

## Run Envoy Proxy

```sh
$ bazel-bin/source/exe/envoy-static --version
bazel-bin/source/exe/envoy-static  version: 9689bc57f80fe56dbb16a4e0d632cde5363d1811/1.23.12/Clean/DEBUG/BoringSSL
```

## Run Tests

**TODO**.