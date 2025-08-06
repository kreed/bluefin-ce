#!/bin/bash

set -ouex pipefail

### Install packages

dnf5 install -y neovim git-delta

dnf5 install -y gnome-shell-extension-dash-to-panel
dnf5 remove -y gnome-shell-extension-dash-to-dock gnome-shell-extension-logo-menu

# hide bluefin logo in plymouth
rm /usr/share/plymouth/themes/spinner/*watermark.png

### Cleanup

rm -r /var/lib/dnf
