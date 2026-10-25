# Aether & Zeptun Troubleshooting Guide

Diagnostics procedures, common failure modes, capability configuration, and resolution steps for `cluvex.aether` (Aether `v2.4.0`, Zeptun `v1.1.3`).

---

## Built-in Diagnostic Tools

### 1. System Doctor (`bin/aether-ctl doctor`)

Run the automated health check from terminal or from the popup panel's **Logs → Diagnostics** sub-tab:

```sh
bin/aether-ctl doctor
```

The tool inspects:
- **Core Binary & Version**: Validates binary presence, pinned release status, and execution permissions.
- **Linux Capabilities**: Checks if `setcap cap_net_admin+ep` is active for hardware packet marking and TUN interface creation.
- **Port Availability**: Scans local SOCKS5 ports (`1819`, `1820`, `1821`) for collisions.
- **Zeptun Engine**: Checks binary existence, capability status, and whether `zeptun0` interface is initialized.
- **Pluggable Transports**: Probes availability of external helpers (`lyrebird`, `psiphon-tunnel-core`).
- **Routing & Egress State**: Analyzes active protocol and egress destination.

### 2. Command Line Preview (`bin/aether-ctl command`)

Generate the exact CLI invocation that the plugin passes to the Aether binary based on current configuration:

```sh
bin/aether-ctl command
```

Example output:
```sh
AETHER_TLS_VERIFY=0 /home/user/.local/share/omarchy-aether/bin/aether \
  --masque --scan balanced --noize firewall -4 --bind 127.0.0.1:1819 \
  --stats --stats-secs 15 --enable-ech-grease --mark 0xff --quick-reconnect --log-level info
```

To debug startup crashes or kernel panics directly, copy and paste the command line into an interactive terminal.

---

## Common Issues & Solutions

### 1. Missing Linux Capabilities (`CAP_NET_ADMIN`)

#### Symptoms
- Zeptun fails to start with: `failed to create TUN device: Operation not permitted`.
- Aether fails with: `failed to set SO_MARK 0xff: Operation not permitted`.

#### Solution
Grant `CAP_NET_ADMIN` to the managed binaries using `setcap`. Run `setcap` once on each binary:

```sh
# For Aether core (needed for socket marking):
sudo setcap cap_net_admin+ep ~/.local/share/omarchy-aether/bin/aether

# For Zeptun engine (needed for TUN interface creation):
sudo setcap cap_net_admin+ep ~/.local/share/omarchy-aether/bin/zeptun
```

To verify active capabilities:
```sh
getcap ~/.local/share/omarchy-aether/bin/aether
getcap ~/.local/share/omarchy-aether/bin/zeptun
```

---

### 2. "unknown option: --no-fragment" or "--api-fragment"

#### Symptoms
Aether core crashes immediately upon launching with exit code 1 and error message:
```
error: unexpected argument '--no-fragment' found
```

#### Cause
Aether core `v2.4.0` removed `--no-fragment` and `--api-fragment`. Passing negative booleans is no longer supported upstream.

#### Solution
The plugin's `bin/aether-ctl` manages this automatically in v2.0.0. If you have legacy settings in `config.env`:
```sh
bin/aether-ctl reset fragment
bin/aether-ctl set fragment 0
```
When `fragment` is `0`, `aether-ctl` completely omits the flag rather than passing `--no-fragment`.

---

### 3. Port Collision: SOCKS5 Port 1819 Already in Use

#### Symptoms
- Panel displays "Connecting..." then immediately resets to "Disconnected".
- Log shows: `address already in use: 127.0.0.1:1819`.

#### Solution
Check what process is holding port 1819:
```sh
ss -tulpn | grep 1819
```
Kill orphaned core processes or restart the daemon cleanly:
```sh
bin/aether-ctl stop
pkill -9 -f "aether.*--bind.*1819"
bin/aether-ctl start
```

---

### 4. Internet Stops Working After Enabling System Routing

#### Symptoms
`zeptun0` interface is up, but no websites load and terminal pings fail.

#### Checklist & Fixes
1. **Verify Aether Core is Connected First**:
   Zeptun relies on Aether's SOCKS5 proxy (`127.0.0.1:1819`). Test local proxy resolution first:
   ```sh
   curl -x socks5h://127.0.0.1:1819 https://cloudflare.com/cdn-cgi/trace
   ```
   If this curl fails, the core connection is down. Resolve transport/gateway connectivity before enabling Zeptun.

2. **Check DNS Leaks / DNS Stalls**:
   If websites hang on DNS lookup:
   - Enable Fake-IP: `bin/aether-ctl set sysroute_fake_ip 1`
   - Ensure DNS hijack is enabled: `bin/aether-ctl set sysroute_dns_hijack 1`
   - Restart system routing: `bin/aether-ctl system-route restart`

3. **Check Strict Leak Protection**:
   If IPv6 is disabled on your network, ensure `sysroute_ipv6` is `0` and `sysroute_strict_route` is `1` so IPv6 requests do not leak onto the physical interface and hang applications.

---

### 5. Infinite Routing Loop with Tor or Psiphon

#### Symptoms
- System routing connects, but after 5-10 seconds CPU spikes to 100% and traffic dies.
- Zeptun logs display millions of looping packets to Tor bridge or Psiphon CDN IPs.

#### Cause
Child helper processes (`psiphon-tunnel-core`, `lyrebird`) do not inherit `SO_MARK 0xff` across `exec` and loop back into `zeptun0`.

#### Solution
1. Apply the 1-click mitigation button on the warning card in the **Routing** tab.
2. Or apply the fix manually via CLI:
   ```sh
   bin/aether-ctl set sysroute_fake_ip 1
   bin/aether-ctl set sysroute_udp_mode tcp
   ```
3. Exclude helper UIDs if running helper binaries under a dedicated daemon user:
   ```sh
   bin/aether-ctl set sysroute_exclude_uids "<uid>"
   ```

---

### 6. Inspecting Raw Log Files

When reporting issues or debugging complex network stalls, inspect the raw logs:

```sh
# Follow Aether core daemon output:
tail -f ~/.local/share/omarchy-aether/aether.log

# Follow Zeptun TUN engine output:
tail -f ~/.local/share/omarchy-aether/zeptun.log

# Inspect generated Zeptun configuration:
cat ~/.local/share/omarchy-aether/data/zeptun.toml
```
