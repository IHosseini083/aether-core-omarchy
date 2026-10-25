# Zeptun System Routing Architecture & Limitations

Documentation for system-wide TUN redirection with the Zeptun engine (`v1.1.3`) and Aether core (`v2.4.0`).

---

## Overview

Zeptun creates a virtual TUN interface (`zeptun0`) and routes all operating system network traffic through Aether's local SOCKS5 proxy without requiring per-application proxy configurations.

### Key Capabilities in Zeptun v1.1.3
- **Async I/O Backend**: Automatic selection between high-throughput `io_uring` and classic Linux `epoll`.
- **Hardware Offload**: Checksum offloading, Generic Segmentation Offload (GSO), and Generic Receive Offload (GRO) on `zeptun0`.
- **Leak Protection (Strict Routing)**: Firewall policy routing blackholes untracked or unsupported address families (such as IPv6 when operating in IPv4-only mode) instead of leaking them unproxied over physical interfaces.
- **Fake-IP Engine**: Synthetic in-tunnel IP mapping for domains, eliminating local DNS resolution and ISP DNS poisoning.
- **Port 53 Hijack**: Intercepts all UDP/TCP port 53 DNS queries system-wide and routes them through the in-tunnel resolver.

---

## Routing Architecture & Loopback Protection

To route all system traffic into `zeptun0` without causing an infinite network loop (where the core's own outbound connection is captured back into the tunnel), Zeptun uses Linux policy routing and firewall marks.

```
+---------------------------------------------------------------+
| User Applications (Browsers, CLI, Games, Daemons)            |
+---------------------------------------------------------------+
                               |
                               v
                     +-------------------+
                     | Interface zeptun0 |
                     +-------------------+
                               |
                               v
                   +-----------------------+
                   |     Zeptun Engine     |
                   |  (tun2socks userspace)|
                   +-----------------------+
                               | SOCKS5 (127.0.0.1:1819)
                               v
                   +-----------------------+
                   |      Aether Core      |
                   +-----------------------+
                               | Outbound Sockets (SO_MARK 0xff)
                               v
                   +-----------------------+
                   |  Linux Policy Routing |
                   |  (Rule: fwmark 0xff   |
                   |   lookup main bypass) |
                   +-----------------------+
                               |
                               v
            +------------------------------------+
            | Physical Interface (eth0 / wlan0)  |
            +------------------------------------+
```

### The `SO_MARK 0xff` Guard
1. Aether attaches socket option `SO_MARK 0xff` to all its upstream outbound sockets when `--mark 0xff` is passed.
2. Zeptun configures an `ip rule`:
   ```sh
   ip rule add fwmark 0xff lookup main priority 9000
   ```
3. Outbound packets with mark `0xff` bypass the `zeptun0` routing table and exit directly via the default gateway on the physical interface (`wlan0` / `eth0`).
4. All unmarked packets match the lower priority rule directing traffic into `zeptun0`.

---

## Tor & Psiphon TUN Limitations

When using multi-hop circumvention protocols (`protocol=tor`, `protocol=psiphon`, or egress targeting Tor/Psiphon), two critical networking constraints arise.

### 1. The Child Process Loopback Problem

#### Problem
Aether spawns helper binaries for multi-hop circumvention:
- Tor pluggable transports (`lyrebird`, `obfs4proxy`, `snowflake-client`)
- Psiphon core daemon (`psiphon-tunnel-core`)

Under Linux, socket options like `SO_MARK` are socket-specific and are **not** inherited by child processes across `execve()` calls. As a result, the outbound TCP/UDP connections opened by `psiphon-tunnel-core` or `lyrebird` do not carry `fwmark 0xff`.

When system routing is active, the Linux kernel sees these unmarked helper sockets as normal user traffic and routes them straight into `zeptun0`. This creates an immediate routing loop:
1. Helper tries to reach external bridge or CDN fronting server.
2. Kernel routes helper packet into `zeptun0`.
3. Zeptun forwards packet to Aether SOCKS5.
4. Aether asks helper to establish the connection.
5. The connection stalls, times out, or crashes with loopback saturation.

#### Mitigation Strategies
- **UID / Group Exclusion (Recommended)**: Run helper daemons or specific system users under an excluded Linux UID. In `Panel.qml` (Routing tab) or `bin/aether-ctl`:
  ```sh
  bin/aether-ctl set sysroute_exclude_uids "1001"
  ```
  Zeptun adds an `ip rule` matching the UID to bypass the TUN device entirely.
- **Subnet Exclusion**: If upstream bridges or CDN IPs are static, exclude their CIDR blocks:
  ```sh
  bin/aether-ctl set sysroute_exclude "198.51.100.0/24,203.0.113.0/24"
  ```
- **Panel 1-Click Fix**: The UI detects Tor or Psiphon egress and displays a warning card with an automated mitigation button.

---

### 2. UDP ASSOCIATE Incompatibility

#### Problem
Standard SOCKS5 supports UDP datagram relay through the `UDP ASSOCIATE` command (RFC 1928). However:
- **Tor SOCKS5 proxy** does not support `UDP ASSOCIATE` by design. Tor is strictly an onion-routed TCP circuit network.
- **Psiphon SOCKS5 core** does not implement `UDP ASSOCIATE` over its tunneled proxy endpoints.

When system routing runs over Tor or Psiphon, any native UDP traffic directed into `zeptun0` fails:
- Native DNS queries to external UDP port 53 are dropped or refused.
- QUIC and HTTP/3 web connections stall and fail.
- UDP voice (Discord, VoIP), gaming, and torrent traffic cannot establish connections.

#### Mitigation Configuration
To achieve seamless browsing across Tor or Psiphon with Zeptun active, apply the following two configuration rules:

1. **Enable Fake-IP (`sysroute_fake_ip=1`)**:
   - Zeptun maps domain names to synthetic IP addresses (`198.18.0.0/15`).
   - When an application connects to a Fake-IP address, Zeptun extracts the original hostname and asks the SOCKS5 proxy to dial the target domain using standard TCP `CONNECT`.
   - Local UDP DNS queries are completely eliminated.

2. **Set UDP Mode to TCP (`sysroute_udp_mode=tcp`)**:
   - Zeptun encapsulates outgoing UDP datagrams into TCP SOCKS5 streams or discards unresolvable UDP gracefully rather than hanging the network stack.

3. **Browser HTTP/3 (QUIC) Adjustment**:
   - When routing system-wide through Tor or Psiphon, disable QUIC in the web browser (e.g. `chrome://flags/#enable-quic` -> Disabled, or Firefox `network.http.http3.enable` -> `false`). This forces all web requests onto TCP-based HTTP/2 and HTTP/1.1, preventing connection hangs.
