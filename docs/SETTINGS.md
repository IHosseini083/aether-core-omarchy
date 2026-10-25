# Aether Settings Reference

Complete configuration schema, category breakdown, presets, and CLI keys for the `cluvex.aether` Omarchy plugin (Aether core `v2.4.0`, Zeptun `v1.1.3`).

---

## Architecture Overview

All user configuration is managed centrally and persisted across shell restarts and system reboots:

1. **Storage**: `~/.config/omarchy-aether/config.env` (permissions `0600`).
2. **Schema Definition**: `Model.js` (`SCHEMA` dictionary) defines key types, categories, defaults, labels, descriptions, and whether the setting is basic or advanced.
3. **Execution & Control**: `bin/aether-ctl` translates key-value pairs into upstream CLI arguments, validates formats, triggers hot-restarts when running, and executes atomic presets.
4. **UI Browser**: The popup panel's **Settings** tab features live search across all 97 settings, Basic/Advanced view modes, dynamic "Modified (N)" filtering chips, active preset detection, full configuration export/import backup actions, and per-setting and global reset capabilities.

---

## Configuration Presets

Presets configure multiple transport, obfuscation, and routing parameters in a single atomic operation via `bin/aether-ctl preset <name>`:

| Preset Name | Target Use Case | Key Configuration Applied |
| :--- | :--- | :--- |
| `default` | Standard reliable WARP | `protocol=masque`, `h2=0`, `scan=balanced`, `noize=firewall`, `fragment=0`, `ech=off`, `ip=v4` |
| `stealth` | Heavy DPI / SNI blocking environments | `protocol=masque`, `h2=1`, `scan=balanced`, `noize=firewall`, `fragment=1`, `fragment_size=8-16`, `fragment_delay=2-10`, `ech=auto`, `enable_ech_grease=1` |
| `speed` | Low-latency streaming and high throughput | `protocol=masque`, `h2=0`, `scan=turbo`, `noize=light`, `fragment=0`, `sysroute_udp_mode=udp`, `sysroute_congestion=cubic` |
| `tor_multihop` | Onion routing layered over WARP | `protocol=tor`, `tor_relays=auto`, `tor_relay_ports=web`, `tor_bridges=""` |
| `psiphon_bypass` | CDN-fronted multi-hop egress | `protocol=psiphon`, `psiphon_mode=auto`, `psiphon_region=""` |

---

## Settings Directory by Category

### 1. Core & Engine

Manages binary selection, process monitoring, timing deadlines, and hardware marking.

| Key | CLI Argument / Environment | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `bin` | Active binary path | `string` | *(auto-discover)* | Override path to Aether core binary. |
| `protocol` | `--protocol <name>` | `choice` | `masque` | Primary transport protocol (`masque`, `wg`, `gool`, `gool-classic`, `mim`, `tor`, `tor-reverse`, `tor-only`, `psiphon`, `psiphon-reverse`, `psiphon-only`). |
| `scan` | `--scan <strategy>` | `choice` | `balanced` | Gateway discovery scan strategy (`balanced`, `turbo`, `verified`, `thorough`, `ironclad`). |
| `noize` | `--noize <profile>` | `choice` | `firewall` | Obfuscation noise profile (`firewall`, `balanced`, `light`, `gfw`, `aggressive`, `off`). |
| `h2` | `--h2` | `bool` | `0` *(false)* | Use TCP-based HTTP/2 for MASQUE instead of HTTP/3 (QUIC). |
| `perf` | `--perf <low\|medium\|high>` | `choice` | `""` *(auto)* | Resource profile adapting buffer and memory allocations. |
| `log_level` | `--log-level <level>` | `choice` | `info` | Core log verbosity (`error`, `warn`, `info`, `debug`, `trace`). |
| `quick_reconnect` | `--quick-reconnect` / `--no-quick-reconnect` | `bool` | `1` *(true)* | Fast-resume connection using the last verified gateway. |
| `no_data_check` | `--no-data-check` | `bool` | `0` *(false)* | Skip HTTP data-plane probe during connection establishment. |
| `no_profile_retry` | `--no-profile-retry` | `bool` | `0` *(false)* | Do not retry other noise/padding profiles if connection fails. |
| `mark` | `--mark 0xff` | `bool` | `0` *(false)* | Attach `SO_MARK 0xff` firewall mark (requires `CAP_NET_ADMIN`). |
| `keepalive` | `--keepalive <secs>` | `int` | `5` | WireGuard keepalive interval in seconds. |
| `validate_secs` | `--validate-secs <secs>` | `int` | `""` | Data-plane validation probe timeout. |
| `startup_secs` | `--startup-secs <secs>` | `int` | `""` | MASQUE initial connection deadline. |
| `reconnect_secs` | `--reconnect-secs <secs>` | `int` | `""` | Reconnect delay backoff after failure. |
| `exit_loc_secs` | `--exit-loc-secs <secs>` | `int` | `60` | Periodic exit location verification interval. |
| `stats` | `--stats` | `bool` | `0` *(false)* | Periodically log bandwidth upload/download totals and uptime. |
| `stats_secs` | `--stats-secs <secs>` | `int` | `15` | Interval in seconds between traffic statistics log entries. |
| `extra_args` | *(appended verbatim)* | `string` | `""` | Arbitrary CLI flags passed directly to core on startup. |

