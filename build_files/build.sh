#!/bin/bash

set -ouex pipefail

### Packages

INCLUDED_PACKAGES=(
  wine
  )

dnf5 -y install "${INCLUDED_PACKAGES[@]}"

### Plymouth

# remove logo
rm /usr/share/plymouth/themes/spinner/*watermark.png

# rebuild initramfs
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed -E 's/kernel-//')"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

### Nix

# Empty mountpoint for the Determinate installer's nix.mount; it can't be
# created at runtime on a composefs (read-only /) system. See
# https://github.com/DeterminateSystems/nix-installer/issues/1445
mkdir /nix

### Cleanup
dnf clean all
if [ -d /var/lib/dnf ]; then
    rm -r /var/lib/dnf
fi
