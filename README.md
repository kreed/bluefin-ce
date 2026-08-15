# Bluefin Cursed Edition

This builds on top of [Bluefin DX](https://github.com/ublue-os/bluefin) with a handful of personal tweaks:

- Remove the bluefin logo from plymouth
- Add an empty /nix mountpoint for the Determinate Nix installer
- Add Wine
- Add a USB HID quirk for the affected device

More (or maybe less) to come in the future.

This project was generated from the Universal Blue
[image-template](https://github.com/ublue-os/image-template). See its
[development documentation](https://github.com/ublue-os/image-template#repository-contents)
for details about the build system and local development commands.

# Installation

Install Bluefin from [upstream](https://projectbluefin.io/). bluefin-ce currently only builds an x86_64 AMD/Intel image so make sure you choose this variant.

Then rebase to bluefin-ce:
```bash
sudo bootc switch --enforce-container-sigpolicy ghcr.io/kreed/bluefin-ce:latest
```
