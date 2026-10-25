# Aether Transports & Circumvention Guide

Comprehensive reference on protocols, multi-hop chaining, obfuscation profiles, and TLS 1.3 fingerprint evasion in Aether core `v2.4.0`.

---

## Supported Protocols

Aether provides multiple transport layers designed to bypass state-level deep packet inspection (DPI) and protocol-specific throttling.

### 1. MASQUE (HTTP/3 — Default)
- **Carrier**: UDP port 443 over QUIC.
- **Mechanism**: Implements RFC 9298 / RFC 9297 (CONNECT-IP / CONNECT-UDP) over HTTP/3.
- **Features**:
  - Connection migration across network switches (Wi-Fi ↔ LTE) without dropping the tunnel.
  - Zero round-trip time (0-RTT) session resumption.
  - QUIC v2 opener packets (enabled by default) to defeat stateless firewall packet drops on initial handshake.
- **Best For**: Maximum throughput, minimal latency, and gaming or streaming on networks that do not block UDP.

### 2. MASQUE HTTP/2
- **Carrier**: TCP port 443 over TLS 1.3.
- **Mechanism**: Multiplexes tunnel datagrams inside standard HTTP/2 streams.
- **Features**:
  - Full compatibility with TLS ClientHello fragmentation.
  - Can pass through corporate enterprise proxies and networks that block UDP/QUIC outright.
- **Best For**: Heavily restricted Wi-Fi networks, hotel networks, and firewalls blocking UDP.

### 3. WireGuard (`wg`)
- **Carrier**: Native UDP datagrams.
- **Mechanism**: Noise protocol handshake with ChaCha20-Poly1305 encryption.
- **Features**:
  - Kernel-speed cryptographic throughput.
  - Profile scanning across endpoints with `--scan` and configurable `--keepalive`.
- **Best For**: High-throughput links where WireGuard traffic is not throttled or fingerprinted by the ISP.

### 4. Gool (WireGuard in MASQUE)
- **Carrier**: Nested WireGuard inside MASQUE HTTP/3.
- **Mechanism**: The client establishes an outer MASQUE connection, then routes an inner WireGuard session through the HTTP/3 stream.
- **Features**:
  - Outer traffic appears as regular HTTPS/QUIC traffic to Cloudflare edge nodes.
  - Defeats WireGuard protocol signatures while maintaining isolated inner encryption.
- **Best For**: ISP firewalls that actively block WireGuard handshakes.

### 5. Gool Classic (WireGuard in WireGuard)
- **Carrier**: Nested WireGuard UDP sessions.
- **Mechanism**: Direct multi-hop encapsulation between two separate Cloudflare endpoint hops (`--wiw-outer` and `--wiw-inner`).
- **Best For**: Geographic routing shifts and multi-hop egress.

### 6. MIM (MASQUE in MASQUE)
- **Carrier**: Double-nested MASQUE tunnels (`--mim-outer` and `--mim-inner`).
- **Mechanism**: Tunnels a secondary MASQUE HTTP/3 session through an initial MASQUE edge gateway.
- **Best For**: Bypassing intermediate Cloudflare rate limits and masking source metadata.

---

## Circumvention Transports (Tor & Psiphon)

Aether core integrates multi-hop circumvention via the Tor network and Psiphon circumvention engine.

### Tor Integration
Aether can operate in three distinct Tor modes:
1. **WARP → Tor (`protocol=tor`)**: Connects to WARP first, then carries Tor inside the tunnel. The external internet sees an exit Tor node IP. Local Tor SOCKS5 proxy binds to `--tor-bind` (default `127.0.0.1:1820`).
2. **Tor → WARP (`protocol=tor-reverse`)**: Dials the WARP tunnel through the Tor network. External traffic exits from Cloudflare WARP, but the local ISP only sees connections to Tor bridges or guards.
3. **Tor Only (`protocol=tor-only`)**: Standalone Tor proxy without establishing a WARP tunnel.

