# omarchy-aether — Reference

Deep documentation for the `cluvex.aether` Omarchy shell plugin. For a quick start see [README.md](README.md). For the Aether core itself, see the [upstream docs](https://github.com/CluvexStudio/Aether/blob/main/Docs/DOCS.en.md) — this document covers the plugin.

## Architecture

```
~/.config/omarchy/plugins/cluvex.aether/
├── manifest.json        # Plugin contract (kind: bar-widget)
├── Panel.qml            # Entry point: bar button + popup panel (5 tabs)
├── Service.qml          # Quickshell Process/Timer layer driving aether-ctl
├── Model.js             # JSON parsing, formatting, log colorization
├── AetherIcon.qml       # Vector shield icon (bar + hero), state-aware
├── bin/aether-ctl       # Bash CLI: status, lifecycle, config, install, system routing
└── systemd/             # Optional user units (aether.service, zeptun.service)
```

Data flow: `Panel.qml` instantiates `Service.qml`, which shells out to `bin/aether-ctl`. The ctl script is the single source of truth — it owns `~/.config/omarchy-aether/config.env`, starts/stops the daemon, and prints a JSON status blob on stdout that `Model.parseStatus` consumes. No Quickshell process is started by the plugin; it loads inside the Omarchy shell.

**Status polling:** `Service.qml` polls `aether-ctl status` every 4 s while connected, 12 s otherwise. Each status includes a probe (`curl` through the SOCKS5 port against `https://www.cloudflare.com/cdn-cgi/trace`) — so "Connected" always means *verified end-to-end traffic*, not just a live PID.

**Logs:** the daemon writes to `~/.local/share/omarchy-aether/aether.log` (rotated at 2 MB). Live Logs polls the last 100 lines; there is no streaming tail. `Model.colorizeLogsToHtml` colorizes by level: errors red, warnings amber, successes accent, plugin lines blue.

**Config changes:** every `aether-ctl set` saves `config.env` and, if the daemon is running, immediately restarts it — UI changes take effect in ~1 s without a manual restart.

## Command reference: `bin/aether-ctl`

```
aether-ctl status                     # JSON status blob (see below)
aether-ctl start|stop|restart|toggle  # daemon lifecycle
aether-ctl foreground                 # run in foreground (for systemd)
aether-ctl install                    # download pinned official release (checksum-verified)
aether-ctl set <key> <val>            # update one setting (hot-restarts)
aether-ctl set-protocol <proto> <0|1> # atomic protocol + h2 switch
aether-ctl cores                      # discovered core binaries
aether-ctl remove-core <path>         # delete a non-active core (managed dir removed whole)
aether-ctl logs [N]                   # last N log lines (default 60)
aether-ctl clear-logs|clear-cache     # housekeeping (cache = lastconn/secondary)
aether-ctl probe                      # raw curl trace through the tunnel
aether-ctl system-route status        # Zeptun system-routing state (JSON)
aether-ctl system-route start         # route all traffic through Aether via Zeptun
aether-ctl system-route stop|restart  # bring routing down / bounce it
aether-ctl zeptun-logs [N]            # last N lines of the engine log
aether-ctl zeptun-clear-logs          # truncate the engine log
aether-ctl zeptun-install             # download pinned Zeptun release (checksum-verified)
aether-ctl zeptun-remove              # delete the managed engine binary
```

### `set` keys

| Key | Values (default first) | Flag passed to core | In panel UI |
| --- | --- | --- | --- |
| `protocol` | `masque`, `wg`, `gool`, `mim`, `tor`, `tor-reverse`, `tor-only` | `--masque` / `--wg` / `--gool` / `--mim` / `--tor` / `--tor-reverse` / `--tor-only` | ✓ Transport + Tor mode |
| `h2` | `0` (HTTP/3), `1` (HTTP/2) | `--h2` | ✓ Transport |
| `scan` | `balanced`, `turbo`, `thorough`, `stealth`, `ironclad` | `--scan <mode>` | ✓ Scan mode |
| `noize` | `firewall`, `gfw`, `aggressive`, `balanced`, `light`, `off` | `--noize <profile>` | ✓ Noize |
| `ip` | `v4`, `v6`, `dual` | `-4` / `-6` / `--dual` | ✓ IP version |
| `socks_port` | `1819` | `--bind 127.0.0.1:<port>` | ✓ Advanced |
| `http_proxy_port` | `0` (off), port | `--http-proxy` | ✓ Advanced |
| `quick_reconnect` | `1`, `0` | `--quick-reconnect` / `--no-quick-reconnect` | ✓ |
| `fragment` | `0`, `1` | `--fragment` (h2 only) | ✓ |
| `fragment_size` | `16-32` | `--fragment-size` | ✓ Advanced |
| `fragment_delay` | `2-10` | `--fragment-delay` | ✓ Advanced |
| `ech` | `off`, `auto`, or base64 config | `--ech <value>` | ✓ |
| `no_quic_v2` | `0` (opener on), `1` | `--no-quic-v2` | ✓ (inverted as "QUIC v2 Opener") |
| `no_data_check` | `0`, `1` | `--no-data-check` | ✓ |
| `keepalive` | `5` | `--keepalive` (wg) | ✓ Advanced |
| `peer` | empty | `--peer <ip:port>` | ✓ Advanced |
| `wg_peer` | empty | `--wg-peer <ip:port>` | ✓ Advanced |
| `h2_peer` | empty | `--h2-peer <ip:port>` | ✓ Advanced |
| `no_profile_retry` | `0`, `1` | `--no-profile-retry` (wg) | ✓ Advanced |
| `wiw_outer` / `wiw_inner` | empty | `--wiw-outer` / `--wiw-inner` | ✓ Advanced |
| `mim_outer` / `mim_inner` | empty | `--mim-outer` / `--mim-inner` | ✓ Advanced |
| `dns` | empty | `--dns <list>` | ✓ Advanced |
| `upstream` | empty | `--upstream <url>` | ✓ Advanced |
| `route_block` / `route_direct` | empty | `--route-block` / `--route-direct` | ✓ Advanced |
| `routes_file` | empty | `--routes <path>` | ✓ Advanced |
| `team` | empty | `--team <name>` | ✓ Advanced |
| `access_token` | empty | `--access-token <jwt>` | ✓ Advanced |
| `access_id` / `access_secret` | empty | `--access-id` / `--access-secret` | ✓ Advanced |
| `access_email` | empty | `--access-email <addr>` | ✓ Advanced |
| `gateway` | `0`, `1` | `--gateway` (with `team`) | ✓ Advanced |
| `tor_bind` / `tor_dir` | empty | `--tor-bind` / `--tor-dir` | ✓ Advanced |
| `tor_bridges` | empty (auto), `on`, `off` | `--tor-bridges` / `--no-tor-bridges` | ✓ Advanced |
| `tor_bridge` | empty | `--tor-bridge <line>` | ✓ Advanced |
| `tor_pt` / `tor_pt_dir` | empty | `--tor-pt` / `--tor-pt-dir` | ✓ Advanced |
| `tor_country` | empty | — (env `AETHER_TOR_COUNTRY`) | ✓ Advanced |
| `validate_secs` / `startup_secs` / `reconnect_secs` | empty (core defaults) | `--validate-secs` / `--startup-secs` / `--reconnect-secs` | ✓ Advanced |
| `perf` | empty (auto), `low`, `medium`, `high` | `--perf <profile>` | ✓ Advanced |
| `tls_groups` | empty | `--tls-groups <list>` | ✓ Advanced |
| `log_level` | `info` | `--log-level <level>` | ✓ Advanced |
| `extra_args` | empty | appended verbatim | ✓ Advanced |
| `bin` | empty (auto-discover) | — (binary selector) | ✓ Settings |
| `sysroute_enabled` | `0` (off), `1` | — (master switch; `1` also starts routing when Aether is up) | ✓ Routing |
| `sysroute_ipv6` | `0` (IPv4-only + v6 blocked), `1` (dual stack) | — | ✓ Routing |
| `sysroute_preset` | `desktop` (default), `mobile`, `server` | — (Zeptun performance & memory preset) | ✓ Routing |
| `sysroute_mtu` | `1500` (default, 576-65535) | — (TUN device MTU) | ✓ Routing |
| `sysroute_dns_mode` | `systemd_resolved`, `hijack`, `off` | — (engine `[dns]` section) | ✓ Routing |
| `sysroute_dns_servers` | `1.1.1.1, 8.8.8.8` | — (in-tunnel DNS servers to prevent ISP poisoning) | ✓ Routing |
| `sysroute_fake_ip` | `0` (off), `1` (on) | — (remote domain resolution via SOCKS5) | ✓ Routing |
| `sysroute_dns_hijack` | `0`, `1` (default `1`) | — (capture port 53 to in-tunnel DNS) | ✓ Routing |
| `sysroute_strict_route` | `0`, `1` (default `1`) | — (block uncarried address families / leak protection) | ✓ Routing |
| `sysroute_auto_redirect` | `0` (default), `1` | — (nftables TCP redirect for lower latency) | ✓ Routing |
| `sysroute_exclude` | empty | — (extra engine `exclude` CIDRs) | ✓ Routing |
| `sysroute_exclude_uids` | empty | — (comma-separated UIDs/ranges excluded from tunnel) | ✓ Routing |
| `sysroute_stack_mode` | `userspace` (default), `hybrid`, `system` | — (Zeptun TCP/IP stack implementation) | ✓ Routing |
| `sysroute_congestion` | `cubic` (default), `newreno` | — (TCP congestion control algorithm) | ✓ Routing |
| `sysroute_udp_mode` | `udp` (native), `tcp` (UDP over TCP) | — (engine `udp_mode`) | ✓ Routing |
| `sysroute_tcp_fastopen` | `0` (default), `1` | — (TCP Fast Open for upstream connections) | ✓ Routing |
| `sysroute_offload` | `0`, `1` (default `1`) | — (virtio-net, TSO, USO, checksum offload) | ✓ Routing |
| `sysroute_io_backend` | `auto` (default), `io_uring`, `epoll` | — (async I/O event engine) | ✓ Routing |
| `sysroute_log_level` | `warn` (default), `info`, `debug`, `err` | — (Zeptun log verbosity) | ✓ Routing |
| `sysroute_persistent` | `0`, `1` (auto-start with Aether, bounded retries) | — | ✓ Routing |
| `zeptun_bin` | empty (auto-discover) | — (engine binary selector) | ✓ Routing |

`sysroute_*` and `zeptun_bin` keys never hot-restart the Aether core. Changing one while routing is active bounces only the Zeptun engine.

All documented upstream flags now have a `set` key (see table above) except the identity-path overrides `--config`, `--wg-config`, `--masque-config` — the plugin manages those paths itself; pass overrides through `extra_args` if you must. Env-only knobs without a flag (the `AETHER_TOR_*` timing/check/log tuning) are likewise out of scope; `tor_country` is exposed because bridge requests are region-sensitive.

**Protocol switching note:** MASQUE's h3/h2 carrier is stored as the separate `h2` key. The panel's MASQUE and HTTP/2 buttons use `set-protocol`, which writes both keys in one save + one restart; two chained `set` calls can drop the second update while the first restart is still in flight.

### Status JSON

`aether-ctl status` prints:

```json
{
  "installed": true, "binary": "/path/to/aether", "binary_version": "aether 2.0.0",
  "has_cap_net_admin": false, "running": true, "pid": "1234", "connected": true,
  "ip": "104.28.x.x", "colo": "FRA", "loc": "IR", "warp": "on", "latency_ms": 1091,
  "proxy_port": 1819, "http_proxy_port": 0,
  "protocol": "masque", "scan": "balanced", "noize": "firewall", "ip_mode": "v4",
  "h2": false, "fragment": true, "quick_reconnect": true, "mark_enabled": false,
  "no_quic_v2": false, "ech": "off", "no_data_check": false, "keepalive": 5,
  "peer": "", "wiw_outer": "", "wiw_inner": "", "mim_outer": "", "mim_inner": "",
  "dns": "", "team": "", "upstream": "", "route_direct": "", "route_block": "",
  "log_level": "info", "wg_peer": "", "h2_peer": "", "no_profile_retry": false,
  "validate_secs": "", "startup_secs": "", "reconnect_secs": "", "perf": "",
  "tls_groups": "", "routes_file": "", "tor_bind": "", "tor_dir": "",
  "tor_bridges": "", "tor_bridge": "", "tor_pt": "", "tor_pt_dir": "",
  "tor_country": "", "access_id": "", "access_secret": "", "access_token": "",
  "access_email": "", "discovered_cores": ["/path/to/aether"],
  "zeptun_state": "DISABLED", "zeptun_available": true,
  "zeptun_binary": "/home/user/.local/share/omarchy-aether/bin/zeptun",
  "zeptun_pid": "", "zeptun_tun": "zeptun0", "zeptun_has_cap_net_admin": false,
  "zeptun_retries": 0, "zeptun_uptime_s": 0, "zeptun_error": "",
  "sysroute_enabled": false, "sysroute_ipv6": false,
  "sysroute_dns_mode": "systemd_resolved", "sysroute_dns_servers": "1.1.1.1, 8.8.8.8",
  "sysroute_fake_ip": false, "sysroute_dns_hijack": true,
  "sysroute_preset": "desktop", "sysroute_mtu": 1500,
  "sysroute_udp_mode": "udp", "sysroute_persistent": false,
  "sysroute_exclude": "", "sysroute_exclude_uids": "",
  "sysroute_strict_route": true, "sysroute_auto_redirect": false,
  "sysroute_stack_mode": "userspace", "sysroute_congestion": "cubic",
  "sysroute_tcp_fastopen": false, "sysroute_offload": true,
  "sysroute_io_backend": "auto", "sysroute_log_level": "warn"
}
```

`discovered_cores` lists every valid Aether binary found, in priority order: the custom path, `~/.local/share/omarchy-aether/bin/`, `~/Downloads/Aether/`, the plugin's own `bin/`, `~/.local/bin`, `/usr/local/bin`, `/opt/aether`, then each `aether` on `PATH` (`which -a`). Detection runs `<bin> --help` and requires SOCKS5 in the output, which filters out the unrelated `aether` theme tool shipped in some repos. The plugin tracks the upstream core **2.0.0** flag set.

### Core remove

`aether-ctl remove-core <path>` deletes a discovered binary after verifying it is a real Aether core and not the active one. Removing the plugin-managed `~/.local/share/omarchy-aether/bin/` binary deletes the whole managed directory (including its `pt/` transports); any other location is deleted as a single file.

### Persistence

All state lives in two files, both rewritten atomically on every change: `~/.config/omarchy-aether/config.env` (settings) and the PID/log files under `~/.local/share/omarchy-aether/`. Nothing is kept in QML — a reboot restores the exact configuration. The daemon is not auto-started at boot unless the optional systemd unit is enabled.

### Core install

`aether-ctl install` maps `uname -m` to the official release asset (`aether-linux-x86_64.tar.gz`, `aether-linux-arm64.tar.gz`, `aether-linux-armv7.tar.gz`), downloads the pinned release `AETHER_CORE_VERSION` from `github.com/CluvexStudio/Aether/releases/download/<version>`, verifies the archive against the SHA-256 checksums committed in `bin/aether-ctl`, and extracts only the expected members (rejecting absolute paths, `..`, links, and extra members) into `~/.local/share/omarchy-aether/bin/`, then pins it as the active core. If GitHub is unreachable directly while the tunnel is up, it retries through the local SOCKS5 port. Downloads are capped at 64 MiB. Upgrades require bumping `AETHER_CORE_VERSION` and its committed checksums. Core install/remove only touch the core's own files — the managed Zeptun binary in the same directory is preserved.

## System-wide routing (Zeptun)

Optional layer on top of the normal tunnel, off by default:

```
Applications → Zeptun TUN (zeptun0) → Zeptun SOCKS5 client → Aether local SOCKS5 (127.0.0.1:<socks_port>) → Aether tunnel
```

Normal mode never changes; Zeptun runs only on explicit request and only while Aether passes traffic.

### Engine install

`aether-ctl zeptun-install` maps `uname -m` to the standalone binary asset (`zeptun-linux-x86_64`, `zeptun-linux-arm64`, `zeptun-linux-armv7`, `zeptun-linux-i686`), downloads the pinned `ZEPTUN_VERSION` from `github.com/Noisemux/zeptun/releases`, verifies the committed SHA-256, and installs it atomically to `~/.local/share/omarchy-aether/bin/zeptun`. Discovery order: `zeptun_bin` config, that managed path, `~/.local/bin/zeptun`, `/usr/local/bin/zeptun`, then `which -a zeptun`. Every candidate is validated by running `zeptun help` (bounded, 3 s) and checking for the flags this integration relies on; results are cached for 60 s so the status poll never stalls. `zeptun-remove` deletes the managed binary.

### Privileges

System-wide routing requires `CAP_NET_ADMIN` on two binaries:
1. **Zeptun engine**: creates the TUN interface (`zeptun0`) and installs netlink routes and policy rules for table `8891`.
2. **Aether core**: applies `SO_MARK 0xff` to its upstream tunnel sockets for loop prevention so its traffic bypasses the TUN policy rule.

The plugin never runs as root. During `zeptun-install` and on first routing start, `ensure_cap_net_admin` attempts non-interactive `sudo -n setcap` first, then prompts via polkit (`pkexec`) if needed. If neither is available, it surfaces the exact `sudo setcap cap_net_admin+ep` commands. No other privileges are needed; ICMP runs over the TUN file descriptor without raw sockets.

### Lifecycle & watchdog

States: `DISABLED → STOPPED → STARTING → RUNNING → STOPPING → FAILED`, persisted in `data/zeptun.state` (state, pid, timestamp, retries, error).

- `system-route start` refuses to run without: engine present, `CAP_NET_ADMIN` on both binaries, Aether running with `--mark 0xff`, and the SOCKS5 endpoint passing a bounded probe (3 attempts). It generates `data/zeptun.toml` (preset `desktop`, tun `zeptun0`, `auto_route`, table `8891`, fwmark `255`, strict route, baseline + user + endpoint excludes, per-config DNS/UDP), launches the engine, and marks `RUNNING` only after: TUN device visible (≤ 5 s), policy rule for table `8891` present (≤ 2 s), and an unproxied end-to-end check returning `warp=on` (3 attempts). Any failure → teardown → `FAILED` with the engine log's last error line.
- The UI ToggleSwitch tracks true engine state (`RUNNING` / `STARTING`), while Start / Stop / Restart buttons are context-aware and enabled on clean install without manual config prerequisites.
- The watchdog runs inside `status` and `system-route status` (bounded, cheap): detects a dead engine (`RUNNING` with no live, identity-verified PID) → cleans up → bounded retry (crash counter, 2/4/8 s backoff, max 3, reset on success); reaps `STARTING` > 45 s and `STOPPING` > 15 s; and in persistent mode spawns a detached `system-route start` whenever Aether is connected and the engine is `STOPPED`/retryable-`FAILED`.
- `aether-ctl stop` (and any Aether stop path) brings system routing down **first**; `system-route stop` escalates `SIGINT → SIGTERM → SIGKILL` on the identity-verified PID only, sweeps reserved table rules, and removes leftover state.

### Routing & DNS behavior

- Routing uses Zeptun's native `auto_route` against a generated TOML config — the integration writes no route or firewall commands of its own beyond teardown of its two reserved resources: the `zeptun0` interface and policy rules for table `8891`. No global flushes, ever.
- **Loop prevention:** the core is (re)started with `--mark 0xff` (the mark is inert without TUN routing; the panel surfaces this on first activation). Zeptun's policy rules exclude fwmark `255` packets, so the core's upstream sockets exit directly. Additionally the engine's established remote IPs are probed (`ss`, 2 s bound) and excluded, and LAN/link-local/multicast ranges are always excluded.
- **DNS handling & anti-poisoning:** in `systemd_resolved` mode (default), the plugin configures `resolvectl` on the TUN link with routing domain `~.` pointing at the configured `sysroute_dns_servers` (default `1.1.1.1, 8.8.8.8`) and flushes cache on connect/disconnect. This prevents local ISP DNS poisoning (which blocks sites like YouTube and X) without editing `/etc/resolv.conf`. Alternatively, `fake_ip` resolves domains remotely via SOCKS5, and `hijack` routes port 53 into the tunnel.
- **Engine tuning:** `sysroute_preset` toggles Desktop (high performance), Mobile (lightweight), and Server (high concurrency) engine profiles; `sysroute_mtu` allows tuning the interface MTU to mitigate network fragmentation.
- **IPv6:** with `sysroute_ipv6` off, the TUN carries IPv4 only and strict route **blocks** IPv6 rather than leaking it; turn on IPv4+IPv6 to carry both families.
- Zeptun's own log streams to `data/zeptun.log` (rotated at 2 MB, same as the core log); the Live Logs tab switches views.

### Omarchy dev note

`omarchy plugin validate` rejects a plugin directory that is itself a symlink. With the development symlink at `~/.config/omarchy/plugins/cluvex.aether`, run the validator against the real working tree instead. Never keep a second copy of the plugin inside `~/.config/omarchy/plugins/` — two manifests with the same id collide in the registry scan and the shell silently loads whichever sorts last.

## Omarchy integration

- **Shell settings schema:** `manifest.json` declares `socksPort`, `httpProxyPort`, and `customBinaryPath` for Omarchy's settings UI. The current `Service.qml` does not read those values back into the ctl config; `config.env` (via `aether-ctl set`) is the effective source of truth. Treat the schema as a preview of intended integration.
- **IPC:** `IpcHandler` target `cluvex.aether` exposes `open`, `close`, `toggle`, `show`, `hide`, `refresh`, `start`, `stop`, `restart`, `status`. Note `toggle` toggles the *panel*, not the tunnel — the tunnel is `start`/`stop`/`restart`.
- **Bar section:** default `right`; move with `omarchy bar move cluvex.aether --section left|center|right`.

## Development

```sh
# Manifest + layout validation
omarchy plugin validate ~/.config/omarchy/plugins/cluvex.aether

# QML lint against the installed shell imports
qmllint -I "$OMARCHY_PATH/shell" \
  ~/.config/omarchy/plugins/cluvex.aether/Panel.qml \
  ~/.config/omarchy/plugins/cluvex.aether/AetherIcon.qml

# QML under ~/.config/omarchy/plugins hot-reloads; force discovery if needed:
omarchy-shell shell rescanPlugins
omarchy restart shell

# Exercise the ctl layer directly
~/.config/omarchy/plugins/cluvex.aether/bin/aether-ctl status | jq
~/.config/omarchy/plugins/cluvex.aether/bin/aether-ctl set-protocol wg 0
~/.config/omarchy/plugins/cluvex.aether/bin/aether-ctl set-protocol masque 0
```

Before sharing, test: bar icon states across connect/disconnect/missing-core, all three tabs, mouse buttons, Escape close, IPC commands, plugin disable/re-enable, shell restart, and removal.

## Publishing checklist

Per the [Omarchy publishing guide](https://plugins.omarchy.org/publish.html) and [development guide](https://plugins.omarchy.org/develop.html):

- [x] Valid `manifest.json` in repository root (`omarchy plugin validate` passes)
- [x] `README.md` with install, usage, requirements, security notes
- [x] `LICENSE` (MIT)
- [x] Safe install and removal (no root, documented teardown)
- [x] Public GitHub repository under the owner's account (`https://github.com/IHosseini083/aether-core-omarchy`)
- [x] Optional `preview.png` screenshot in the root (referenced from `README.md`, centered, with the badge beneath it)
- [ ] Submit via the [marketplace issue form](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml)

The plugin `id` is `cluvex.aether` — historical (named after the upstream core) and kept for upgrade compatibility; the `author` field correctly credits the plugin author. Third-party IDs cannot use the `omarchy.*` namespace.

## Limitations

- Core installs are pinned to `AETHER_CORE_VERSION` in `bin/aether-ctl` (checksum-verified); newer upstream releases require a plugin update.
- Live Logs is polling (last 100 lines), not a streamed tail.
- Tor support depends on the installed core being built with the `tor` cargo feature; the plugin passes the flags regardless.
- Env-only tuning without a flag (`AETHER_TOR_STALL_SECS`, `AETHER_TOR_CHECK`, `AETHER_TOR_LOG`, …) is not exposed; `AETHER_TOR_COUNTRY` is.
- Only Linux releases are installed automatically; Windows/macOS assets are ignored.
