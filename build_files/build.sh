#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Packages

dnf5 -y copr enable kreed/bluefin-ce

INCLUDED_PACKAGES=(
  dnsproxy
  plymouth-plugin-script
  )

dnf5 -y install "${INCLUDED_PACKAGES[@]}"
dnf5 -y copr disable kreed/bluefin-ce

### dconf

# Compile /etc/dconf/db/*.d/ overrides shipped in system_files/
dconf update

### Plymouth

# Install the framework-penguin theme (tracked as a git submodule) and set it
# as the default. -R is omitted because the initramfs is rebuilt explicitly below.
install -d /usr/share/plymouth/themes/framework-penguin
cp -a /ctx/framework-penguin/. /usr/share/plymouth/themes/framework-penguin/
rm -rf /usr/share/plymouth/themes/framework-penguin/.git \
       /usr/share/plymouth/themes/framework-penguin/README.md \
       /usr/share/plymouth/themes/framework-penguin/penguin-anim.gif
plymouth-set-default-theme framework-penguin

# Drop the Fedora logo watermark from the stock themes (fallbacks)
rm -f /usr/share/plymouth/themes/*/watermark.png

# rebuild initramfs
KERNEL_SUFFIX=""
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(|'"$KERNEL_SUFFIX"'-)(\d+\.\d+\.\d+)' | sed -E 's/kernel-(|'"$KERNEL_SUFFIX"'-)//')"
export DRACUT_NO_XATTR=1
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

### Nix

# Empty mountpoint for the Determinate installer's nix.mount; it can't be
# created at runtime on a composefs (read-only /) system. See
# https://github.com/DeterminateSystems/nix-installer/issues/1445
mkdir /nix
