#!/bin/bash

set -ouex pipefail

### Install packages

dnf5 install -y cargo neovim