---

### 2. Network & Ports

Network protocol, port bindings, DNS resolvers, static peers, and direct routing bypass rules.

| Key | CLI Argument / Environment | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `ip` | `-4`, `-6`, `--dual` | `choice` | `v4` | Internet Protocol version (`v4`, `v6`, `dual`). |
| `socks_port` | `--bind 127.0.0.1:<port>` | `int` | `1819` | Local SOCKS5 proxy port. |
| `http_proxy_port` | `--http-proxy <port>` | `int` | `0` *(off)* | Local HTTP CONNECT proxy port. |
| `dns` | `--dns <list>` | `string` | `""` | Custom tunnel DNS resolvers (comma-separated). |
| `upstream` | `--upstream <url>` | `string` | `""` | Upstream proxy URL to chain tunnel traffic through. |
| `routes_file` | `--routes <path>` | `string` | `""` | File containing route table specifications. |
| `route_block` | `--route-block <list>` | `string` | `""` | Destinations blocked from reaching the tunnel. |
| `route_direct` | `--route-direct <list>` | `string` | `""` | Destinations routed directly, bypassing the tunnel. |
| `peer` | `--peer <ip:port>` | `string` | `""` | Static gateway endpoint IP:port override. |
| `wg_peer` | `--wg-peer <ip:port>` | `string` | `""` | Static WireGuard endpoint IP:port override. |
| `gool_peer` | `--gool-peer <ip:port>` | `string` | `""` | Static Gool endpoint IP:port override. |
| `h2_peer` | `--h2-peer <ip:port>` | `string` | `""` | Static HTTP/2 endpoint IP:port override. |
| `wiw_outer` | `--wiw-outer <ip:port>` | `string` | `""` | WireGuard-in-WireGuard outer hop endpoint. |
| `wiw_inner` | `--wiw-inner <ip:port>` | `string` | `""` | WireGuard-in-WireGuard inner hop endpoint. |
| `mim_outer` | `--mim-outer <ip:port>` | `string` | `""` | MASQUE-in-MASQUE outer hop endpoint. |
| `mim_inner` | `--mim-inner <ip:port>` | `string` | `""` | MASQUE-in-MASQUE inner hop endpoint. |
| `no_profile_retry` | `--no-profile-retry` | `bool` | `0` | Prevent retrying alternate WireGuard obfuscation profiles. |

---

### 3. TLS 1.3 & Fingerprint Evasion (Core v2.4.0)

Fine-grained control over TLS 1.3 ClientHello records, cipher suites, signature algorithms, and extensions to evade deep packet inspection (DPI).

