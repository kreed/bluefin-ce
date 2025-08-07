# Bluefin Cursed Edition

This builds on top of [bluefin-latest](https://github.com/ublue-os/bluefin) with a handful of personal tweaks:

- Remove the bluefin logo from plymouth
- Add neovim and git-delta
- Swap out some gnome shell extensions (drop dash to dock and logo menu, add dash to panel)

More (or maybe less) to come in the future.

# Installation

Install Bluefin from [upstream](https://projectbluefin.io/). bluefin-ce currently only builds an x86_64 AMD/Intel image so make sure you choose this variant.

Then rebase to bluefin-ce:
```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/kreed/bluefin-ce:latest
```