#### Tor Relay & Bridge Capabilities
- **Onionoo Relays (`--tor-relays auto|only|off`)**: Uses live directory relays queried from the Tor Onionoo service alongside traditional BridgeDB bridges.
- **Web Port Filtering (`--tor-relay-ports web`)**: Restricts Tor connections strictly to standard HTTP/HTTPS ports (80 and 443) to evade firewalls blocking non-standard ports.
- **Pluggable Transports (`--tor-pt`)**: Supports external helpers such as `lyrebird` (obfs4, meek, webtunnel) and `snowflake-client`.

### Psiphon Integration
Psiphon circumvention can be used across three operational modes:
1. **WARP → Psiphon (`protocol=psiphon`)**: Carries Psiphon inside the WARP tunnel. External traffic exits from Psiphon's global egress servers. Local SOCKS5 binds to `--psiphon-bind` (default `127.0.0.1:1821`).
2. **Psiphon → WARP (`protocol=psiphon-reverse`)**: Dials the WARP tunnel through Psiphon.
3. **Psiphon Only (`protocol=psiphon-only`)**: Standalone Psiphon proxy without WARP.

#### Psiphon Transport Shapes
- **Auto (`--psiphon-mode auto`)**: Dynamically evaluates and selects the optimal egress channel.
- **CDN Fronting (`--psiphon-mode cdn`)**: Forces meek domain-fronted connections over public CDNs (`--psiphon-cdn-ips`, `--psiphon-cdn-sni`), bypassing national firewalls that block direct IPs.
- **Direct (`--psiphon-mode direct`)**: Direct connections without CDN fronting.

---

## TLS 1.3 Fingerprint Evasion (Core v2.4.0)

Aether core `v2.4.0` introduces extensive BoringSSL TLS fingerprint evasion capabilities designed to defeat advanced deep packet inspection and SNI filtering.

### ClientHello Fragmentation
- **Flag**: `--fragment` (boolean)
- **Tuning**: `--fragment-size <min-max>` (e.g. `8-16`), `--fragment-delay <min-max>` (e.g. `2-10` ms).
- **How It Works**: Splits the initial TLS ClientHello record across multiple TCP segments. Because DPI middleboxes typically assemble and inspect single TCP packets, fragmented records pass through undetected.

### Encrypted Client Hello (ECH)
- **Flag**: `--ech auto` / `--ech off`
- **Tuning**: `--ech-dns <url>`, `--ech-domain <domain>`, `--enable-ech-grease`
- **How It Works**: Encrypts the Server Name Indication (SNI) inside an outer TLS extension using a public key published via DNS HTTPS records. Eavesdroppers and middleboxes only see the public outer domain (e.g. `cloudflare.com`), completely hiding the destination website.

### Cipher Suites & Curve Groups
- **TLS 1.3 Ciphers (`--tls13-ciphers`)**: Customize allowed TLS 1.3 suites (e.g. `TLS_AES_128_GCM_SHA256:TLS_CHACHA20_POLY1305_SHA256`).
- **Curve Groups (`--tls-groups`)**: Select elliptic curve groups (e.g. `X25519:P-256`).
- **Key Shares (`--tls-key-shares`)**: Control which groups offer precomputed key shares in the ClientHello.

### Extension Permutation & GREASE
- **GREASE Signature Algorithms (`--enable-grease-sigalgs`)**: Injects synthetic GREASE values to prevent middlebox protocol ossification.
- **Extension Order (`--disable-extension-permutation`)**: Enforces deterministic extension ordering when emulating specific legacy browser fingerprints.
- **OCSP & SCT Toggles**: Disable OCSP stapling (`--disable-ocsp-stapling`) or Certificate Transparency timestamps (`--disable-sct`) to reduce ClientHello size.
- **Server Padding (`--tls-server-padding`)**: Pads the ClientHello with dummy bytes to obscure packet lengths from statistical traffic analysis.
