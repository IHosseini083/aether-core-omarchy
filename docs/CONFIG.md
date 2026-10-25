# Aether Configuration & State Management

Technical guide to configuration persistence, migrations, file formats, and CLI subcommands in the `cluvex.aether` Omarchy plugin.

---

## Configuration File: `config.env`

All settings configured via the popup panel or CLI are persisted in:

```
~/.config/omarchy-aether/config.env
```

### Format

The configuration file is formatted as standard shell-compatible key-value assignments:

```sh
# Aether core & transport
PROTOCOL="masque"
H2="0"
SCAN="balanced"
NOIZE="firewall"
IP_MODE="v4"
SOCKS_PORT="1819"
HTTP_PROXY_PORT="0"

# TLS & Fingerprint Evasion (Core v2.4.0)
FRAGMENT="0"
FRAGMENT_SIZE="8-16"
FRAGMENT_DELAY="2-10"
ECH="off"
ENABLE_ECH_GREASE="0"
TLS_VERIFY="auto"

# System-wide routing (Zeptun v1.1.3)
SYSROUTE_ENABLED="0"
SYSROUTE_PRESET="desktop"
SYSROUTE_MTU="1500"
SYSROUTE_DNS_MODE="systemd_resolved"
SYSROUTE_DNS_SERVERS="1.1.1.1, 8.8.8.8"
SYSROUTE_FAKE_IP="0"
SYSROUTE_UDP_MODE="udp"
```

### File System Permissions

The plugin enforces strict UNIX permissions on all configuration directories and files:

- Configuration Directory: `~/.config/omarchy-aether/` (`0700` / `drwx------`)
- Configuration File: `config.env` (`0600` / `-rw-------`)
- State & Working Directory: `~/.local/share/omarchy-aether/` (`0700` / `drwx------`)

This guarantees that local non-root users cannot read Zero Trust tokens, service secrets, or customized bridge lists.

---

## Configuration Migrations

When `bin/aether-ctl` loads an existing configuration, it executes automatic migrations:

1. **Deprecated Flag Cleanup**:
   - `API_FRAGMENT` (removed upstream in v2.4.0) is safely ignored and omitted from daemon startup flags.
   - `FRAGMENT` is treated as a clean boolean: `1` passes `--fragment`, while `0` completely omits the flag (preventing "unknown option: --no-fragment" crashes on v2.4.0).
2. **Zeptun Presets**:
   - Invalid `SYSROUTE_PRESET` values fall back to `desktop` to guarantee proper interface initialization.
3. **Atomic Rewrites**:
   - Updates are written to a temporary file (`config.env.tmp.$PID`) and moved into place with `mv -f` to prevent corrupted state on sudden power loss or process kill.

---

## CLI Management Subcommands

The `bin/aether-ctl` helper exposes rich configuration subcommands:

### 1. `get`

Retrieve the current value of a configuration key:

```sh
bin/aether-ctl get protocol
# masque

bin/aether-ctl get fragment
# 0
```

### 2. `set`

Update a setting, validate input, save to `config.env`, and hot-restart the tunnel if running:

```sh
bin/aether-ctl set protocol gool
bin/aether-ctl set fragment 1
bin/aether-ctl set fragment_size "8-16"
bin/aether-ctl set sysroute_fake_ip 1
```

### 3. `reset`

Reset one setting (or all settings) back to factory defaults:

```sh
# Reset a single field
bin/aether-ctl reset fragment

# Reset every option to default values
bin/aether-ctl reset all   # custom core and Zeptun binary paths are kept
```

### 4. `preset`

Atomically apply a complete operational profile:

```sh
bin/aether-ctl preset default
bin/aether-ctl preset stealth
bin/aether-ctl preset speed
bin/aether-ctl preset tor_multihop
bin/aether-ctl preset psiphon_bypass
```

### 5. `export`

Export configuration to standard output or a destination file:

```sh
# Print to stdout
bin/aether-ctl export

# Export to a backup file
bin/aether-ctl export ~/backup-aether-config.env
```

### 6. `import`

Import and apply a configuration file. Only `AETHER_CFG_NAME=value` lines are accepted, with values that are empty, single-quoted, or backslash-escaped (the format `export` writes). Command substitution, variable expansion and `;` are rejected before `config.env` is replaced:

```sh
bin/aether-ctl import ~/backup-aether-config.env
```

---

## Secret Handling & Environment Injection

To prevent leaking sensitive Zero Trust credentials in process listings or `/proc/*/cmdline`:

- Zero Trust tokens (`access_token`, `access_id`, `access_secret`, `access_email`) are **never** passed as CLI flags.
- `bin/aether-ctl` injects them as runtime environment variables directly to the spawned child process:
  - `AETHER_ACCESS_TOKEN`
  - `AETHER_ACCESS_CLIENT_ID`
  - `AETHER_ACCESS_CLIENT_SECRET`
  - `AETHER_ACCESS_EMAIL`
- Status queries returned by `bin/aether-ctl status` redact secrets, exposing boolean flags (`has_access_id`, `has_access_secret`, `has_access_token`) instead of plaintext values.
- UI fields for secrets show masking (`••••••••`) and allow clearing or replacement without displaying the secret on screen.
