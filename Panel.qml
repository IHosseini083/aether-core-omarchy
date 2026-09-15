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

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color accent: Color.accent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color barIconColor: aether.connected ? accent : (aether.running ? foreground : dim)

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
    function refresh(): string { aether.refresh(); return "ok" }
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
    tooltipText: aether.statusSummary

    iconComponent: Component {
      Item {
        AetherIcon {
          anchors.centerIn: parent
          iconSize: Style.space(13)
          color: root.barIconColor
          accentColor: root.accent
          badgeColor: root.urgent
          active: aether.connected
          connecting: aether.running && !aether.connected
          crossed: !aether.running
          warning: !aether.installed || aether.lastError !== ""
        }
      }
    }

    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) {
        aether.toggleAether()
      } else if (buttonCode === Qt.MiddleButton) {
        aether.refresh()
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
    contentWidth: panel.fittedContentWidth(Style.space(380))
    contentHeight: panel.fittedContentHeight(mainColumn.implicitHeight + Style.space(24), Style.space(620))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Flickable {
        id: flick
        anchors.fill: parent
        contentWidth: width
        contentHeight: mainColumn.implicitHeight + Style.space(24)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick

        Column {
          id: mainColumn
          width: parent.width - Style.space(16)
          anchors.horizontalCenter: parent.horizontalCenter
          anchors.top: parent.top
          anchors.topMargin: Style.space(12)
          spacing: Style.space(12)

          // Hero banner
          PanelHero {
            width: parent.width
            title: "Aether"
            meta: aether.running ? (aether.connected ? aether.heroPhrase : "Connecting to WARP…") : "Censorship Circumvention Core"
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
                warning: !aether.installed
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

          // Uninstalled Banner
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
                text: "Aether Core Not Found"
                color: root.foreground
                font.bold: true
                font.family: root.fontFamily
                font.pixelSize: Style.font.subtitle
              }

              Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: "Download and set up the Aether censorship circumvention client automatically."
                color: root.dim
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }

              Button {
                text: aether.installing ? "Installing…" : "Install Aether Now"
                accent: root.accent
                bordered: true
                enabled: !aether.installing
                onClicked: aether.installAether()
              }
            }
          }

          // Connection Metrics
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

              // Colo / Location
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
                  text: aether.connected ? Model.formatColo(aether.colo, aether.loc) : (aether.running ? "Resolving…" : "--")
                  font.pixelSize: Style.font.body
                  font.bold: true
                  color: aether.connected ? root.foreground : root.dim
                  font.family: root.fontFamily
                }
              }

              // Latency
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

              // Exit IP
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

              // SOCKS5 Port
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
            description: "Route GNOME & desktop apps through 127.0.0.1:" + aether.proxyPort
            checked: aether.systemProxy
            onClicked: aether.toggleSystemProxy()
          }

          PanelSeparator {
            width: parent.width
          }

          // Protocol Selector
          PanelSectionHeader {
            text: "PROTOCOL"
            foreground: root.foreground
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(6)

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

          // Scan Mode Selector
          PanelSectionHeader {
            text: "SCAN PROFILE"
            foreground: root.foreground
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(6)

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
              text: "Ironclad"
              selected: aether.scan === "ironclad"
              onClicked: aether.setConfig("scan", "ironclad")
            }
          }

          // Obfuscation (Noize) Selector
          PanelSectionHeader {
            text: "OBFUSCATION / NOIZE"
            foreground: root.foreground
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(6)

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

          PanelSeparator {
            width: parent.width
          }

          // Quick Actions & Copy Helpers
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

          // Action Status Toast
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

          // Operations Row
          RowLayout {
            width: parent.width
            spacing: Style.space(8)

            Button {
              Layout.fillWidth: true
              text: aether.refreshing ? "Checking…" : "Re-probe Status"
              enabled: !aether.refreshing
              onClicked: aether.refresh()
            }

            Button {
              Layout.fillWidth: true
              text: "Restart Tunnel"
              enabled: aether.running && !aether.actionInProgress
              onClicked: aether.restartAether()
            }
          }
        }
      }
    }
  }
}
