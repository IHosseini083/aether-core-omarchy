import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Item {
  id: root

  property var settings: ({})

  // Core status
  property bool installed: false
  property string binary: ""
  property string binaryVersion: ""
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
  property bool systemProxy: false

  // Configuration
  property string protocol: "masque"
  property string scan: "balanced"
  property string noize: "firewall"
  property string ipMode: "v4"
  property bool h2: false
  property bool fragment: false
  property bool quickReconnect: true
  property bool markEnabled: false

  // Logs & Operations
  property string logsText: ""
  property bool refreshing: false
  property bool fetchingLogs: false
  property bool installing: false
  property bool actionInProgress: false
  property string actionStatus: ""
  property string lastError: ""
  property int phraseIndex: 0

  readonly property string ctlPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/cluvex.aether/bin/aether-ctl"
  readonly property string heroPhrase: Model.getHeroPhrase(phraseIndex)
  readonly property string statusSummary: !installed ? "Aether core not found" : (!running ? "Disconnected" : (connected ? "Connected · " + Model.formatColo(colo, loc) : "Connecting to WARP…"))

  function refresh() {
    if (statusProcess.running) return
    refreshing = true
    _statusOutput = ""
    statusProcess.command = [ctlPath, "status"]
    statusProcess.running = true
  }

  function fetchLogs() {
    if (logsProcess.running) return
    fetchingLogs = true
    _logsOutput = ""
    logsProcess.command = [ctlPath, "logs", "45"]
    logsProcess.running = true
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

  function toggleSystemProxy() {
    runAction(["proxy", "toggle"], "Toggling system proxy…")
  }

  function installAether() {
    if (installProcess.running) return
    installing = true
    actionStatus = "Downloading and installing official Aether core…"
    _installOutput = ""
    installProcess.command = [ctlPath, "install"]
    installProcess.running = true
  }

  function setConfig(key, value) {
    runAction(["set", key, String(value)], "Updating setting…")
  }

  function setCore(path) {
    runAction(["set", "bin", String(path)], "Switching core binary…")
  }

  function clearLogs() {
    runAction(["clear-logs"], "Clearing logs…")
    logsText = ""
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

  function copyExportEnv() {
    copyToClipboard(Model.exportEnv(proxyPort), "environment variables")
  }

  function copyCurlSnippet() {
    copyToClipboard(Model.curlSnippet(proxyPort), "curl command")
  }

  function copyAllLogs() {
    copyToClipboard(logsText, "Aether logs")
  }

  property string _statusOutput: ""
  property string _logsOutput: ""
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
        root.installed = data.installed
        root.binary = data.binary
        root.binaryVersion = data.binary_version
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
        root.systemProxy = data.system_proxy
        root.protocol = data.protocol
        root.scan = data.scan
        root.noize = data.noize
        root.ipMode = data.ip_mode
        root.h2 = data.h2
        root.fragment = data.fragment
        root.quickReconnect = data.quick_reconnect
        root.markEnabled = data.mark_enabled
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
    onExited: function(code) {
      root.installing = false
      if (code === 0) {
        root.actionStatus = "Installation complete! Core ready."
        resetStatusTimer.restart()
      } else {
        root.lastError = "Install failed. Check internet connection."
      }
      root.refresh()
    }
  }

  Timer {
    id: pollTimer
    interval: root.running ? 6000 : 15000
    running: true
    repeat: true
    onTriggered: {
      root.refresh()
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