> **Note on Upstream v2.4.0 Changes**: Flags `--no-fragment` and `--api-fragment` have been removed in v2.4.0. Fragmentation is explicitly toggled via `--fragment` (or omitted when off).

| Key | CLI Argument / Environment | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `fragment` | `--fragment` | `bool` | `0` *(false)* | Fragment TLS ClientHello across TCP records to bypass DPI. |
| `fragment_size` | `--fragment-size <min-max>` | `string` | `8-16` | Range of fragment byte sizes (e.g. `8-16` or `16-32`). |
| `fragment_delay` | `--fragment-delay <min-max>`| `string` | `2-10` | Inter-packet delay range in milliseconds. |
| `ech` | `--ech <off\|auto>` | `choice` | `off` | Encrypted Client Hello negotiation mode. |
| `ech_dns` | `--ech-dns <url>` | `string` | `""` | Custom DoH resolver URL for ECH configuration fetch. |
| `ech_domain` | `--ech-domain <domain>` | `string` | `""` | Outer public domain name used during ECH negotiation. |
| `enable_ech_grease` | `--enable-ech-grease` | `bool` | `0` *(false)* | Inject synthetic ECH GREASE extension when ECH is off. |
| `tls_verify` | `AETHER_TLS_VERIFY=<0\|1>` / `--tls-verify` | `choice` | `auto` | TLS certificate verification policy (`auto`, `1`, `0`). |
| `tls13_ciphers` | `--tls13-ciphers <list>` | `string` | `""` | Colon-separated TLS 1.3 cipher suite list. |
| `tls_ciphers` | `--tls-ciphers <list>` | `string` | `""` | Colon-separated TLS 1.2 cipher suite list. |
| `tls_groups` | `--tls-groups <list>` | `string` | `""` | Supported elliptic curve groups (e.g. `X25519:P-256`). |
| `tls_key_shares` | `--tls-key-shares <list>` | `string` | `""` | TLS 1.3 key share groups offered in ClientHello. |
| `tls_sigalgs` | `--tls-sigalgs <list>` | `string` | `""` | Allowed signature algorithms list. |
| `enable_grease_sigalgs` | `--enable-grease-sigalgs` | `bool` | `0` | Inject GREASE values into signature algorithms extension. |
| `tls_cert_compression` | `--tls-cert-compression <c>` | `string` | `""` | Certificate compression algorithm (`brotli` or `zstd`). |
| `tls_alps` | `--tls-alps <new\|old>` | `choice` | `""` *(auto)*| Application-Layer Protocol Settings draft version. |
| `tls_server_padding` | `--tls-server-padding <n>` | `int` | `""` | Byte padding added to Server Name Indication. |
| `disable_grease` | `--disable-grease` | `bool` | `0` *(false)* | Strip all GREASE values from TLS ClientHello extensions. |
| `disable_ocsp_stapling`| `--disable-ocsp-stapling` | `bool` | `0` *(false)* | Do not request OCSP stapling response in handshake. |
| `disable_sct` | `--disable-sct` | `bool` | `0` *(false)* | Omit Signed Certificate Timestamp (CT) extension. |
| `disable_session_ticket`| `--disable-session-ticket`| `bool` | `0` *(false)* | Disable TLS session resumption tickets. |
| `disable_extension_permutation` | `--disable-extension-permutation` | `bool` | `0` *(false)* | Preserve deterministic extension ordering instead of random shuffling. |
| `api_address` | `--api-address <ip:port>` | `string` | `""` | Direct WARP API endpoint address override. |
| `api_host` | `--api-host <host>` | `string` | `""` | Custom HTTP Host header sent to WARP registration API. |
| `api_sni` | `--api-sni <sni>` | `string` | `""` | Custom TLS SNI used when connecting to WARP API. |
| `masque_sni` | `--masque-sni <sni>` | `string` | `""` | Custom TLS SNI used during MASQUE tunnel handshakes. |

---

