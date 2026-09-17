# omarchy-aether — Reference

Deep documentation for the `cluvex.aether` Omarchy shell plugin. For a quick start see [README.md](README.md). For the Aether core itself, see the [upstream docs](https://github.com/CluvexStudio/Aether/blob/main/Docs/DOCS.en.md) — this document covers the plugin.

## Architecture

```
~/.config/omarchy/plugins/cluvex.aether/
├── manifest.json        # Plugin contract (kind: bar-widget)
├── Panel.qml            # Entry point: bar button + popup panel (3 tabs)
├── Service.qml          # Quickshell Process/Timer layer driving aether-ctl
├── Model.js             # JSON parsing, formatting, log colorization
├── AetherIcon.qml       # Vector shield icon (bar + hero), state-aware
├── bin/aether-ctl       # Bash CLI: status, lifecycle, config, install
└── systemd/aether.service  # Optional user unit (uses `aether-ctl foreground`)
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
aether-ctl install                    # download latest official release
aether-ctl set <key> <val>            # update one setting (hot-restarts)
aether-ctl set-protocol <proto> <0|1> # atomic protocol + h2 switch
aether-ctl cores                      # discovered core binaries
aether-ctl logs [N]                   # last N log lines (default 60)
aether-ctl clear-logs|clear-cache     # housekeeping (cache = lastconn/secondary)
aether-ctl probe                      # raw curl trace through the tunnel
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
  "access_email": "", "discovered_cores": ["/path/to/aether"]
}
```

`discovered_cores` lists every valid Aether binary found (custom path, plugin bin dir, `~/Downloads/Aether`, `~/.local/bin`, PATH, common prefixes) — detection runs `<bin> --help` and requires SOCKS5 in the output, which filters out the unrelated `aether` theme tool shipped in some repos.

### Core install

`aether-ctl install` maps `uname -m` to the official release asset (`aether-linux-x86_64.tar.gz`, `aether-linux-arm64.tar.gz`, `aether-linux-armv7.tar.gz`), downloads from `github.com/CluvexStudio/Aether/releases/latest`, extracts to `~/.local/share/omarchy-aether/bin/`, and pins it as the active core. If GitHub is unreachable directly while the tunnel is up, it retries through the local SOCKS5 port. Downloads are not checksum-verified.

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
- [ ] Public GitHub repository under the owner's account
- [ ] Optional `preview.png` screenshot in the root
- [ ] Submit via the [marketplace issue form](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml)

The plugin `id` is `cluvex.aether` — historical (named after the upstream core) and kept for upgrade compatibility; the `author` field correctly credits the plugin author. Third-party IDs cannot use the `omarchy.*` namespace.

## Limitations

- Downloads of release archives are not checksum-verified.
- Live Logs is polling (last 100 lines), not a streamed tail.
- Tor support depends on the installed core being built with the `tor` cargo feature; the plugin passes the flags regardless.
- Env-only tuning without a flag (`AETHER_TOR_STALL_SECS`, `AETHER_TOR_CHECK`, `AETHER_TOR_LOG`, …) is not exposed; `AETHER_TOR_COUNTRY` is.
- Only Linux releases are installed automatically; Windows/macOS assets are ignored.
