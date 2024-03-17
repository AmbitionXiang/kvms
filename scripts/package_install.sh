#!/bin/bash

apt-get install -y git-core gnupg flex bison \
build-essential zip curl zlib1g-dev \
x11proto-core-dev libx11-dev libgl1-mesa-dev libxml2-utils \
xsltproc unzip fontconfig pip build-essential make ninja-build \
bsdmainutils libdrm-dev libegl-dev libegl1-mesa-dev libelf-dev \
libexpat1-dev libgl-dev libgles-dev libglib2.0-dev libglib2.0-dev-bin \
libglu1-mesa-dev libglvnd-core-dev libglx-dev libgmp-dev libice-dev \
libmagic-dev libmpc-dev libmpfr-dev libpcre3-dev libpcre2-dev \
libpixman-1-dev libpng-dev libpopt-dev libpulse-dev libsdl1.2-dev \
libsdl2-dev libspice-protocol-dev libspice-server-dev libwayland-dev \
libxau-dev libxinerama-dev libxrandr-dev linux-libc-dev xtrans-dev \
libssl-dev git texi2html texinfo rsync gawk bc python2 sudo wget qemu \
binfmt-support qemu-user-static libx11-xcb1 libx11-6 libxkbcommon0 \
libxkbcommon-x11-0 libvulkan-dev libvulkan1 libvdeplug2 libepoxy0 \
libvirglrenderer1 meson python3-mako python-is-python3 libxdamage-dev \
libxcb-glx0-dev libx11-xcb-dev libxcb-dri2-0-dev libxcb-dri3-dev \
libxcb-present-dev libxshmfence-dev llvm libvirglrenderer-dev \
libaio-dev libepoxy-dev wayland-protocols libwayland-egl-backend-dev \
net-tools iputils-ping iproute2 gdb-multiarch sshpass \
device-tree-compiler glslang-tools libxcb-shm0-dev doxygen graphviz \
texlive-latex-base texlive-fonts-recommended texlive-latex-extra kmod \
qemu-utils parted cpio xxd zstd udev dwarves libgtk-3-dev libncurses5 kpartx

pip install absl-py && pip install urlfetch

curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
source "$HOME/.cargo/env"
cargo install cargo-binutils
rustup component add llvm-tools-preview
cd /tmp && git clone https://github.com/eqrion/cbindgen.git
cargo install --force cbindgen
