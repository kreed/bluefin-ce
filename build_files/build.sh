#!/bin/bash

set -ouex pipefail

### Install packages

dnf5 install -y cargo neovim

dnf5 install -y gnome-shell-extension-dash-to-panel
dnf5 remove -y gnome-shell-extension-dash-to-dock gnome-shell-extension-logo-menu