### 4. Circumvention (Tor & Psiphon)

Multi-hop transports chaining WARP with Onionoo Tor relays or Psiphon CDN-fronted meek tunnels.

| Key | CLI Argument / Environment | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `protocol` | `--<protocol>` | `choice` | `masque` | Active transport or multi-hop chaining mode. |
| `psiphon_mode` | `--psiphon-mode <mode>` | `choice` | `auto` | Psiphon transport mode (`auto`, `cdn`, `direct`). |
| `psiphon_region` | `--psiphon-region <cc>` | `string` | `""` | Target egress ISO country code (e.g. `DE`, `NL`, `US`). |
| `psiphon_bind` | `--psiphon-bind <addr>` | `string` | `127.0.0.1:1821`| SOCKS5 listen address for Psiphon exit. |
| `psiphon_http` | `--psiphon-http <addr>` | `string` | `""` | HTTP proxy listen address for Psiphon exit. |
| `psiphon_cdn_ips` | `--psiphon-cdn-ips <list>` | `string` | `""` | Comma-separated CDN fronting IP addresses. |
| `psiphon_cdn_sni` | `--psiphon-cdn-sni <list>` | `string` | `""` | Comma-separated CDN fronting TLS SNI names. |
| `psiphon_cdn_sets` | `--psiphon-cdn-sets <urls>`| `string` | `""` | Custom CDN configuration URLs. |
| `psiphon_server_entries`| `--psiphon-server-entries <path>`| `string`| `""` | Custom server entries list file or URL. |
| `psiphon_dir` | `--psiphon-dir <path>` | `string` | `""` | Working state directory for Psiphon core. |
| `psiphon_bin` | `--psiphon-bin <path>` | `string` | `""` | Custom path to `psiphon-tunnel-core` binary. |
| `psiphon_config` | `--psiphon-config <path>` | `string` | `""` | Custom JSON configuration file for Psiphon. |
| `tor_bind` | `--tor-bind <addr>` | `string` | `127.0.0.1:1820`| SOCKS5 listen address for Tor exit. |
| `tor_http` | `--tor-http <addr>` | `string` | `""` | HTTP proxy listen address for Tor exit. |
| `tor_country` | `AETHER_TOR_COUNTRY=<cc>` | `string` | `""` | Preferred bridge exit country code (e.g. `ir`). |
| `tor_bridges` | `--tor-bridges` / `--no-tor-bridges` | `choice` | `""` *(auto)*| Bridge enforcement (`""` auto, `on`, `off`). |
| `tor_bridge` | `--tor-bridge <line>` | `string` | `""` | Custom bridge line (e.g. `obfs4 IP:PORT FINGERPRINT ...`). |
| `tor_bridge_file` | `--tor-bridge-file <path>` | `string` | `""` | File containing multiple bridge configuration lines. |
| `tor_relays` | `--tor-relays <what>` | `choice` | `auto` | Onionoo live relay selection (`auto`, `only`, `off`). |
| `tor_relay_ports` | `--tor-relay-ports <set>` | `choice` | `web` | Relay port filter (`web` for 80/443, or `any`). |
| `tor_pt` | `--tor-pt <path>` | `string` | `""` | Pluggable transport binary specification. |
| `tor_pt_dir` | `--tor-pt-dir <path>` | `string` | `""` | Directory to search for pluggable transport binaries. |
| `tor_dir` | `--tor-dir <path>` | `string` | `""` | Working directory for Tor state files. |

---

### 5. System Routing (Zeptun TUN v1.1.3)

Transparent, full-system tun2socks redirection over `zeptun0`.

