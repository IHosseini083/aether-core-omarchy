import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Item {
  id: root

  // Core status
  property string pluginVersion: "1.8.0"
  property bool installed: false
  property string binary: ""
  property string binaryVersion: ""
  property string core_pinned_version: ""
  property bool core_update_available: false
  property bool hasCapNetAdmin: false
  property var discoveredCores: []
  property bool running: false
  property string pid: ""
  property bool connected: false

  // Metrics
  property string ip: ""
  property string colo: ""
  property string loc: ""
  property string warp: ""
  property int latency: 0
  property int proxyPort: 1819
  property int httpProxyPort: 0
  property int socks_port: 1819
  property int http_proxy_port: 0
  property string fragment_size: "16-32"
  property string fragment_delay: "2-10"
  property string extra_args: ""

  // Configuration — property names intentionally mirror the ctl config keys
  property string protocol: "masque"
  property string scan: "balanced"
  property string noize: "firewall"
  property string ip_mode: "v4"
  property bool h2: false
  property bool fragment: false
  property bool quick_reconnect: true
  property bool mark_enabled: false
  property bool no_quic_v2: false
  property string ech: "off"
  property bool no_data_check: false
  property int keepalive: 5
  property string peer: ""
  property string wiw_outer: ""
  property string wiw_inner: ""
  property string mim_outer: ""
  property string mim_inner: ""
  property string dns: ""
  property string team: ""
  property bool gateway: false
  property string upstream: ""
  property string route_direct: ""
  property string route_block: ""
  property string log_level: "info"
  property string wg_peer: ""
  property string h2_peer: ""
  property bool no_profile_retry: false
  property string validate_secs: ""
  property string startup_secs: ""
  property string reconnect_secs: ""
  property string perf: ""
  property string tls_groups: ""
  property string routes_file: ""
  property string tor_bind: ""
  property string tor_http: ""
  property string tor_dir: ""
  property string tor_bridges: ""
  property string tor_bridge: ""
  property string tor_bridge_file: ""
  property string tor_relays: ""
  property string tor_relay_ports: ""
  property string tor_pt: ""
  property string tor_pt_dir: ""
  property string tor_country: ""
  property string psiphon_mode: "auto"
  property string psiphon_region: ""
  property string psiphon_bind: ""
  property string psiphon_http: ""
  property string psiphon_config: ""
  property string psiphon_cdn_ips: ""
  property string psiphon_cdn_sni: ""
  property string exit_loc: ""
  property string exit_loc_secs: ""
  property bool stats_enabled: false
  property string stats_secs: ""
  property string access_id: ""
  property string access_secret: ""
  property string access_token: ""
  property string access_email: ""

  // Zeptun system-wide routing (optional TUN engine)
  property string zeptun_state: "DISABLED"
  property bool zeptun_available: false
  property string zeptun_binary: ""
  property string zeptun_version: ""
  property string zeptun_pinned_version: ""
  property bool zeptun_update_available: false
  property string zeptun_pid: ""
  property string zeptun_tun: "zeptun0"
  property bool zeptun_has_cap_net_admin: false
  property int zeptun_retries: 0
  property int zeptun_uptime_s: 0
  property string zeptun_error: ""
  property bool sysroute_enabled: false
  property bool sysroute_ipv6: false
  property string sysroute_dns_mode: "systemd_resolved"
  property string sysroute_dns_servers: "1.1.1.1, 8.8.8.8"
  property bool sysroute_fake_ip: false
  property bool sysroute_dns_hijack: true
  property string sysroute_preset: "desktop"
  property int sysroute_mtu: 1500
  property string sysroute_udp_mode: "udp"
  property bool sysroute_persistent: false
  property string sysroute_exclude: ""
  property string sysroute_exclude_uids: ""
  property bool sysroute_strict_route: true
  property bool sysroute_auto_redirect: false
  property string sysroute_stack_mode: "userspace"
  property string sysroute_congestion: "cubic"
  property bool sysroute_tcp_fastopen: false
  property bool sysroute_offload: true
  property string sysroute_io_backend: "auto"
  property string sysroute_log_level: "warn"

  // Logs & Operations
  property string logsText: ""
  property string logsHtml: ""
  property string zeptunLogsText: ""
  property string zeptunLogsHtml: ""
  property string logsView: "aether" // "aether" | "zeptun"
  property bool autoTailLogs: true
  property bool refreshing: false
  property bool fetchingLogs: false
  property bool installing: false
  property bool actionInProgress: false
  property string actionStatus: ""
  property string lastError: ""
  property int phraseIndex: 0

  readonly property string ctlPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/cluvex.aether/bin/aether-ctl"
  readonly property string heroPhrase: Model.getHeroPhrase(phraseIndex)
  readonly property string statusSummary: !installed ? "Aether core not found" : (!running ? "Disconnected" : (connected ? "Connected · " + Model.formatColo(colo, loc) + (zeptun_state === "RUNNING" ? " · TUN" : "") : "Connecting to WARP…"))
  readonly property string zeptunStatusSummary: Model.zeptunStateLabel(zeptun_state, zeptun_error, zeptun_available)

  function refresh() {
    if (statusProcess.running) return
    refreshing = true
    _statusOutput = ""
    statusProcess.command = [ctlPath, "status"]
    statusProcess.running = true
  }

  function fetchLogs() {
    if (logsView === "zeptun") {
      if (zeptunLogsProcess.running) return
      fetchingLogs = true
      _zeptunLogsOutput = ""
      zeptunLogsProcess.command = [ctlPath, "zeptun-logs", "100"]
      zeptunLogsProcess.running = true
      return
    }
    if (logsProcess.running) return
    fetchingLogs = true
    _logsOutput = ""
    logsProcess.command = [ctlPath, "logs", "100"]
    logsProcess.running = true
  }

  function setLogsView(view) {
    if (logsView === view) return
    logsView = view
    fetchLogs()
  }

  function toggleAether() {
    runAction(["toggle"], running ? "Disconnecting…" : "Connecting…")
  }

  function startAether() {
    runAction(["start"], "Starting tunnel…")
  }

  function stopAether() {
    runAction(["stop"], "Stopping tunnel…")
  }

  function restartAether() {
    runAction(["restart"], "Restarting tunnel…")
  }

  // All system-route actions reuse runAction (async Process, bounded ctl).
  function systemRouteStart() {
    runAction(["system-route", "start"], "Starting system routing…")
  }

  function systemRouteStop() {
    runAction(["system-route", "stop"], "Stopping system routing…")
  }

  function systemRouteRestart() {
    runAction(["system-route", "restart"], "Restarting system routing…")
  }

  function toggleSystemRoute() {
    if (zeptun_state === "RUNNING" || zeptun_state === "STARTING") {
      systemRouteStop()
    } else {
      systemRouteStart()
    }
  }

  function setSysrouteEnabled(enabled) {
    setConfig("sysroute_enabled", enabled ? "1" : "0")
  }

  function installAether() {
    if (installProcess.running) return
    installing = true
    actionStatus = "Downloading official Aether release from GitHub…"
    lastError = ""
    _installOutput = ""
    installProcess.command = [ctlPath, "install"]
    installProcess.running = true
  }

  function updateAetherCore() {
    installAether()
  }

  function updateZeptun() {
    runAction(["zeptun-install"], "Updating Zeptun to " + (zeptun_pinned_version || "latest pinned") + "…")
  }

  function setConfig(key, value) {
    runAction(["set", key, String(value)], "Applying " + key + "…")
  }

  // Atomic protocol switch: one ctl invocation, no dropped updates
  function setProtocol(protocol, h2) {
    runAction(["set-protocol", protocol, h2 ? "1" : "0"], "Switching transport…")
  }

  function setCore(path) {
    runAction(["set", "bin", String(path)], "Activating selected core…")
  }

  function removeCore(path) {
    if (path) {
      runAction(["remove-core", String(path)], "Removing core…")
    } else {
      runAction(["remove-core"], "Removing core…")
    }
  }

  function removeZeptun(path) {
    if (path && path !== "zeptun") {
      runAction(["zeptun-remove", String(path)], "Removing Zeptun…")
    } else {
      runAction(["zeptun-remove"], "Removing Zeptun…")
    }
  }

  function clearLogs() {
    if (logsView === "zeptun") {
      runAction(["zeptun-clear-logs"], "Clearing zeptun logs…")
      zeptunLogsText = ""
      zeptunLogsHtml = Model.colorizeLogsToHtml("", Color.accent, Color.urgent)
    } else {
      runAction(["clear-logs"], "Clearing logs…")
      logsText = ""
      logsHtml = Model.colorizeLogsToHtml("", Color.accent, Color.urgent)
    }
  }

  function clearCache() {
    runAction(["clear-cache"], "Clearing gateway cache…")
  }

  function runAction(args, statusMsg) {
    if (actionProcess.running) return
    actionInProgress = true
    actionStatus = statusMsg || "Applying…"
    lastError = ""
    _actionOutput = ""
    var cmd = [ctlPath]
    for (var i = 0; i < args.length; i++) {
      cmd.push(args[i])
    }
    actionProcess.command = cmd
    actionProcess.running = true
  }

  function copyToClipboard(text, label) {
    var val = String(text || "")
    if (val === "") return
    Quickshell.execDetached(["bash", "-c", "printf %s " + Util.shellQuote(val) + " | wl-copy"])
    actionStatus = "Copied " + (label || "text") + " to clipboard"
    resetStatusTimer.restart()
  }

  function copySocksUrl() {
    copyToClipboard(Model.socksUrl(proxyPort), "SOCKS5 URL")
  }

  function copyHttpProxyUrl() {
    if (httpProxyPort > 0) {
      copyToClipboard(Model.httpProxyUrl(httpProxyPort), "HTTP Proxy URL")
    }
  }

  function copyTorSocksUrl() {
    copyToClipboard(Model.torProxyUrl(tor_bind), "Tor SOCKS5 URL")
  }

  function copyTorHttpProxyUrl() {
    if (tor_http !== "") {
      copyToClipboard(Model.torHttpProxyUrl(tor_http), "Tor HTTP URL")
    }
  }

  function copyPsiphonSocksUrl() {
    copyToClipboard(Model.psiphonProxyUrl(psiphon_bind), "Psiphon SOCKS5 URL")
  }

  function copyPsiphonHttpProxyUrl() {
    if (psiphon_http !== "") {
      copyToClipboard(Model.psiphonHttpProxyUrl(psiphon_http), "Psiphon HTTP URL")
    }
  }

  function toggleStats() {
    setConfig("stats", stats_enabled ? "0" : "1")
  }

  function setExitLoc(spec) {
    setConfig("exit_loc", spec)
  }

  function copyExportEnv() {
    copyToClipboard(Model.exportEnv(proxyPort), "environment variables")
  }

  function copyCurlSnippet() {
    copyToClipboard(Model.curlSnippet(proxyPort), "curl command")
  }

  function copyAllLogs() {
    copyToClipboard(logsView === "zeptun" ? zeptunLogsText : logsText, logsView === "zeptun" ? "Zeptun logs" : "Aether logs")
  }

  property string _statusOutput: ""
  property string _logsOutput: ""
  property string _zeptunLogsOutput: ""
  property string _actionOutput: ""
  property string _installOutput: ""

  Process {
    id: statusProcess
    stdout: SplitParser {
      onRead: function(line) {
        root._statusOutput += line
      }
    }
    onExited: function(code) {
      root.refreshing = false
      if (code === 0 && root._statusOutput.length > 0) {
        var data = Model.parseStatus(root._statusOutput)
        root.pluginVersion = data.plugin_version
        root.installed = data.installed
        root.binary = data.binary
        root.binaryVersion = data.binary_version
        root.core_pinned_version = data.core_pinned_version
        root.core_update_available = data.core_update_available
        root.hasCapNetAdmin = data.has_cap_net_admin
        root.discoveredCores = data.discovered_cores
        root.running = data.running
        root.pid = data.pid
        root.connected = data.connected
        root.ip = data.ip
        root.colo = data.colo
        root.loc = data.loc
        root.warp = data.warp
        root.latency = data.latency_ms
        root.proxyPort = data.proxy_port
        root.httpProxyPort = data.http_proxy_port
        root.socks_port = data.proxy_port
        root.http_proxy_port = data.http_proxy_port
        root.fragment_size = data.fragment_size
        root.fragment_delay = data.fragment_delay
        root.extra_args = data.extra_args
        root.protocol = data.protocol
        root.scan = data.scan
        root.noize = data.noize
        root.ip_mode = data.ip_mode
        root.h2 = data.h2
        root.fragment = data.fragment
        root.quick_reconnect = data.quick_reconnect
        root.mark_enabled = data.mark_enabled
        root.no_quic_v2 = data.no_quic_v2
        root.ech = data.ech
        root.no_data_check = data.no_data_check
        root.keepalive = data.keepalive
        root.peer = data.peer
        root.wiw_outer = data.wiw_outer
        root.wiw_inner = data.wiw_inner
        root.mim_outer = data.mim_outer
        root.mim_inner = data.mim_inner
        root.dns = data.dns
        root.team = data.team
        root.gateway = data.gateway === true
        root.upstream = data.upstream
        root.route_direct = data.route_direct
        root.route_block = data.route_block
        root.log_level = data.log_level
        root.wg_peer = data.wg_peer
        root.h2_peer = data.h2_peer
        root.no_profile_retry = data.no_profile_retry
        root.validate_secs = data.validate_secs
        root.startup_secs = data.startup_secs
        root.reconnect_secs = data.reconnect_secs
        root.perf = data.perf
        root.tls_groups = data.tls_groups
        root.routes_file = data.routes_file
        root.tor_bind = data.tor_bind
        root.tor_http = data.tor_http
        root.tor_dir = data.tor_dir
        root.tor_bridges = data.tor_bridges
        root.tor_bridge = data.tor_bridge
        root.tor_bridge_file = data.tor_bridge_file
        root.tor_relays = data.tor_relays
        root.tor_relay_ports = data.tor_relay_ports
        root.tor_pt = data.tor_pt
        root.tor_pt_dir = data.tor_pt_dir
        root.tor_country = data.tor_country
        root.psiphon_mode = data.psiphon_mode
        root.psiphon_region = data.psiphon_region
        root.psiphon_bind = data.psiphon_bind
        root.psiphon_http = data.psiphon_http
        root.psiphon_config = data.psiphon_config
        root.psiphon_cdn_ips = data.psiphon_cdn_ips
        root.psiphon_cdn_sni = data.psiphon_cdn_sni
        root.exit_loc = data.exit_loc
        root.exit_loc_secs = data.exit_loc_secs
        root.stats_enabled = data.stats_enabled
        root.stats_secs = data.stats_secs
        root.access_id = data.access_id
        root.access_secret = data.access_secret
        root.access_token = data.access_token
        root.access_email = data.access_email
        root.zeptun_state = data.zeptun_state
        root.zeptun_available = data.zeptun_available
        root.zeptun_binary = data.zeptun_binary
        root.zeptun_version = data.zeptun_version
        root.zeptun_pinned_version = data.zeptun_pinned_version
        root.zeptun_update_available = data.zeptun_update_available
        root.zeptun_pid = data.zeptun_pid
        root.zeptun_tun = data.zeptun_tun
        root.zeptun_has_cap_net_admin = data.zeptun_has_cap_net_admin
        root.zeptun_retries = data.zeptun_retries
        root.zeptun_uptime_s = data.zeptun_uptime_s
        root.zeptun_error = data.zeptun_error
        root.sysroute_enabled = data.sysroute_enabled
        root.sysroute_ipv6 = data.sysroute_ipv6
        root.sysroute_dns_mode = data.sysroute_dns_mode
        root.sysroute_dns_servers = data.sysroute_dns_servers
        root.sysroute_fake_ip = data.sysroute_fake_ip
        root.sysroute_dns_hijack = data.sysroute_dns_hijack
        root.sysroute_preset = data.sysroute_preset
        root.sysroute_mtu = data.sysroute_mtu
        root.sysroute_udp_mode = data.sysroute_udp_mode
        root.sysroute_persistent = data.sysroute_persistent
        root.sysroute_exclude = data.sysroute_exclude
        root.sysroute_exclude_uids = data.sysroute_exclude_uids
        root.sysroute_strict_route = data.sysroute_strict_route
        root.sysroute_auto_redirect = data.sysroute_auto_redirect
        root.sysroute_stack_mode = data.sysroute_stack_mode
        root.sysroute_congestion = data.sysroute_congestion
        root.sysroute_tcp_fastopen = data.sysroute_tcp_fastopen
        root.sysroute_offload = data.sysroute_offload
        root.sysroute_io_backend = data.sysroute_io_backend
        root.sysroute_log_level = data.sysroute_log_level
      }
    }
  }

  Process {
    id: logsProcess
    stdout: SplitParser {
      onRead: function(line) {
        root._logsOutput += line + "\n"
      }
    }
    onExited: function(code) {
      root.fetchingLogs = false
      if (code === 0) {
        root.logsText = Model.cleanLogLines(root._logsOutput.trim())
        root.logsHtml = Model.colorizeLogsToHtml(root._logsOutput.trim(), Color.accent, Color.urgent)
      }
    }
  }

  Process {
    id: zeptunLogsProcess
    stdout: SplitParser {
      onRead: function(line) {
        root._zeptunLogsOutput += line + "\n"
      }
    }
    onExited: function(code) {
      root.fetchingLogs = false
      if (code === 0) {
        root.zeptunLogsText = Model.cleanLogLines(root._zeptunLogsOutput.trim())
        root.zeptunLogsHtml = Model.colorizeLogsToHtml(root._zeptunLogsOutput.trim(), Color.accent, Color.urgent)
      }
    }
  }

  Process {
    id: actionProcess
    stdout: SplitParser {
      onRead: function(line) {
        root._actionOutput += line
      }
    }
    stderr: SplitParser {
      onRead: function(line) {
        root.lastError += line
      }
    }
    onExited: function(code) {
      root.actionInProgress = false
      if (code === 0) {
        var out = root._actionOutput.trim()
        if (out.length > 0) root.actionStatus = out
        resetStatusTimer.restart()
      } else {
        if (root.lastError === "") root.lastError = root._actionOutput.trim() || "Operation failed"
      }
      root.refresh()
      root.fetchLogs()
    }
  }

  Process {
    id: installProcess
    stdout: SplitParser {
      onRead: function(line) {
        root._installOutput += line
      }
    }
    stderr: SplitParser {
      onRead: function(line) {
        root.lastError += line
      }
    }
    onExited: function(code) {
      root.installing = false
      if (code === 0) {
        root.actionStatus = "Installation complete! Aether core is ready."
        resetStatusTimer.restart()
      } else {
        root.lastError = "Install failed: " + (root.lastError || "Check network connection")
      }
      root.refresh()
    }
  }

  Timer {
    id: pollTimer
    interval: root.running ? 4000 : 12000
    running: true
    repeat: true
    onTriggered: {
      root.refresh()
      if (root.autoTailLogs) {
        root.fetchLogs()
      }
    }
  }

  Timer {
    id: phraseTimer
    interval: 5000
    running: root.connected
    repeat: true
    onTriggered: root.phraseIndex = (root.phraseIndex + 1) % Model.activePhrases.length
  }

  Timer {
    id: resetStatusTimer
    interval: 4000
    repeat: false
    onTriggered: root.actionStatus = ""
  }

  Component.onCompleted: {
    refresh()
    fetchLogs()
  }
}
