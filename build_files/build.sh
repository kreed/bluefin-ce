#!/bin/bash

set -ouex pipefail

### Install packages

dnf5 install -y neovim git-delta

dnf5 install -y gnome-shell-extension-dash-to-panel
dnf5 remove -y gnome-shell-extension-dash-to-dock gnome-shell-extension-logo-menu

dnf5 -y copr enable kreed/kernel-sandbox
dnf5 -y versionlock delete kernel kernel-devel kernel-devel-matched kernel-core kernel-modules kernel-modules-core kernel-modules-extra
dnf5 -y remove kmod-framework-laptop kmod-openrazer kmod-kvmfr kmod-v4l2loopback
dnf5 -y update kernel\*
dnf5 -y copr disable kreed/kernel-sandbox

### Cleanup
rm -rf /var/lib/dnf
