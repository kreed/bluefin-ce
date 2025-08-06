#!/bin/bash

set -ouex pipefail

### Install packages

dnf5 install -y neovim git-delta

dnf5 install -y gnome-shell-extension-dash-to-panel
dnf5 remove -y gnome-shell-extension-dash-to-dock gnome-shell-extension-logo-menu

# hide bluefin logo in plymouth
rm /usr/share/plymouth/themes/spinner/*watermark.png

# rebuild initramfs
QUALIFIED_KERNEL="$(rpm -qa | grep -P 'kernel-(\d+\.\d+\.\d+)' | sed -E 's/kernel-//')"
/usr/bin/dracut --no-hostonly --kver "$QUALIFIED_KERNEL" --reproducible -v --add ostree -f "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"
chmod 0600 "/lib/modules/$QUALIFIED_KERNEL/initramfs.img"

### Cleanup

rm -r /var/lib/dnf
