#!/bin/bash

set -ouex pipefail

### Packages

INCLUDED_PACKAGES=(
  gnome-shell-extension-dash-to-panel
  )

EXCLUDED_PACKAGES=(
  gnome-shell-extension-apps-menu
  gnome-shell-extension-dash-to-dock
  gnome-shell-extension-logo-menu
  gnome-shell-extension-places-menu
  gnome-shell-extension-window-list
  )

dnf5 -y install "${INCLUDED_PACKAGES[@]}"

readarray -t EXCLUDED_PACKAGES < <(rpm -qa --queryformat='%{NAME}\n' "${EXCLUDED_PACKAGES[@]}")

# remove any excluded packages which are still present on image
if [[ "${#EXCLUDED_PACKAGES[@]}" -gt 0 ]]; then
    dnf5 -y remove "${EXCLUDED_PACKAGES[@]}"
else
    echo "No packages to remove."
fi

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
rm -r /var/lib/dnf
