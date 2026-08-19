# DNS over QUIC

Public DNS queries are sent to Quad9's threat-blocking service over strict DNS
over QUIC. Network-specific domains supplied by NetworkManager, such as `lan`
and VPN search domains, continue to use their per-link resolvers.

The local proxy keeps a bounded 4 MiB DNS cache and coalesces duplicate pending
queries. This reduces unnecessary upstream traffic and concurrent DoQ streams
while preserving the TTLs returned by Quad9.

The temporary manual bypass returns public DNS to the active network's
resolver. It is cleared automatically at reboot:

```bash
quad9ctl status
sudo quad9ctl disable
sudo quad9ctl enable
```

## ECS carve-outs

Queries go to Quad9's ECS-stripped service by default, so no part of your
address reaches authoritative servers. The trade-off is that DNS-based geo
routing sees the Quad9 anycast node instead of you, and latency-routed records
can answer with a POP on the wrong continent.

Individual domains can opt in to Quad9's ECS-enabled service, which forwards
your address truncated to a /24. Malware blocking and DNSSEC are identical on
both; only subnet privacy differs, and only for the domains listed:

```bash
quad9ctl ecs list
sudo quad9ctl ecs add corp.amazon.com
sudo quad9ctl ecs remove corp.amazon.com
```

Nothing is carved out by default, and nothing is shipped to configure it:
`quad9ctl` writes `/etc/dnsproxy/ecs.env` when the first carve-out is added and
removes it again with the last. The service reads that path optionally, so its
absence simply contributes no upstream argument.

They only help where the authoritative honours ECS from any resolver. Akamai
restricts it to an allowlist of resolver operators, and Cloudflare and Fastly
are anycast and ignore it, so carve-outs for domains they front do nothing.
Confirm one is worth keeping by comparing a few rounds of:

```bash
dig +short @9.9.9.9 <host>    # ECS stripped
dig +short @9.9.9.11 <host>   # ECS forwarded
```