| Key | Zeptun Configuration Key | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `sysroute_enabled` | Master switch | `bool` | `0` *(false)* | Enable system-wide TUN routing via Zeptun. |
| `sysroute_preset` | `preset = "..."` | `choice` | `desktop` | Engine preset profile (`desktop`, `mobile`, `server`). |
| `sysroute_mtu` | `mtu = <n>` | `int` | `1500` | TUN virtual network interface MTU. |
| `sysroute_ipv6` | Dual-stack route policy | `bool` | `0` *(false)* | Enable IPv6 routing (when off, IPv6 is blocked). |
| `sysroute_strict_route` | Strict firewall routing | `bool` | `1` *(true)* | Blackhole unrouted traffic to prevent leaks. |
| `sysroute_auto_redirect`| `auto_redirect = true` | `bool` | `0` *(false)* | Accelerate TCP via kernel nftables redirection. |
| `sysroute_dns_mode` | `[dns] mode = "..."` | `choice` | `systemd_resolved`| DNS mode (`systemd_resolved`, `hijack`, `off`). |
| `sysroute_dns_servers` | `nameservers = [...]` | `string` | `1.1.1.1, 8.8.8.8` | In-tunnel upstream DNS resolvers. |
| `sysroute_fake_ip` | Remote DNS resolution | `bool` | `0` *(false)* | Fake-IP address mapping for remote SOCKS5 DNS. |
| `sysroute_dns_hijack` | Port 53 interception | `bool` | `1` *(true)* | Capture and redirect all UDP/TCP 53 DNS queries. |
| `sysroute_stack_mode` | `stack = "..."` | `choice` | `userspace` | Network stack implementation (`userspace`, `hybrid`, `system`). |
| `sysroute_congestion` | `congestion = "..."` | `choice` | `cubic` | TCP congestion control algorithm (`cubic`, `newreno`). |
| `sysroute_udp_mode` | `udp_mode = "..."` | `choice` | `udp` | UDP carrier mode (`udp` native, `tcp` encapsulated). |
| `sysroute_tcp_fastopen`| `tcp_fast_open = true` | `bool` | `0` *(false)* | Enable TCP Fast Open on upstream connections. |
| `sysroute_offload` | Hardware offloads | `bool` | `1` *(true)* | Enable GSO/GRO and checksum offloads on TUN device. |
| `sysroute_io_backend` | Event engine backend | `choice` | `auto` | Async I/O engine (`auto`, `io_uring`, `epoll`). |
| `sysroute_log_level` | `log_level = "..."` | `choice` | `warn` | Zeptun logging verbosity (`warn`, `info`, `debug`, `err`). |
| `sysroute_persistent` | Service watchdog | `bool` | `0` *(false)* | Automatically bring routing up when tunnel connects. |
| `sysroute_exclude` | `exclude = [...]` | `string` | `""` | Comma-separated CIDR subnets bypassed from TUN. |
| `sysroute_exclude_uids`| Policy routing rules | `string` | `""` | Comma-separated Linux UIDs/ranges excluded from TUN. |
| `zeptun_bin` | Engine executable | `string` | `""` *(auto)*| Custom binary path override for Zeptun. |

---

### 6. Zero Trust (Cloudflare Access)

Enterprise authentication, enrollment credentials, and Gateway inspection.

| Key | Runtime Environment / Argument | Type | Default | Description |
| :--- | :--- | :--- | :--- | :--- |
| `team` | `--team <name>` | `string` | `""` | Cloudflare Zero Trust team organization slug. |
| `access_id` | `AETHER_ACCESS_CLIENT_ID` | `string` | `""` | Cloudflare Access service token Client ID. |
| `access_secret` | `AETHER_ACCESS_CLIENT_SECRET` | `secret` | `""` | Cloudflare Access service token Client Secret. |
| `access_token` | `AETHER_ACCESS_TOKEN` | `secret` | `""` | Zero Trust enrollment JWT token. |
| `access_email` | `AETHER_ACCESS_EMAIL` | `string` | `""` | Enrollment user email address. |
| `enroll_address` | `--enroll-address <host>` | `string` | `""` | Custom Zero Trust enrollment API host/address. |
| `gateway` | `--gateway` | `bool` | `0` *(false)* | Route HTTP/HTTPS through Cloudflare Gateway inspection. |
