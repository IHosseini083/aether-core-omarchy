import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model

Panel {
  id: root

  moduleName: "cluvex.aether"
  ipcTarget: "cluvex.aether"
  manageIpc: false

  property string currentTab: "controls" // "controls" | "settings" | "logs"

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color accent: Color.accent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color barIconColor: aether.connected ? accent : (aether.running ? foreground : dim)

  readonly property string icon: {
    if (!aether.installed || aether.lastError !== "") return "\uDB80\uDC28" // alert
    if (!aether.running) return "\uDB80\uDC84" // shield-off
    if (aether.connected) return "\uDB85\uDEB5" // shield-lock
    return "\uDB80\uDC83" // shield outline
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Service {
    id: aether
    settings: root.settings
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { aether.refresh(); aether.fetchLogs(); return "ok" }
    function start(): string { aether.startAether(); return "ok" }
    function stop(): string { aether.stopAether(); return "ok" }
    function restart(): string { aether.restartAether(); return "ok" }
    function toggleProxy(): string { aether.toggleSystemProxy(); return "ok" }
    function status(): string { return aether.statusSummary }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.icon
    active: aether.connected
    activeColor: root.accent
    tooltipText: aether.statusSummary

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) {
        aether.toggleAether()
      } else if (buttonCode === Qt.MiddleButton) {
        aether.refresh()
        aether.fetchLogs()
      } else {
        root.toggle()
      }
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(420))
    contentHeight: panel.fittedContentHeight(mainColumn.implicitHeight + Style.space(32), Style.space(640))

    onOpenChanged: {
      if (open) {
        aether.refresh()
        aether.fetchLogs()
      }
    }

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: mainColumn.implicitHeight + Style.space(28)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        Column {
          id: mainColumn
          width: parent.width - Style.space(20)
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          anchors.topMargin: Style.space(12)
          spacing: Style.space(12)

          // Hero Banner
          PanelHero {
            width: parent.width
            title: "Aether Core"
            meta: aether.running ? (aether.connected ? aether.heroPhrase : "Establishing MASQUE tunnel…") : "Censorship Circumvention Core"
            foreground: root.foreground
            fontFamily: root.fontFamily
            iconComponent: Component {
              AetherIcon {
                iconSize: Style.space(28)
                color: root.foreground
                accentColor: root.accent
                badgeColor: root.urgent
                active: aether.connected
                connecting: aether.running && !aether.connected
                crossed: !aether.running
                warning: !aether.installed || aether.lastError !== ""
              }
            }
            trailingControl: Component {
              ToggleSwitch {
                checked: aether.running
                busy: aether.actionInProgress || aether.installing
                onToggled: aether.toggleAether()
              }
            }
          }

          // Tab Navigation Bar
          RowLayout {
            width: parent.width
            spacing: Style.space(6)

            Button {
              Layout.fillWidth: true
              text: "Tunnel"
              selected: root.currentTab === "controls"
              onClicked: root.currentTab = "controls"
            }

            Button {
              Layout.fillWidth: true
              text: "Core & Config"
              selected: root.currentTab === "settings"
              onClicked: root.currentTab = "settings"
            }

            Button {
              Layout.fillWidth: true
              text: "Live Logs"
              selected: root.currentTab === "logs"
              onClicked: {
                root.currentTab = "logs"
                aether.fetchLogs()
              }
            }
          }

          // Uninstalled Banner (shown on any tab if binary missing)
          BorderSurface {
            visible: !aether.installed
            width: parent.width
            radius: Style.cornerRadius
            color: Qt.rgba(root.urgent.r, root.urgent.g, root.urgent.b, 0.12)
            borderSpec: Border.flat(root.urgent, 1)
            implicitHeight: uninstalledCol.implicitHeight + Style.space(20)

            Column {
              id: uninstalledCol
              width: parent.width - Style.space(24)
              anchors.centerIn: parent
              spacing: Style.space(8)

              Text {
                width: parent.width
                text: "Aether Binary Not Found"
                color: root.foreground
                font.bold: true
                font.family: root.fontFamily
                font.pixelSize: Style.font.subtitle
              }

              Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: "No Aether userspace core was detected. Download and install the pre-compiled binary automatically, or configure a custom binary path in Core & Config."
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }

              Button {
                text: aether.installing ? "Downloading Release…" : "Download & Install Aether"
                accent: root.accent
                bordered: true
                enabled: !aether.installing
                onClicked: aether.installAether()
              }
            }
          }

          // -------------------------------------------------------------
          // TAB 1: CONTROLS
          // -------------------------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(12)
            visible: root.currentTab === "controls"

            // Metrics Card
            BorderSurface {
              visible: aether.installed
              width: parent.width
              radius: Style.cornerRadius
              implicitHeight: metricsGrid.implicitHeight + Style.space(16)
              color: Color.cardFill || Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)

              GridLayout {
                id: metricsGrid
                width: parent.width - Style.space(24)
                anchors.centerIn: parent
                columns: 2
                rowSpacing: Style.space(8)
                columnSpacing: Style.space(12)

                Column {
                  Layout.fillWidth: true
                  Text {
                    text: "GATEWAY / COLO"
                    font.pixelSize: Style.font.caption
                    color: root.dim
                    font.bold: true
                    font.family: root.fontFamily
                  }
                  Text {
                    text: aether.connected ? Model.formatColo(aether.colo, aether.loc) : (aether.running ? "Scanning…" : "--")
                    font.pixelSize: Style.font.body
                    font.bold: true
                    color: aether.connected ? root.foreground : root.dim
                    font.family: root.fontFamily
                  }
                }

                Column {
                  Layout.fillWidth: true
                  Text {
                    text: "LATENCY"
                    font.pixelSize: Style.font.caption
                    color: root.dim
                    font.bold: true
                    font.family: root.fontFamily
                  }
                  Text {
                    text: aether.connected ? Model.formatLatency(aether.latency) : "--"
                    font.pixelSize: Style.font.body
                    font.bold: true
                    color: aether.connected ? (aether.latency < 500 ? root.accent : root.urgent) : root.dim
                    font.family: root.fontFamily
                  }
                }

                Column {
                  Layout.fillWidth: true
                  Text {
                    text: "EXIT IP"
                    font.pixelSize: Style.font.caption
                    color: root.dim
                    font.bold: true
                    font.family: root.fontFamily
                  }
                  Text {
                    text: aether.connected ? aether.ip : (aether.running ? "Obtaining…" : "--")
                    font.pixelSize: Style.font.body
                    font.bold: true
                    color: root.foreground
                    font.family: root.fontFamily
                    elide: Text.ElideRight
                  }
                }

                Column {
                  Layout.fillWidth: true
                  Text {
                    text: "SOCKS5 PROXY"
                    font.pixelSize: Style.font.caption
                    color: root.dim
                    font.bold: true
                    font.family: root.fontFamily
                  }
                  Text {
                    text: "127.0.0.1:" + aether.proxyPort
                    font.pixelSize: Style.font.body
                    font.bold: true
                    color: root.accent
                    font.family: root.fontFamily
                  }
                }
              }
            }

            // System Proxy Toggle
            Toggle {
              width: parent.width
              label: "System Proxy"
              description: "Route GNOME & desktop apps through SOCKS5 127.0.0.1:" + aether.proxyPort
              checked: aether.systemProxy
              onClicked: aether.toggleSystemProxy()
            }

            PanelSeparator { width: parent.width }

            // Protocol
            PanelSectionHeader {
              text: "PROTOCOL"
              foreground: root.foreground
            }

            RowLayout {
              width: parent.width
              spacing: Style.space(4)

              Button {
                Layout.fillWidth: true
                text: "MASQUE"
                selected: aether.protocol === "masque" && !aether.h2
                onClicked: {
                  aether.setConfig("h2", "0")
                  aether.setConfig("protocol", "masque")
                }
              }

              Button {
                Layout.fillWidth: true
                text: "HTTP/2"
                selected: aether.protocol === "masque" && aether.h2
                onClicked: {
                  aether.setConfig("h2", "1")
                  aether.setConfig("protocol", "masque")
                }
              }

              Button {
                Layout.fillWidth: true
                text: "WireGuard"
                selected: aether.protocol === "wg"
                onClicked: aether.setConfig("protocol", "wg")
              }

              Button {
                Layout.fillWidth: true
                text: "Gool"
                selected: aether.protocol === "gool"
                onClicked: aether.setConfig("protocol", "gool")
              }

              Button {
                Layout.fillWidth: true
                text: "MIM"
                selected: aether.protocol === "mim"
                onClicked: aether.setConfig("protocol", "mim")
              }

              Button {
                Layout.fillWidth: true
                text: "Tor"
                selected: aether.protocol === "tor"
                onClicked: aether.setConfig("protocol", "tor")
              }
            }

            // Scan Profile
            PanelSectionHeader {
              text: "SCAN PROFILE"
              foreground: root.foreground
            }

            RowLayout {
              width: parent.width
              spacing: Style.space(4)

              Button {
                Layout.fillWidth: true
                text: "Balanced"
                selected: aether.scan === "balanced"
                onClicked: aether.setConfig("scan", "balanced")
              }

              Button {
                Layout.fillWidth: true
                text: "Turbo"
                selected: aether.scan === "turbo"
                onClicked: aether.setConfig("scan", "turbo")
              }

              Button {
                Layout.fillWidth: true
                text: "Thorough"
                selected: aether.scan === "thorough"
                onClicked: aether.setConfig("scan", "thorough")
              }

              Button {
                Layout.fillWidth: true
                text: "Stealth"
                selected: aether.scan === "stealth"
                onClicked: aether.setConfig("scan", "stealth")
              }

              Button {
                Layout.fillWidth: true
                text: "Ironclad"
                selected: aether.scan === "ironclad"
                onClicked: aether.setConfig("scan", "ironclad")
              }
            }

            // Obfuscation / Noize
            PanelSectionHeader {
              text: "OBFUSCATION / NOIZE"
              foreground: root.foreground
            }

            RowLayout {
              width: parent.width
              spacing: Style.space(4)

              Button {
                Layout.fillWidth: true
                text: "Firewall"
                selected: aether.noize === "firewall"
                onClicked: aether.setConfig("noize", "firewall")
              }

              Button {
                Layout.fillWidth: true
                text: "GFW"
                selected: aether.noize === "gfw"
                onClicked: aether.setConfig("noize", "gfw")
              }

              Button {
                Layout.fillWidth: true
                text: "Balanced"
                selected: aether.noize === "balanced"
                onClicked: aether.setConfig("noize", "balanced")
              }

              Button {
                Layout.fillWidth: true
                text: "Aggressive"
                selected: aether.noize === "aggressive"
                onClicked: aether.setConfig("noize", "aggressive")
              }

              Button {
                Layout.fillWidth: true
                text: "Off"
                selected: aether.noize === "off"
                onClicked: aether.setConfig("noize", "off")
              }
            }

            PanelSeparator { width: parent.width }

            // Quick Copy
            PanelSectionHeader {
              text: "QUICK COPY"
              foreground: root.foreground
            }

            RowLayout {
              width: parent.width
              spacing: Style.space(6)

              Button {
                Layout.fillWidth: true
                text: "SOCKS5 URL"
                onClicked: aether.copySocksUrl()
              }

              Button {
                Layout.fillWidth: true
                text: "Env Exports"
                onClicked: aether.copyExportEnv()
              }

              Button {
                Layout.fillWidth: true
                text: "Curl Test"
                onClicked: aether.copyCurlSnippet()
              }
            }

            // Operations Row
            RowLayout {
              width: parent.width
              spacing: Style.space(6)

              Button {
                Layout.fillWidth: true
                text: aether.refreshing ? "Probing…" : "Re-probe"
                enabled: !aether.refreshing
                onClicked: {
                  aether.refresh()
                  aether.fetchLogs()
                }
              }

              Button {
                Layout.fillWidth: true
                text: "Restart"
                enabled: aether.running && !aether.actionInProgress
                onClicked: aether.restartAether()
              }

              Button {
                Layout.fillWidth: true
                text: "Clear Cache"
                onClicked: aether.clearCache()
              }
            }
          }

          // -------------------------------------------------------------
          // TAB 2: SETTINGS & CORE SELECTION
          // -------------------------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(12)
            visible: root.currentTab === "settings"

            PanelSectionHeader {
              text: "ACTIVE CORE BINARY"
              foreground: root.foreground
            }

            BorderSurface {
              width: parent.width
              radius: Style.cornerRadius
              implicitHeight: coreInfoCol.implicitHeight + Style.space(16)
              color: Color.cardFill || Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)

              Column {
                id: coreInfoCol
                width: parent.width - Style.space(24)
                anchors.centerIn: parent
                spacing: Style.space(6)

                Text {
                  width: parent.width
                  text: aether.binary !== "" ? aether.binary : "None detected"
                  font.bold: true
                  font.family: root.fontFamily
                  font.pixelSize: Style.font.body
                  color: aether.binary !== "" ? root.foreground : root.urgent
                  elide: Text.ElideMiddle
                }

                RowLayout {
                  width: parent.width
                  spacing: Style.space(8)

                  Text {
                    text: aether.binaryVersion !== "" ? aether.binaryVersion : "Unknown"
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    color: root.dim
                  }

                  Text {
                    text: "·"
                    color: root.dim
                  }

                  Text {
                    text: aether.hasCapNetAdmin ? "CAP_NET_ADMIN active" : "Userspace only"
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    color: aether.hasCapNetAdmin ? root.accent : root.dim
                  }
                }
              }
            }

            // Discovered Cores
            PanelSectionHeader {
              text: "DISCOVERED CORES ON SYSTEM"
              foreground: root.foreground
            }

            Repeater {
              model: aether.discoveredCores
              delegate: BorderSurface {
                width: parent.width
                radius: Style.cornerRadius
                implicitHeight: Style.space(40)
                color: aether.binary === modelData ? Style.selectedFillFor(root.foreground, root.accent) : "transparent"
                borderSpec: Border.controlSpec(aether.binary === modelData ? "selected" : "normal", root.foreground, root.accent)

                RowLayout {
                  anchors.fill: parent
                  anchors.leftMargin: Style.space(10)
                  anchors.rightMargin: Style.space(10)
                  spacing: Style.space(8)

                  Text {
                    Layout.fillWidth: true
                    text: modelData
                    font.family: root.fontFamily
                    font.pixelSize: Style.font.caption
                    color: root.foreground
                    elide: Text.ElideMiddle
                  }

                  Button {
                    text: aether.binary === modelData ? "Active" : "Use"
                    selected: aether.binary === modelData
                    enabled: aether.binary !== modelData
                    onClicked: aether.setCore(modelData)
                  }
                }
              }
            }

            PanelSeparator { width: parent.width }

            // Network Stack Configuration
            PanelSectionHeader {
              text: "IP STACK & ROUTING"
              foreground: root.foreground
            }

            RowLayout {
              width: parent.width
              spacing: Style.space(6)

              Button {
                Layout.fillWidth: true
                text: "IPv4 Only"
                selected: aether.ipMode === "v4"
                onClicked: aether.setConfig("ip", "v4")
              }

              Button {
                Layout.fillWidth: true
                text: "IPv6 Only"
                selected: aether.ipMode === "v6"
                onClicked: aether.setConfig("ip", "v6")
              }

              Button {
                Layout.fillWidth: true
                text: "Dual Stack"
                selected: aether.ipMode === "dual"
                onClicked: aether.setConfig("ip", "dual")
              }
            }

            Toggle {
              width: parent.width
              label: "Quick Reconnect"
              description: "Fast-resume connection using the last verified gateway"
              checked: aether.quickReconnect
              onClicked: aether.setConfig("quick_reconnect", aether.quickReconnect ? "0" : "1")
            }

            Toggle {
              width: parent.width
              label: "TLS ClientHello Fragmentation"
              description: "Fragment TLS ClientHello packets (HTTP/2 transport only)"
              checked: aether.fragment
              onClicked: aether.setConfig("fragment", aether.fragment ? "0" : "1")
            }

            Toggle {
              width: parent.width
              label: "Firewall Mark (SO_MARK 0xff)"
              description: "Attach mark for router / transparent tun2socks bypass (needs CAP_NET_ADMIN)"
              checked: aether.markEnabled
              onClicked: aether.setConfig("mark", aether.markEnabled ? "0" : "1")
            }
          }

          // -------------------------------------------------------------
          // TAB 3: LIVE LOGS
          // -------------------------------------------------------------
          Column {
            width: parent.width
            spacing: Style.space(8)
            visible: root.currentTab === "logs"

            RowLayout {
              width: parent.width

              PanelSectionHeader {
                text: "AETHER PROCESS LOGS"
                foreground: root.foreground
                Layout.fillWidth: true
              }

              Button {
                text: aether.fetchingLogs ? "Loading…" : "Refresh"
                enabled: !aether.fetchingLogs
                onClicked: aether.fetchLogs()
              }

              Button {
                text: "Copy All"
                onClicked: aether.copyAllLogs()
              }

              Button {
                text: "Clear"
                onClicked: aether.clearLogs()
              }
            }

            BorderSurface {
              width: parent.width
              radius: Style.cornerRadius
              implicitHeight: Style.space(320)
              color: "#0a0a0c"
              borderSpec: Border.flat(root.dim, 1)

              Flickable {
                anchors.fill: parent
                anchors.margins: Style.space(8)
                contentWidth: logText.implicitWidth
                contentHeight: logText.implicitHeight
                clip: true

                TextEdit {
                  id: logText
                  text: aether.logsText !== "" ? aether.logsText : "(No recent log entries)"
                  readOnly: true
                  color: "#d4d4d4"
                  font.family: "monospace"
                  font.pixelSize: Style.font.caption
                  selectByMouse: true
                }
              }
            }
          }

          // Global Action Status & Toast
          Text {
            visible: aether.actionStatus !== "" || aether.lastError !== ""
            width: parent.width
            text: aether.lastError !== "" ? aether.lastError : aether.actionStatus
            color: aether.lastError !== "" ? root.urgent : root.accent
            font.pixelSize: Style.font.caption
            font.family: root.fontFamily
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
          }
        }
      }
    }
  }
}
