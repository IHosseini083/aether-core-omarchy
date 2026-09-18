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

  property string currentTab: "controls" // "controls" | "settings" | "routing" | "advanced" | "logs"
  property string pendingRemovePath: ""

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property color accent: Color.accent
  readonly property color dim: Qt.darker(foreground, 1.55)
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family

  readonly property color barGlyphColor: {
    if (!aether.installed || aether.lastError !== "") return urgent
    if (aether.zeptun_state === "RUNNING" && aether.connected) return accent
    if (aether.connected) return accent
    if (aether.running) return foreground
    return dim
  }

  function torMode(p) {
    return (p === "tor" || p === "tor-reverse" || p === "tor-only") ? p : "off"
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Service {
    id: aether
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
    function systemRouteStatus(): string { return aether.zeptunStatusSummary }
    function systemRouteStart(): string { aether.systemRouteStart(); return "ok" }
    function systemRouteStop(): string { aether.systemRouteStop(); return "ok" }
    function systemRouteRestart(): string { aether.systemRouteRestart(); return "ok" }
    function tab(t: string): string { root.currentTab = t; return "ok" }
    function status(): string { return aether.statusSummary }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    iconComponent: Component {
        Item {
        AetherIcon {
          anchors.centerIn: parent
          iconSize: Style.space(16)
          color: root.barGlyphColor
          accentColor: root.accent
          badgeColor: root.urgent
          active: aether.connected
          connecting: aether.running && !aether.connected
          crossed: !aether.running
          warning: !aether.installed || aether.lastError !== ""
          routed: aether.zeptun_state === "RUNNING"
        }
      }
    }
    active: aether.connected
    activeColor: root.barGlyphColor
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
    contentWidth: panel.fittedContentWidth(Style.space(430))
    // +12: breathing room below the last row. fittedContentHeight adds the
    // card's padding/border insets on top; the column's 12px top margin is
    // separate, so total visible margin is 12 top / 12 bottom.
    contentHeight: panel.fittedContentHeight(mainColumn.implicitHeight + Style.space(12), Style.space(currentTab === "controls" || currentTab === "logs" || currentTab === "routing" ? 760 : 660))

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
        contentHeight: mainColumn.implicitHeight + Style.space(24)
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: contentHeight > height
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

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
            title: "Aether Tunnel"
            meta: !aether.installed ? "Missing Core — Click to Install" : (aether.running ? (aether.connected ? aether.heroPhrase : "Establishing tunnel…") : "Censorship Circumvention Ready")
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
                routed: aether.zeptun_state === "RUNNING"
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
              text: "Cores"
              selected: root.currentTab === "settings"
              onClicked: root.currentTab = "settings"
            }

            Button {
              Layout.fillWidth: true
              text: "Routing"
              selected: root.currentTab === "routing"
              onClicked: root.currentTab = "routing"
            }

            Button {
              Layout.fillWidth: true
              text: "Advanced"
              selected: root.currentTab === "advanced"
              onClicked: root.currentTab = "advanced"
            }

            Button {
              Layout.fillWidth: true
              text: "Logs"
              selected: root.currentTab === "logs"
              onClicked: {
                root.currentTab = "logs"
                aether.fetchLogs()
              }
            }
          }

          // Missing core alert card
          BorderSurface {
            visible: !aether.installed
            width: parent.width
            radius: Style.cornerRadius
            color: Qt.rgba(root.urgent.r, root.urgent.g, root.urgent.b, 0.12)
            borderSpec: Border.flat(root.urgent, 1)
            implicitHeight: missingCoreCol.implicitHeight + Style.space(20)

            Column {
              id: missingCoreCol
              width: parent.width - Style.space(24)
              anchors.centerIn: parent
              spacing: Style.space(8)

              Text {
                width: parent.width
                text: "Aether Core Executable Not Found"
                color: root.urgent
                font.bold: true
                font.family: root.fontFamily
                font.pixelSize: Style.font.subtitle
              }

              Text {
                width: parent.width
                wrapMode: Text.Wrap
                text: "No Aether binary was located on your system. Download the official release directly from GitHub or select a core path in the Cores tab."
                color: root.foreground
                font.family: root.fontFamily
                font.pixelSize: Style.font.caption
              }

              Button {
                text: aether.installing ? "Downloading Official Release…" : "Download & Install Aether Core"
                accent: root.accent
                bordered: true
                enabled: !aether.installing
                onClicked: aether.installAether()
              }
            }
          }

          // Exactly one tab is instantiated at a time; the Loader keeps
          // mainColumn's implicitHeight honest for the panel sizing.
          Loader {
            id: tabLoader
            width: parent.width
            sourceComponent: root.currentTab === "controls" ? tabControlsComp
              : root.currentTab === "settings" ? tabSettingsComp
              : root.currentTab === "routing" ? tabRoutingComp
              : root.currentTab === "advanced" ? tabAdvancedComp
              : tabLogsComp
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

      ConfirmDialog {
        anchors.fill: parent
        opened: root.pendingRemovePath !== ""
        message: "Remove this Aether core from your system?\n" + root.pendingRemovePath
        confirmText: "Remove"
        background: Color.background
        foreground: root.foreground
        selectedText: root.accent
        fontFamily: root.fontFamily
        onCanceled: root.pendingRemovePath = ""
        onConfirmed: {
          aether.removeCore(root.pendingRemovePath)
          root.pendingRemovePath = ""
        }
      }
    }
  }

  // Labeled input bound to one ctl config key. Syncs from status polls while
  // unfocused; commits on Enter or focus loss when the text differs.
  component AetherField: Column {
    id: af
    property string key: ""
    property string labelText: ""
    property string hintText: ""
    property bool secret: false
    readonly property string current: key !== "" ? aether[key] : ""

    width: parent.width
    spacing: Style.space(4)

    onCurrentChanged: if (!fld.activeFocus && fld.text !== current) fld.text = current

    Text {
      text: labelText
      font.pixelSize: Style.font.caption
      font.bold: true
      color: root.dim
      font.family: root.fontFamily
    }

    TextField {
      id: fld
      width: parent.width
      password: secret
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      foreground: root.foreground
      accent: root.accent
      // editingFinished fires on both Enter and focus loss; a separate
      // onAccepted handler would commit the same value twice.
      onEditingFinished: if (fld.text !== af.current) aether.setConfig(af.key, fld.text)
      Component.onCompleted: if (af.current !== "") fld.text = af.current
    }

    Text {
      visible: af.hintText !== ""
      width: parent.width
      wrapMode: Text.Wrap
      text: af.hintText
      font.pixelSize: Style.font.caption
      color: root.dim
      font.family: root.fontFamily
    }
  }

  component AetherDropdown: Dropdown {
    property string key: ""
    width: parent.width
    foreground: root.foreground
    accent: root.accent
    fontFamily: root.fontFamily
    onChanged: function(v) { if (v !== aether[key]) aether.setConfig(key, v) }
  }

  // -------------------------------------------------------------
  // TAB 1: TUNNEL — metrics, transport, scan/noize, quick actions
  // -------------------------------------------------------------
  Component {
    id: tabControlsComp

    Column {
      width: parent.width
      spacing: Style.space(12)

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
              text: "GATEWAY"
              font.pixelSize: Style.font.caption
              color: root.dim
              font.bold: true
              font.family: root.fontFamily
            }
            Text {
              text: aether.connected ? Model.formatColo(aether.colo, aether.loc) : (aether.running ? "Connecting…" : "--")
              font.pixelSize: Style.font.body
              font.bold: true
              color: aether.connected ? root.foreground : root.dim
              font.family: root.fontFamily
            }
          }

          Column {
            Layout.fillWidth: true
            Text {
              text: "PING"
              font.pixelSize: Style.font.caption
              color: root.dim
              font.bold: true
              font.family: root.fontFamily
            }
            Text {
              text: aether.connected ? Model.formatLatency(aether.latency) : "--"
              font.pixelSize: Style.font.body
              font.bold: true
              color: aether.connected ? (aether.latency < 450 ? root.accent : root.urgent) : root.dim
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
              text: aether.connected ? aether.ip : (aether.running ? "Routing…" : "--")
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

      PanelSeparator { width: parent.width }

      // Transport Selection
      PanelSectionHeader {
        text: "TRANSPORT"
        foreground: root.foreground
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(4)

        Button {
          Layout.fillWidth: true
          text: "MASQUE"
          selected: aether.protocol === "masque" && !aether.h2
          onClicked: aether.setProtocol("masque", false)
        }

        Button {
          Layout.fillWidth: true
          text: "HTTP/2"
          selected: aether.protocol === "masque" && aether.h2
          onClicked: aether.setProtocol("masque", true)
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
      }

      // Scan Profile
      AetherDropdown {
        key: "scan"
        label: "SCAN MODE"
        value: aether.scan
        options: [
          { value: "balanced", label: "Balanced — collect a few, keep the fastest" },
          { value: "turbo", label: "Turbo — first responder wins" },
          { value: "thorough", label: "Thorough — sweep whole ranges" },
          { value: "stealth", label: "Stealth — few probes in flight" },
          { value: "ironclad", label: "Ironclad — verify with real traffic" }
        ]
      }

      // Obfuscation / Noize
      AetherDropdown {
        key: "noize"
        label: "NOIZE / OBFUSCATION"
        value: aether.noize
        options: [
          { value: "firewall", label: "Firewall (default for MASQUE)" },
          { value: "balanced", label: "Balanced (default for WireGuard)" },
          { value: "light", label: "Light" },
          { value: "gfw", label: "GFW" },
          { value: "aggressive", label: "Aggressive" },
          { value: "off", label: "Off" }
        ]
      }

      PanelSeparator { width: parent.width }

      // Action row
      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          text: "Copy Env"
          onClicked: aether.copyExportEnv()
        }

        Button {
          Layout.fillWidth: true
          text: "Curl Cmd"
          onClicked: aether.copyCurlSnippet()
        }

        Button {
          Layout.fillWidth: true
          text: "Clear Cache"
          onClicked: aether.clearCache()
        }
      }
    }
  }

  // -------------------------------------------------------------
  // TAB 2: CORES — active core, discovery, download
  // -------------------------------------------------------------
  Component {
    id: tabSettingsComp

    Column {
      width: parent.width
      spacing: Style.space(12)

      // Active Core Card
      PanelSectionHeader {
        text: "ACTIVE CORE"
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
            text: aether.binary !== "" ? aether.binary : "No binary detected"
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
              text: aether.hasCapNetAdmin ? "CAP_NET_ADMIN" : "Userspace"
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              color: aether.hasCapNetAdmin ? root.accent : root.dim
            }
          }
        }
      }

      // Discovered Cores
      PanelSectionHeader {
        text: "DISCOVERED CORES"
        foreground: root.foreground
      }

      Text {
        width: parent.width
        wrapMode: Text.Wrap
        text: "Searched in order: custom path, ~/.local/share/omarchy-aether/bin, ~/Downloads/Aether, plugin bin/, ~/.local/bin, /usr/local/bin, /opt/aether, then $PATH. Any of them can be activated below; the official release can be downloaded if none is found."
        font.pixelSize: Style.font.caption
        color: root.dim
        font.family: root.fontFamily
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

            Button {
              text: "Remove"
              enabled: aether.binary !== modelData
              onClicked: root.pendingRemovePath = modelData
            }
          }
        }
      }

      // Download official core button
      Button {
        width: parent.width
        text: aether.installing ? "Downloading Official Aether Core…" : "Download Latest Official Release"
        enabled: !aether.installing
        accent: root.accent
        bordered: true
        onClicked: aether.installAether()
      }

      PanelSeparator { width: parent.width }

      // IP Stack
      PanelSectionHeader {
        text: "IP VERSION"
        foreground: root.foreground
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          text: "IPv4"
          selected: aether.ip_mode === "v4"
          onClicked: aether.setConfig("ip", "v4")
        }

        Button {
          Layout.fillWidth: true
          text: "IPv6"
          selected: aether.ip_mode === "v6"
          onClicked: aether.setConfig("ip", "v6")
        }

        Button {
          Layout.fillWidth: true
          text: "Dual Stack"
          selected: aether.ip_mode === "dual"
          onClicked: aether.setConfig("ip", "dual")
        }
      }

      // Feature Toggles
      Toggle {
        width: parent.width
        label: "Quick Reconnect"
        description: "Fast-resume connection using the last verified gateway"
        checked: aether.quick_reconnect
        onClicked: aether.setConfig("quick_reconnect", aether.quick_reconnect ? "0" : "1")
      }

      Toggle {
        width: parent.width
        label: "TLS ClientHello Fragmentation"
        description: "Fragment ClientHello on HTTP/2 transport to bypass DPI"
        checked: aether.fragment
        onClicked: aether.setConfig("fragment", aether.fragment ? "0" : "1")
      }

      Toggle {
        width: parent.width
        label: "Encrypted Client Hello (ECH)"
        description: "Enable automated ECH negotiation to hide SNI"
        checked: aether.ech === "auto"
        onClicked: aether.setConfig("ech", aether.ech === "auto" ? "off" : "auto")
      }

      Toggle {
        width: parent.width
        label: "QUIC v2 Opener"
        description: "Send initial QUIC v2 opener packet on HTTP/3 (recommended)"
        checked: !aether.no_quic_v2
        onClicked: aether.setConfig("no_quic_v2", aether.no_quic_v2 ? "0" : "1")
      }

      Toggle {
        width: parent.width
        label: "Skip Data-Plane Probe"
        description: "Skip HTTP probe verification (connects faster but less resilient)"
        checked: aether.no_data_check
        onClicked: aether.setConfig("no_data_check", aether.no_data_check ? "0" : "1")
      }

      Toggle {
        width: parent.width
        label: "Firewall Mark (SO_MARK 0xff)"
        description: "Attach mark for router / transparent tun2socks bypass (requires CAP_NET_ADMIN)"
        checked: aether.mark_enabled
        onClicked: aether.setConfig("mark", aether.mark_enabled ? "0" : "1")
      }
    }
  }

  // -------------------------------------------------------------
  // TAB 3: ROUTING — optional Zeptun system-wide TUN routing
  // -------------------------------------------------------------
  Component {
    id: tabRoutingComp

    Column {
      width: parent.width
      spacing: Style.space(12)

      // Missing engine alert card
      BorderSurface {
        visible: !aether.zeptun_available
        width: parent.width
        radius: Style.cornerRadius
        color: Qt.rgba(root.urgent.r, root.urgent.g, root.urgent.b, 0.12)
        borderSpec: Border.flat(root.urgent, 1)
        implicitHeight: missingZeptunCol.implicitHeight + Style.space(20)

        Column {
          id: missingZeptunCol
          width: parent.width - Style.space(24)
          anchors.centerIn: parent
          spacing: Style.space(8)

          Text {
            width: parent.width
            text: "Zeptun Engine Not Found"
            color: root.urgent
            font.bold: true
            font.family: root.fontFamily
            font.pixelSize: Style.font.subtitle
          }

          Text {
            width: parent.width
            wrapMode: Text.Wrap
            text: "System-wide routing needs the Zeptun TUN engine (github.com/Noisemux/zeptun). Download the pinned, checksum-verified release into the plugin's data directory, or point the binary path below at an existing installation."
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          Button {
            text: aether.actionInProgress ? "Downloading…" : "Download & Install Zeptun"
            accent: root.accent
            bordered: true
            enabled: !aether.actionInProgress
            onClicked: aether.runAction(["zeptun-install"], "Downloading Zeptun…")
          }
        }
      }

      // Status card
      BorderSurface {
        visible: aether.zeptun_available
        width: parent.width
        radius: Style.cornerRadius
        implicitHeight: routingCol.implicitHeight + Style.space(16)
        color: Color.cardFill || Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)

        Column {
          id: routingCol
          width: parent.width - Style.space(24)
          anchors.centerIn: parent
          spacing: Style.space(6)

          RowLayout {
            width: parent.width
            spacing: Style.space(8)

            Text {
              Layout.fillWidth: true
              text: Model.zeptunStateLabel(aether.zeptun_state, aether.zeptun_error, aether.zeptun_available)
              font.bold: true
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              color: Model.zeptunStateColor(aether.zeptun_state, root.accent, root.urgent, root.foreground, root.dim)
              wrapMode: Text.Wrap
            }

            ToggleSwitch {
              checked: aether.zeptun_state === "RUNNING" || aether.zeptun_state === "STARTING"
              busy: aether.actionInProgress || aether.zeptun_state === "STARTING" || aether.zeptun_state === "STOPPING"
              enabled: aether.zeptun_available && aether.connected && !aether.actionInProgress
              onToggled: aether.toggleSystemRoute()
            }
          }

          Text {
            width: parent.width
            visible: aether.zeptun_state === "RUNNING"
            text: "tun " + aether.zeptun_tun + " · pid " + aether.zeptun_pid + " · up " + aether.zeptun_uptime_s + "s"
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            color: root.dim
            elide: Text.ElideMiddle
          }

          Text {
            width: parent.width
            visible: aether.zeptun_available && !aether.connected && aether.zeptun_state !== "RUNNING"
            wrapMode: Text.Wrap
            text: "Connect Aether tunnel first to enable system routing."
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            color: root.dim
          }

          Text {
            width: parent.width
            visible: aether.zeptun_available && !aether.zeptun_has_cap_net_admin
            wrapMode: Text.Wrap
            text: "Zeptun needs CAP_NET_ADMIN (TUN + routing). Grant it once:\nsudo setcap cap_net_admin+ep " + (aether.zeptun_binary !== "" ? aether.zeptun_binary : "~/.local/share/omarchy-aether/bin/zeptun")
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            color: root.urgent
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(6)

            Button {
              Layout.fillWidth: true
              text: "Start"
              enabled: aether.zeptun_available && aether.connected && aether.zeptun_state !== "RUNNING" && aether.zeptun_state !== "STARTING" && !aether.actionInProgress
              onClicked: aether.systemRouteStart()
            }

            Button {
              Layout.fillWidth: true
              text: "Stop"
              enabled: (aether.zeptun_state === "RUNNING" || aether.zeptun_state === "STARTING") && !aether.actionInProgress
              onClicked: aether.systemRouteStop()
            }

            Button {
              Layout.fillWidth: true
              text: "Restart"
              enabled: aether.zeptun_state === "RUNNING" && aether.connected && !aether.actionInProgress
              onClicked: aether.systemRouteRestart()
            }
          }
        }
      }

      // Engine settings
      PanelSectionHeader {
        visible: aether.zeptun_available
        text: "ROUTING SETTINGS"
        foreground: root.foreground
      }

      RowLayout {
        visible: aether.zeptun_available
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          text: "IPv4"
          selected: !aether.sysroute_ipv6
          onClicked: aether.setConfig("sysroute_ipv6", "0")
        }

        Button {
          Layout.fillWidth: true
          text: "IPv4 + IPv6"
          selected: aether.sysroute_ipv6
          onClicked: aether.setConfig("sysroute_ipv6", "1")
        }
      }

      AetherDropdown {
        visible: aether.zeptun_available
        key: "sysroute_dns_mode"
        label: "DNS MODE"
        value: aether.sysroute_dns_mode
        options: [
          { value: "systemd_resolved", label: "Hand over to systemd-resolved" },
          { value: "hijack", label: "Hijack all DNS into the tunnel" },
          { value: "off", label: "Off — DNS follows normal routing" }
        ]
      }

      AetherDropdown {
        visible: aether.zeptun_available
        key: "sysroute_udp_mode"
        label: "UDP CARRIER"
        value: aether.sysroute_udp_mode
        options: [
          { value: "udp", label: "Native UDP (SOCKS5 UDP ASSOCIATE)" },
          { value: "tcp", label: "UDP over TCP" }
        ]
      }

      Toggle {
        visible: aether.zeptun_available
        width: parent.width
        label: "Persistent"
        description: "Bring system routing up automatically whenever Aether is connected (survives reboot and Aether restarts, with bounded retries)"
        checked: aether.sysroute_persistent
        onClicked: aether.setConfig("sysroute_persistent", aether.sysroute_persistent ? "0" : "1")
      }

      AetherField {
        visible: aether.zeptun_available
        key: "sysroute_exclude"
        labelText: "Route exclusions (CIDRs, comma or space separated)"
        hintText: "Kept off the tunnel in addition to LAN, link-local, multicast, and Aether's own endpoints."
      }

      AetherField {
        visible: aether.zeptun_available
        key: "zeptun_bin"
        labelText: "Zeptun binary path (empty = auto-discover)"
        hintText: "Discovery order: this path, ~/.local/share/omarchy-aether/bin/, ~/.local/bin, /usr/local/bin, then $PATH."
      }

      Text {
        visible: aether.zeptun_available
        width: parent.width
        wrapMode: Text.Wrap
        text: "Starting system routing turns on the core's firewall mark (SO_MARK 0xff) so Aether's own connection bypasses the TUN — the mark is inert in normal mode. IPv4-only mode blocks IPv6 through the routing policy instead of leaking it."
        font.pixelSize: Style.font.caption
        color: root.dim
        font.family: root.fontFamily
      }
    }
  }

  // -------------------------------------------------------------
  // TAB 4: ADVANCED — every remaining Aether CLI feature
  // -------------------------------------------------------------
  Component {
    id: tabAdvancedComp

    Column {
      width: parent.width
      spacing: Style.space(10)

      Text {
        width: parent.width
        wrapMode: Text.Wrap
        text: "Direct access to the remaining core options. Fields apply on Enter or when focus leaves; each change restarts the tunnel if it is running."
        font.pixelSize: Style.font.caption
        color: root.dim
        font.family: root.fontFamily
      }

      PanelSectionHeader {
        text: "STATIC PEERS & ENDPOINTS"
        foreground: root.dim
      }

      GridLayout {
        width: parent.width
        columns: 2
        columnSpacing: Style.space(8)
        rowSpacing: Style.space(8)

        AetherField { Layout.fillWidth: true; key: "peer"; labelText: "Forced peer (ip:port)" }
        AetherField { Layout.fillWidth: true; key: "wg_peer"; labelText: "WireGuard peer (--wg-peer)" }
        AetherField { Layout.fillWidth: true; key: "h2_peer"; labelText: "HTTP/2 peer (--h2-peer)" }
        AetherField { Layout.fillWidth: true; key: "upstream"; labelText: "Upstream proxy URL" }
        AetherField { Layout.fillWidth: true; key: "wiw_outer"; labelText: "WiW outer hop (ip:port)" }
        AetherField { Layout.fillWidth: true; key: "wiw_inner"; labelText: "WiW inner hop (ip:port)" }
        AetherField { Layout.fillWidth: true; key: "mim_outer"; labelText: "MIM outer hop (ip:port)" }
        AetherField { Layout.fillWidth: true; key: "mim_inner"; labelText: "MIM inner hop (ip:port)" }
      }

      PanelSectionHeader {
        text: "NETWORK"
        foreground: root.dim
      }

      GridLayout {
        width: parent.width
        columns: 2
        columnSpacing: Style.space(8)
        rowSpacing: Style.space(8)

        AetherField { Layout.fillWidth: true; key: "socks_port"; labelText: "SOCKS5 port" }
        AetherField { Layout.fillWidth: true; key: "http_proxy_port"; labelText: "HTTP CONNECT port (0 = off)" }
        AetherField { Layout.fillWidth: true; key: "dns"; labelText: "Tunnel resolvers" }
        AetherField { Layout.fillWidth: true; key: "routes_file"; labelText: "Routes file (--routes)" }
      }

      AetherField { key: "route_block"; labelText: "Route block list (domains, CIDRs, port:, private)" }
      AetherField { key: "route_direct"; labelText: "Route direct list (bypasses the tunnel)" }

      PanelSectionHeader {
        text: "ZERO TRUST"
        foreground: root.dim
      }

      AetherField { key: "team"; labelText: "Team name" }

      GridLayout {
        width: parent.width
        columns: 2
        columnSpacing: Style.space(8)
        rowSpacing: Style.space(8)

        AetherField { Layout.fillWidth: true; key: "access_id"; labelText: "Service token ID" }
        AetherField { Layout.fillWidth: true; secret: true; key: "access_secret"; labelText: "Service token secret" }
        AetherField { Layout.fillWidth: true; secret: true; key: "access_token"; labelText: "Enrolment token (JWT)" }
        AetherField { Layout.fillWidth: true; key: "access_email"; labelText: "Enrolment email" }
      }

      Toggle {
        width: parent.width
        label: "Organization Gateway"
        description: "Route HTTP(S) through the Zero Trust gateway (adds a hop, applies its logging)"
        checked: aether.gateway
        onClicked: aether.setConfig("gateway", aether.gateway ? "0" : "1")
      }

      Toggle {
        width: parent.width
        label: "No Profile Retry"
        description: "WireGuard scan: don't retry other obfuscation profiles"
        checked: aether.no_profile_retry
        onClicked: aether.setConfig("no_profile_retry", aether.no_profile_retry ? "0" : "1")
      }

      PanelSectionHeader {
        text: "TOR"
        foreground: root.dim
      }

      Dropdown {
        width: parent.width
        label: "TOR MODE"
        value: root.torMode(aether.protocol)
        foreground: root.foreground
        accent: root.accent
        fontFamily: root.fontFamily
        options: [
          { value: "off", label: "Disabled" },
          { value: "tor", label: "Carry Tor inside the tunnel" },
          { value: "tor-reverse", label: "Dial the tunnel through Tor" },
          { value: "tor-only", label: "Tor only — no WARP tunnel" }
        ]
        onChanged: function(v) { aether.setConfig("protocol", v === "off" ? "masque" : v) }
      }

      AetherDropdown {
        key: "tor_bridges"
        label: "TOR BRIDGES"
        value: aether.tor_bridges
        options: [
          { value: "", label: "Auto — try plain Tor, fall back to bridges" },
          { value: "on", label: "Always use bridges" },
          { value: "off", label: "Never use bridges" }
        ]
      }

      GridLayout {
        width: parent.width
        columns: 2
        columnSpacing: Style.space(8)
        rowSpacing: Style.space(8)

        AetherField { Layout.fillWidth: true; key: "tor_bind"; labelText: "Tor proxy bind address" }
        AetherField { Layout.fillWidth: true; key: "tor_country"; labelText: "Bridge country (e.g. ir)" }
        AetherField { Layout.fillWidth: true; key: "tor_dir"; labelText: "Tor state directory" }
        AetherField { Layout.fillWidth: true; key: "tor_pt_dir"; labelText: "Transport search directory" }
      }

      AetherField { key: "tor_bridge"; labelText: "Custom bridge line (obfs4 1.2.3.4:443 …)" }
      AetherField { key: "tor_pt"; labelText: "Pluggable transport binary ([name=]/path)" }

      PanelSectionHeader {
        text: "TIMING, TLS & LOGGING"
        foreground: root.dim
      }

      GridLayout {
        width: parent.width
        columns: 2
        columnSpacing: Style.space(8)
        rowSpacing: Style.space(8)

        AetherField { Layout.fillWidth: true; key: "keepalive"; labelText: "WireGuard keepalive (s)" }
        AetherField { Layout.fillWidth: true; key: "validate_secs"; labelText: "Data-plane validate (s)" }
        AetherField { Layout.fillWidth: true; key: "startup_secs"; labelText: "MASQUE startup deadline (s)" }
        AetherField { Layout.fillWidth: true; key: "reconnect_secs"; labelText: "Reconnect delay (s)" }
        AetherField { Layout.fillWidth: true; key: "tls_groups"; labelText: "TLS key share groups" }
        AetherField { Layout.fillWidth: true; key: "fragment_size"; labelText: "Fragment size (bytes)" }
        AetherField { Layout.fillWidth: true; key: "fragment_delay"; labelText: "Fragment delay (ms)" }
      }

      AetherDropdown {
        key: "perf"
        label: "RESOURCE PROFILE"
        value: aether.perf
        options: [
          { value: "", label: "Auto-detect from CPU / RAM" },
          { value: "low", label: "Low — routers, small boards" },
          { value: "medium", label: "Medium — typical desktop" },
          { value: "high", label: "High — servers" }
        ]
      }

      AetherDropdown {
        key: "log_level"
        label: "LOG LEVEL"
        value: aether.log_level
        options: ["error", "warn", "info", "debug", "trace"]
      }

      AetherField {
        key: "extra_args"
        labelText: "Extra core arguments (verbatim)"
        hintText: "Appended as-is to the core command line, split on spaces. Handy for flags the panel doesn't expose — e.g. --verbose, or --ironclad-port 80."
      }
    }
  }

  // -------------------------------------------------------------
  // TAB 5: LIVE LOGS — auto-tailing & color-coded viewer
  // -------------------------------------------------------------
  Component {
    id: tabLogsComp

    Column {
      width: parent.width
      spacing: Style.space(8)

      RowLayout {
        width: parent.width

        Button {
          text: "Aether"
          selected: aether.logsView === "aether"
          onClicked: aether.setLogsView("aether")
        }

        Button {
          text: "Zeptun"
          selected: aether.logsView === "zeptun"
          enabled: aether.zeptun_available
          onClicked: aether.setLogsView("zeptun")
        }

        Item { Layout.fillWidth: true }

        Button {
          text: aether.fetchingLogs ? "…" : "Refresh"
          enabled: !aether.fetchingLogs
          onClicked: aether.fetchLogs()
        }

        Button {
          text: "Copy"
          onClicked: aether.copyAllLogs()
        }

        Button {
          text: "Clear"
          onClicked: aether.clearLogs()
        }
      }

      Toggle {
        width: parent.width
        label: "Auto-Tail Logs"
        description: "Continuously stream new output while panel is open"
        checked: aether.autoTailLogs
        onClicked: aether.autoTailLogs = !aether.autoTailLogs
      }

      Text {
        width: parent.width
        text: aether.logsView === "zeptun"
          ? "Log file: ~/.local/share/omarchy-aether/zeptun.log"
          : "Log file: ~/.local/share/omarchy-aether/aether.log"
        color: root.dim
        font.pixelSize: Style.font.caption
        elide: Text.ElideMiddle
      }

      BorderSurface {
        width: parent.width
        radius: Style.cornerRadius
        // Fixed-height viewport with its OWN scroll: the box itself scrolls,
        // not the panel. No manual ScrollBar position writes anywhere — those
        // caused the earlier reflow distortion.
        implicitHeight: Style.space(340)
        color: "#0a0a0f"
        borderSpec: Border.flat(root.dim, 1)

        ScrollView {
          id: logScroll
          anchors.fill: parent
          anchors.margins: Style.space(8)
          clip: true
          ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

          function toBottom() {
            var f = logScroll.contentItem
            if (f) f.contentY = Math.max(0, f.contentHeight - f.height)
          }

          // Tail when the tab mounts; the TextArea's onTextChanged covers
          // updates while it is already visible.
          Component.onCompleted: if (aether.autoTailLogs) Qt.callLater(logScroll.toBottom)
          Connections {
            target: root
            function onCurrentTabChanged() {
              if (root.currentTab === "logs" && aether.autoTailLogs)
                Qt.callLater(logScroll.toBottom)
            }
          }

          TextArea {
            id: logView
            readOnly: true
            textFormat: TextEdit.RichText
            wrapMode: TextEdit.WrapAnywhere
            persistentSelection: false
            color: root.foreground
            selectionColor: Style.selectionFillFor(root.foreground, root.accent)
            selectedTextColor: root.foreground
            font.family: "monospace"
            font.pixelSize: Style.font.caption

            text: {
              var html = aether.logsView === "zeptun" ? aether.zeptunLogsHtml : aether.logsHtml
              return html !== "" ? html : "<span style='color:#666;'>(No recent log entries)</span>"
            }

            onTextChanged: {
              if (aether.autoTailLogs && root.currentTab === "logs")
                Qt.callLater(logScroll.toBottom)
            }
          }
        }
      }
    }
  }
}
