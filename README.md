# Bluefin Cursed Edition

This builds on top of [Bluefin](https://github.com/ublue-os/bluefin) with a handful of personal tweaks:

- Remove the bluefin logo from plymouth
- Add an empty /nix mountpoint for the Determinate Nix installer
- Resolve public DNS through Quad9 using DNS over QUIC

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

## DNS over QUIC

Public DNS queries are sent to Quad9's threat-blocking service over strict DNS
over QUIC. Network-specific domains supplied by NetworkManager, such as `lan`
and VPN search domains, continue to use their per-link resolvers.

The local proxy keeps a bounded 4 MiB DNS cache and coalesces duplicate pending
queries. This reduces unnecessary upstream traffic and concurrent DoQ streams
while preserving the TTLs returned by Quad9.

The temporary manual bypass returns public DNS to the active network's
resolver. It is cleared automatically at reboot:

```bash
quad9-doq status
sudo quad9-doq disable
sudo quad9-doq enable
```
