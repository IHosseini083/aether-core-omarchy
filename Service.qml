import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Item {
  id: root

  property var settings: ({})

  property bool installed: false
  property bool running: false
  property bool connected: false
  property string binary: ""
  property string ip: ""
  property string colo: ""
  property string loc: ""
  property string warp: ""
  property int latency: 0
  property int proxyPort: 1819
  property bool systemProxy: false

  property string protocol: "masque"
  property string scan: "balanced"
  property string noize: "firewall"
  property string ipMode: "v4"
  property bool h2: false
  property bool fragment: false
  property bool quickReconnect: true

  property bool refreshing: false
  property bool installing: false
  property bool actionInProgress: false
  property string actionStatus: ""
  property string lastError: ""
  property int phraseIndex: 0

  readonly property string ctlPath: Quickshell.env("HOME") + "/.config/omarchy/plugins/cluvex.aether/bin/aether-ctl"
  readonly property string heroPhrase: Model.getHeroPhrase(phraseIndex)
  readonly property string statusSummary: !installed ? "Aether not installed" : (!running ? "Disconnected" : (connected ? "Protected · " + Model.formatColo(colo, loc) : "Connecting…"))

  function refresh() {
    if (statusProcess.running) return
    refreshing = true
    _statusOutput = ""
    statusProcess.command = [ctlPath, "status"]
    statusProcess.running = true
  }

  function toggleAether() {
    runAction(["toggle"], "Toggling Aether…")
  }

  function startAether() {
    runAction(["start"], "Starting Aether…")
  }

  function stopAether() {
    runAction(["stop"], "Stopping Aether…")
  }

  function restartAether() {
    runAction(["restart"], "Restarting Aether…")
  }

  function toggleSystemProxy() {
    runAction(["proxy", "toggle"], "Toggling system proxy…")
  }

  function installAether() {
    if (installProcess.running) return
    installing = true
    actionStatus = "Downloading and installing Aether…"
    _installOutput = ""
    installProcess.command = [ctlPath, "install"]
    installProcess.running = true
  }

  function setConfig(key, value) {
    runAction(["set", key, String(value)], "Updating setting…")
  }

  function runAction(args, statusMsg) {
    if (actionProcess.running) return
    actionInProgress = true
    actionStatus = statusMsg || "Applying…"
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

  function copyExportEnv() {
    copyToClipboard(Model.exportEnv(proxyPort), "environment export")
  }

  function copyCurlSnippet() {
    copyToClipboard(Model.curlSnippet(proxyPort), "curl command")
  }

  property string _statusOutput: ""
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
        root.running = data.running
        root.connected = data.connected
        root.ip = data.ip
        root.colo = data.colo
        root.loc = data.loc
        root.warp = data.warp
        root.latency = data.latency_ms
        root.proxyPort = data.proxy_port
        root.systemProxy = data.system_proxy
        if (data.protocol) root.protocol = data.protocol
        if (data.scan) root.scan = data.scan
        if (data.noize) root.noize = data.noize
        if (data.ip_mode) root.ipMode = data.ip_mode
        root.h2 = data.h2 === true
        root.fragment = data.fragment === true
        root.quickReconnect = data.quick_reconnect === true
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
    onExited: function(code) {
      root.actionInProgress = false
      if (code === 0) {
        root.actionStatus = root._actionOutput.trim()
        resetStatusTimer.restart()
      } else {
        root.lastError = "Action failed"
      }
      root.refresh()
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
        root.actionStatus = "Installation successful!"
        resetStatusTimer.restart()
      } else {
        root.lastError = "Installation failed. Check internet connection."
      }
      root.refresh()
    }
  }

  Timer {
    id: pollTimer
    interval: root.running ? 8000 : 20000
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Timer {
    id: phraseTimer
    interval: 6000
    running: root.connected
    repeat: true
    onTriggered: root.phraseIndex = (root.phraseIndex + 1) % Model.activePhrases.length
  }

  Timer {
    id: resetStatusTimer
    interval: 3500
    repeat: false
    onTriggered: root.actionStatus = ""
  }

  Component.onCompleted: {
    refresh()
  }
}
