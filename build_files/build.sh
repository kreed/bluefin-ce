#!/bin/bash

set -ouex pipefail

### Install packages

dnf5 install -y cargo neovim git-delta

dnf5 install -y gnome-shell-extension-dash-to-panel
dnf5 remove -y gnome-shell-extension-dash-to-dock gnome-shell-extension-logo-menu

### Cleanup

rm -r /var/lib/dnf
