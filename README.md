# Aether — Omarchy Shell Plugin

<p align="center">
  <img src="https://raw.githubusercontent.com/IHosseini083/aether-core-omarchy/main/preview.png" alt="Aether Omarchy shell plugin — popup control panel" width="550" />
</p>

<p align="center">
  <a href="https://github.com/tcballard/omarchy-badges"><img src="https://raw.githubusercontent.com/tcballard/omarchy-badges/75975e5b5bf75e7ede3764bcd2950046f7abfe2c/badges/v1/omarchy-plugin.svg" alt="Built for Omarchy: Plugin" /></a>
</p>

An [Omarchy](https://omarchy.org/) status bar widget and popup panel for controlling the [Aether](https://github.com/CluvexStudio/Aether) tunnel — a userspace Cloudflare WARP client built by [CluvexStudio](https://github.com/CluvexStudio) for heavily censored networks.

The plugin is written and maintained by **iliya**. It is an independent companion tool and is **not** affiliated with CluvexStudio; Aether itself is a separate project with its own repository and licensing.

The plugin talks to the Aether core through `bin/aether-ctl`. It can download the official core for you, switch between cores found on your system, and surface the daemon's live output — all from the Omarchy bar, with no root required for normal use.

### Documentation Guides

- [Full Technical Reference (DOCS.md)](DOCS.md)
- [Settings & Schema Directory (docs/SETTINGS.md)](docs/SETTINGS.md)
- [Configuration, Persistence & CLI (docs/CONFIG.md)](docs/CONFIG.md)
- [Transports & Circumvention Guide (docs/TRANSPORTS.md)](docs/TRANSPORTS.md)
- [System Routing Architecture & Limitations (docs/SYSTEM-ROUTING.md)](docs/SYSTEM-ROUTING.md)
- [Troubleshooting & Diagnostics Guide (docs/TROUBLESHOOTING.md)](docs/TROUBLESHOOTING.md)

## Features

**Bar widget**

- Status-aware shield icon: filled when connected, pulsing while connecting, slashed when disconnected, warning badge when the core is missing.
- Left-click opens the control panel, right-click connects/disconnects, middle-click forces a refresh.

**Popup panel — Tunnel tab**

- Gateway (Cloudflare colo + country), round-trip latency, WARP exit IP, local SOCKS5 address, exit location filter status, and traffic stats.
- One-click connect/disconnect.
- Transport presets: **MASQUE** (HTTP/3), **MASQUE HTTP/2**, **WireGuard**, **Gool** (WireGuard in MASQUE), **Gool Classic** (WireGuard in WireGuard), **MIM** (MASQUE-in-MASQUE), **Psiphon**, **Tor**.
- First-class inline controls for **Psiphon** (WARP → Psiphon, Psiphon → WARP, Standalone Psiphon, quick region presets) and **Tor** (WARP → Tor, Tor → WARP, Standalone Tor, Onionoo relays).
- Exit location guard card with quick country restriction presets (`Worldwide`, `!IR,AZ,RU`, `DE,SE,NL`, `US`).
- Scan mode covering `balanced`, `turbo`, **`verified`** (measured connect-ip edges), `thorough`, and `ironclad`.
- Obfuscation (noize) profile selectors covering all upstream values.
- One-click copy of SOCKS5 / HTTP URLs, `all_proxy` exports, `curl` test command, and gateway cache clearing.

**Popup panel — Settings tab**

- Shows the active core binary, its version, and `CAP_NET_ADMIN` status.
- Switch between every Aether core discovered on your system, or download the pinned, checksum-verified official release from GitHub with one click.
- **Profile Presets**: 1-click profiles for `Default` (standard WARP), `Stealth` (anti-DPI with TLS 1.3 ClientHello fragmentation & ECH), `Speed` (turbo scan & cubic congestion), `Tor Multi-hop`, and `Psiphon Bypass`.
- **Live Search & Category Navigation**: Filter any setting instantly by name or keyword across Core & Engine, Network & Ports, TLS 1.3 & Fingerprint Evasion, Circumvention, System Routing, and Zero Trust.
- **Basic vs Advanced Toggle**: Keep the interface clean with essential controls or expand to configure all 60+ parameters.
- **Per-Field Reset & Global Reset**: Reset individual settings to defaults with one click or restore factory defaults with confirmation.
- **TLS 1.3 & Fingerprint Evasion (Core v2.4.0)**: ClientHello fragmentation (`--fragment`, `--fragment-size`, `--fragment-delay`), Encrypted Client Hello (`--ech auto`, `--ech-dns`, `--ech-domain`), synthetic GREASE injection, custom cipher suites, curve groups, ALPS draft version, and extension ordering.

**Popup panel — Routing tab (optional system-wide routing)**

- Route **all** system traffic through the Aether tunnel with the [Zeptun](https://github.com/Noisemux/zeptun) TUN engine (`v1.1.3`): `system traffic → Zeptun TUN → Aether local SOCKS5 → Aether tunnel`.
- Completely optional and **off by default** — normal Aether behavior is untouched until you enable it.
- Comprehensive engine controls: Engine profiles (Desktop, Mobile, Server), TUN MTU, IPv4 vs IPv4+IPv6, Strict routing (leak protection), Auto-redirect TCP (nftables netlink), DNS mode & custom in-tunnel DNS servers, Fake-IP remote resolution, DNS hijack (port 53 capture), TCP/IP stack mode, Congestion control, native vs TCP-carried UDP, TCP Fast Open, Hardware offloads, I/O backend (`auto`, `io_uring`, `epoll`), Zeptun log levels, persistent auto-start, UID exclusions, and route exclusions.
- **Tor & Psiphon Guard**: Detects multi-hop egress and displays a warning card with 1-click mitigation for child-process loopback and UDP ASSOCIATE limitations.

**Popup panel — Live Logs & Diagnostics tab**

- Sub-tab navigation switching seamlessly between **Core Logs**, **Zeptun Logs**, and **Diagnostics**.
- Real-time auto-tailing with syntax color-coding, manual refresh, copy, and log clearing.
- **Diagnostics & Health Doctor**: Runs `bin/aether-ctl doctor` in-panel to diagnose binary integrity, Linux capabilities, port availability, and helper presence.
- **CLI Command Line Generator**: Generates and copies the exact command line executed by the daemon for troubleshooting and standalone execution.

**Missing-core handling**

- If no Aether binary is found, the panel shows a warning and offers to download and install the official release for your architecture automatically (`x86_64`, `arm64`, `armv7`), falling back to downloading through the active tunnel if GitHub is unreachable directly.

## Requirements

- Omarchy (Quattro shell with Quickshell) — this is an Omarchy plugin.
- `bash`, `curl`, `jq`, `tar` — present on any Omarchy install.
- An Aether core binary — downloaded automatically in-panel, or see [Core](#core).

## Install

Install with:

```sh
omarchy plugin add https://github.com/IHosseini083/aether-core-omarchy.git --enable
```

The plugin appears in the bar's right section. Move it with `omarchy bar move cluvex.aether --section <left|center|right>` if you like.

## Update

Update the plugin with:

```sh
omarchy plugin update cluvex.aether
```

(Omit the id to update every installed git-managed plugin at once.) Manual alternative:

```sh
git -C ~/.config/omarchy/plugins/cluvex.aether pull
```

If the bar widget doesn't pick up the change immediately, restart the Omarchy shell (or log out and back in).

**Aether core updates:** the core version is pinned by the plugin and verified against committed SHA-256 checksums, so a plugin update does not silently swap your core. When a plugin update bumps the pinned core version, refresh it in two steps: remove the managed core in the Settings tab (**Remove** next to `~/.local/share/omarchy-aether/bin/aether`), then use **Download & Install Aether Core**. The new plugin version installs its pinned release.

## Core

The plugin controls an Aether binary; it does not ship one. It is kept up-to-date with **Aether core v2.4.0** and **Zeptun v1.1.3**.

**Where the plugin looks for a core** (first match wins; each candidate is verified by running it with `--help` and checking for SOCKS5 output, so the unrelated `aether` theme tool is never mistaken for the core):

1. The custom path you set (Settings tab / `aether-ctl set bin <path>`)
2. `~/.local/share/omarchy-aether/bin/aether` — where the plugin installs official releases
3. `~/Downloads/Aether/aether`
4. `<plugin directory>/bin/aether`
5. `~/.local/bin/aether`
6. `/usr/local/bin/aether`
7. `/opt/aether/aether`
8. Every `aether` on your `PATH`

To set up a core manually, drop the binary at any of those locations (e.g. `~/.local/bin/aether`), make it executable, and it will be discovered — or point the custom path at it.

- **Download:** with no core found, the panel offers **Download & Install Aether Core**, which fetches the version-pinned, SHA-256-verified release asset from [CluvexStudio/Aether releases](https://github.com/CluvexStudio/Aether/releases) into `~/.local/share/omarchy-aether/bin/` and pins it as the active core.
- **Switch/activate:** every discovered core is listed in the Settings tab; click **Use** to activate it.
- **Remove:** cores can be deleted from the same list (**Remove**, with a confirmation), even if only one core is installed. Removing the active core stops the tunnel first. The plugin-managed directory is removed as a whole; a binary anywhere else is deleted individually.

Verify a running tunnel yourself:

```sh
curl -x socks5h://127.0.0.1:1819 https://www.cloudflare.com/cdn-cgi/trace
```

The reply should show a Cloudflare colo and `warp=on`.

## Persistence

Every setting — transport, scan mode, noize profile, ports, peers, Zero Trust and Tor options — is stored in `~/.config/omarchy-aether/config.env` the moment you change it, so your configuration survives reboots and shell restarts. The tunnel itself is not started at boot unless you enable the optional [systemd unit](#optional-systemd-user-service); that is deliberate, so a reboot never silently re-routes your traffic.

## Firewall mark (`--mark`)

For router-style setups (tun2socks, hev-socks5-tunnel) the core can set the `SO_MARK` firewall mark. The kernel requires `CAP_NET_ADMIN` for that, so grant it once to the binary:

```sh
sudo setcap cap_net_admin+ep ~/.local/share/omarchy-aether/bin/aether
```

Then enable **Firewall Mark (SO_MARK 0xff)** in the Settings tab. The plugin checks for the capability before every start and silently omits the flag if it is missing, instead of letting the core abort.

## Optional systemd user service

To have the tunnel start at login independent of the plugin:

```sh
mkdir -p ~/.config/systemd/user
cp ~/.config/omarchy/plugins/cluvex.aether/systemd/aether.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now aether
```

To have **system-wide routing** start with it, install `systemd/zeptun.service` the same way after enabling routing in the panel.

## System-wide routing (Zeptun, optional)

The Routing tab can route every application's traffic through the tunnel — not just proxy-aware apps — using [Zeptun](https://github.com/Noisemux/zeptun), a userspace tun2socks engine, pointed at Aether's local SOCKS5 port.

**Transport-aware egress**

The engine follows the selected transport, so the whole system exits where the transport says:

- Direct transports (MASQUE, WireGuard, Gool, MIM), the reverse chains (Tor → WARP, Psiphon → WARP) and the standalone modes (`--tor-only`, `--psiphon-only`) serve their exit on the main SOCKS port — the engine feeds that port.
- The chain transports **WARP → Tor** and **WARP → Psiphon** keep the WARP exit on the main port and serve the chain exit on their own listeners (`--tor-bind`, default `127.0.0.1:1820`; `--psiphon-bind`, default `127.0.0.1:1821`) — the engine feeds those, so system traffic genuinely exits through Tor or Psiphon. The end-to-end check accepts the non-WARP exit accordingly, and readiness probes give Tor/Psiphon a longer bounded window to finish bootstrapping.
- Switching transport (or changing `socks_port`/`tor_bind`/`psiphon_bind`) while routing is active restarts the engine so the new egress applies.

**Setup**

1. Connect the Aether tunnel.
2. Open the **Routing** tab and press **Download & Install Zeptun** (or install Zeptun yourself; the plugin discovers `~/.local/share/omarchy-aether/bin/zeptun`, `~/.local/bin/zeptun`, `/usr/local/bin/zeptun`, then `$PATH`, or set a path in the tab).
3. Grant `CAP_NET_ADMIN` privileges: both Zeptun (to create the TUN device and routing policy) and the Aether core (for `SO_MARK 0xff` routing loop prevention) require this capability. The plugin requests this via polkit password prompt automatically during install / first start. If granting manually:
   ```sh
   sudo setcap cap_net_admin+ep ~/.local/share/omarchy-aether/bin/zeptun
   sudo setcap cap_net_admin+ep ~/.local/share/omarchy-aether/bin/aether
   ```
4. Toggle **System-wide routing** on (or click **Start**). The engine launches only when Aether is connected; toggling off (or stopping Aether) always brings routing down first.

**Safety model**

- The engine is only marked `RUNNING` after the TUN device, the routing policy, **and** a real end-to-end traffic check all succeed; any failure tears the engine down and restores the previous network state before reporting an error.
- Teardown removes **only** what this integration created — the `zeptun0` interface and policy rules for table `8891`. Routes, rules, and firewalls outside it are never touched.
- Routing loops are prevented by the core's firewall mark (`SO_MARK 0xff`, enabled automatically and inert without TUN mode) plus a snapshot of the core's and its helper processes' current endpoints. The mark does not propagate to child helpers (`psiphon-tunnel-core`, Tor pluggable transports), so their dial-outs rely on that snapshot — restarting routing refreshes it. LAN, link-local, and multicast ranges are always excluded.
- IPv4-only mode **blocks** IPv6 through the routing policy rather than leaking it; choose IPv4+IPv6 to carry both families.
- Crash detection runs on every status poll; restarts are bounded (three attempts with backoff) — a broken setup fails visibly instead of flapping.

**Rollback**

Toggle the switch off (or `omarchy-shell cluvex.aether systemRouteStop`), then remove the capabilities if desired:

```sh
sudo setcap -r ~/.local/share/omarchy-aether/bin/zeptun
sudo setcap -r ~/.local/share/omarchy-aether/bin/aether
```

`aether-ctl zeptun-remove [path]` deletes the engine binary (also removable via **Remove** in the Routing and Cores tabs); disabling routing leaves nothing running and no routing state behind.

## IPC

Control the plugin from scripts or Hyprland keybindings:

```sh
omarchy-shell cluvex.aether toggle       # open/close the popup panel
omarchy-shell cluvex.aether status       # one-line status summary
omarchy-shell cluvex.aether start        # connect
omarchy-shell cluvex.aether stop         # disconnect
omarchy-shell cluvex.aether restart
omarchy-shell cluvex.aether refresh      # re-probe status + logs
omarchy-shell cluvex.aether systemRouteStatus   # system routing state
omarchy-shell cluvex.aether systemRouteStart    # route all traffic (needs setup above)
omarchy-shell cluvex.aether systemRouteStop
omarchy-shell cluvex.aether systemRouteRestart
```

## CLI & Automation

Direct management via `bin/aether-ctl`:

```sh
# Lifecycle & diagnostics
bin/aether-ctl status               # Full JSON status
bin/aether-ctl doctor               # System health check & capability inspection
bin/aether-ctl command              # Print active core command line invocation
bin/aether-ctl start | stop | restart

# Configuration management
bin/aether-ctl get <key>            # Get configuration setting
bin/aether-ctl set <key> <val>      # Set setting and hot-reload tunnel if running
bin/aether-ctl reset <key|all>      # Restore field or full default configuration
bin/aether-ctl preset <name>        # Apply preset: default, stealth, speed, tor_multihop, psiphon_bypass
bin/aether-ctl export [file]        # Export configuration
bin/aether-ctl import <file>        # Import and apply configuration
```

## Data and file paths

| Path | Purpose |
| --- | --- |
| `~/.local/share/omarchy-aether/bin/` | Cores **and the managed Zeptun engine** downloaded by the plugin |
| `~/.local/share/omarchy-aether/data/` | Working directory for the core (identity files, `aether.toml`, gateway cache, generated `zeptun.toml`, zeptun state) |
| `~/.local/share/omarchy-aether/aether.log` | Daemon log shown in Live Logs (Aether view) |
| `~/.local/share/omarchy-aether/zeptun.log` | Routing engine log shown in Live Logs (Zeptun view) |
| `~/.config/omarchy-aether/config.env` | Plugin settings (source of truth for all options) |

Identity files (`aether.toml`, `aether-masque.toml`, last-connection cache) are created by the Aether core inside the data directory and are never touched by plugin removal.

## Remove

```sh
omarchy plugin remove cluvex.aether
```

Before removing: disconnect the tunnel first if you want a clean teardown (removal leaves the daemon running otherwise). To also drop the WARP identities and logs, delete `~/.local/share/omarchy-aether/`.

## Security notes

- Plugins run unsandboxed inside the Omarchy shell with your user permissions. This plugin only shells out to its own `bin/aether-ctl`, `curl`, `tar`, `jq`, `ss`, and `systemctl`, and never requests root; the one privileged step (granting `CAP_NET_ADMIN` to the Zeptun binary) is a one-time `sudo setcap` you run or approve.
- Release downloads (Aether core and Zeptun engine) are pinned to fixed versions, fetched over HTTPS from GitHub, and verified against SHA-256 checksums committed in `bin/aether-ctl` before anything is used; see [Core](#core) and [DOCS.md](DOCS.md).
- The local SOCKS5 proxy has no authentication and binds to `127.0.0.1` only. Do not expose the port to your network.

## License

MIT — see [LICENSE](LICENSE). The Aether core is a separate project by CluvexStudio under its own license.
