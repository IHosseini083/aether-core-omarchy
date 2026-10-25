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

  property string currentTab: "controls" // "controls" | "settings" | "routing" | "logs"
  property string settingsCategory: "all" // "all" | "core" | "network" | "tls" | "circumvention" | "routing" | "zerotrust"
  property bool showAdvancedSettings: false
  property string settingsSearchQuery: ""
  property bool confirmResetAll: false
  property string logsSubTab: "core" // "core" | "zeptun" | "doctor"
  property bool customExitExpanded: false
  property string pendingRemovePath: ""
  property string pendingRemoveZeptunPath: ""
  property string pendingImportPath: ""

  function isFieldVisible(key, category, isAdvanced) {
    if (!root.showAdvancedSettings && isAdvanced) return false
    var item = Model.getSchemaItem(key)
    if (!item) return false

    if (root.settingsCategory === "modified") {
      var val = Model.getSettingValue(aether, key)
      var hasSec = aether["has_" + key]
      if (!Model.isSettingModified(key, val, hasSec)) return false
    } else if (root.settingsCategory !== "all" && root.settingsCategory !== category) {
      return false
    }

    if (root.settingsSearchQuery === "") return true
    return Model.matchesQuery(item, root.settingsSearchQuery)
  }

  function isCategoryVisible(category) {
    if (root.settingsCategory !== "all" && root.settingsCategory !== "modified" && root.settingsCategory !== category) return false
    if (root.settingsCategory === "modified") {
      var modItems = Model.filterSchema("", category, root.showAdvancedSettings, true, aether)
      return modItems.length > 0
    }
    if (root.settingsSearchQuery === "") return true
    var items = Model.filterSchema(root.settingsSearchQuery, category, root.showAdvancedSettings, false, aether)
    return items.length > 0
  }

  function isSectionVisible(keys) {
    if (!keys || keys.length === 0) return true
    for (var i = 0; i < keys.length; i++) {
      var k = keys[i]
      var item = Model.getSchemaItem(k)
      var isAdv = item ? (item.level === "advanced") : false
      var cat = item ? item.category : "core"
      if (root.isFieldVisible(k, cat, isAdv)) return true
    }
    return false
  }

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

  function psiphonMode(p) {
    return (p === "psiphon" || p === "psiphon-reverse" || p === "psiphon-only") ? p : "off"
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
    function tab(t: string): string {
      // Settings categories live under the "settings" tab; only real tab
      // names may be assigned to currentTab.
      const categories = ["core", "network", "tls", "circumvention", "routing", "zerotrust", "advanced"]
      if (t === "cores" || categories.includes(t)) {
        root.currentTab = "settings"
        root.settingsCategory = t === "cores" ? "core" : t
      } else {
        root.currentTab = t
      }
      return "ok"
    }
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
    contentHeight: panel.fittedContentHeight(mainColumn.implicitHeight + Style.space(12), Style.space(780))

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
              text: aether.core_update_available ? "Settings •" : "Settings"
              selected: root.currentTab === "settings" || root.currentTab === "advanced"
              onClicked: root.currentTab = "settings"
            }

            Button {
              Layout.fillWidth: true
              text: aether.zeptun_update_available ? "Routing •" : "Routing"
              selected: root.currentTab === "routing"
              onClicked: root.currentTab = "routing"
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
              : (root.currentTab === "settings" || root.currentTab === "advanced") ? tabSettingsComp
              : root.currentTab === "routing" ? tabRoutingComp
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

          // Versions Footer
          RowLayout {
            width: parent.width
            spacing: Style.space(6)

            Item { Layout.fillWidth: true }

            Text {
              text: "Plugin v" + (aether.pluginVersion !== "" ? aether.pluginVersion : "1.8.1")
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              color: root.dim
            }

            Text {
              text: "·"
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              color: root.dim
            }

            Text {
              text: aether.binaryVersion !== "" ? aether.binaryVersion : "Aether core missing"
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              color: aether.installed ? root.dim : root.urgent
            }

            Text {
              visible: aether.zeptun_available && aether.zeptun_version !== ""
              text: "·"
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              color: root.dim
            }

            Text {
              visible: aether.zeptun_available && aether.zeptun_version !== ""
              text: aether.zeptun_version
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              color: root.dim
            }

            Item { Layout.fillWidth: true }
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

      ConfirmDialog {
        anchors.fill: parent
        opened: root.pendingRemoveZeptunPath !== ""
        message: "Remove Zeptun engine from your system?\n" + root.pendingRemoveZeptunPath
        confirmText: "Remove"
        background: Color.background
        foreground: root.foreground
        selectedText: root.accent
        fontFamily: root.fontFamily
        onCanceled: root.pendingRemoveZeptunPath = ""
        onConfirmed: {
          aether.removeZeptun(root.pendingRemoveZeptunPath)
          root.pendingRemoveZeptunPath = ""
        }
      }

      ConfirmDialog {
        anchors.fill: parent
        opened: root.confirmResetAll
        message: "Reset all Aether configuration settings to default values?\nAny custom configuration will be cleared."
        confirmText: "Reset All"
        background: Color.background
        foreground: root.foreground
        selectedText: root.urgent
        fontFamily: root.fontFamily
        onCanceled: root.confirmResetAll = false
        onConfirmed: {
          aether.resetAllConfig()
          root.confirmResetAll = false
        }
      }

      ConfirmDialog {
        anchors.fill: parent
        opened: root.pendingImportPath !== ""
        message: "Import configuration from:\n" + root.pendingImportPath + "\n\nThis will replace all current settings and reload the service."
        confirmText: "Import"
        background: Color.background
        foreground: root.foreground
        selectedText: root.accent
        fontFamily: root.fontFamily
        onCanceled: root.pendingImportPath = ""
        onConfirmed: {
          aether.importConfig(root.pendingImportPath)
          root.pendingImportPath = ""
        }
      }
    }
  }

  // Responsive form container for short settings fields. Lays children out
  // in two equal columns when the panel is wide enough, stacks them
  // single-column when narrow. Children must bind `width: <id>.cellWidth`
  // so Grid sizes its cells correctly (AetherField defaults to full width).
  component ResponsiveFormGrid: Grid {
    id: rfg
    property real breakpoint: Style.space(460)
    readonly property bool stacked: width < breakpoint
    readonly property real cellWidth: stacked ? width : (width - columnSpacing) / 2
    columns: stacked ? 1 : 2
    columnSpacing: Style.space(8)
    rowSpacing: Style.space(8)
  }

  // Labeled input bound to one ctl config key. Syncs from status polls while
  // unfocused; commits on Enter or focus loss when the text differs.
  component AetherField: Column {
    id: af
    property string key: ""
    property string labelText: ""
    property string hintText: ""
    property bool secret: false
    property bool isAdvanced: false
    property string category: "core"
    readonly property bool isConfigured: secret ? Boolean(aether["has_" + key]) : (current !== "")
    readonly property string current: key !== "" && aether[key] !== undefined ? String(aether[key]) : ""

    visible: root.isFieldVisible(key, category, isAdvanced)
    width: parent.width
    spacing: Style.space(4)

    onCurrentChanged: if (!secret && !fld.activeFocus && fld.text !== current) fld.text = current

    RowLayout {
      width: parent.width
      Text {
        Layout.fillWidth: true
        text: labelText
        font.pixelSize: Style.font.caption
        font.bold: true
        color: root.dim
        font.family: root.fontFamily
      }
      Text {
        visible: !af.secret && af.key !== "" && Model.isSettingModified(af.key, af.current, false)
        text: "Reset"
        font.pixelSize: Style.font.caption
        color: root.accent
        font.family: root.fontFamily
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: aether.resetConfig(af.key)
        }
      }
      Text {
        visible: af.secret && af.isConfigured
        text: "Clear"
        font.pixelSize: Style.font.caption
        font.bold: true
        color: root.urgent
        font.family: root.fontFamily
        MouseArea {
          anchors.fill: parent
          cursorShape: Qt.PointingHandCursor
          onClicked: {
            fld.text = ""
            aether.setConfig(af.key, "")
          }
        }
      }
    }

    TextField {
      id: fld
      width: parent.width
      password: secret
      placeholderText: secret ? (af.isConfigured ? "••••••••  (configured · enter new to replace)" : "Optional secret") : ""
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      foreground: root.foreground
      accent: root.accent
      // editingFinished fires on both Enter and focus loss; a separate
      // onAccepted handler would commit the same value twice.
      onEditingFinished: {
        if (secret) {
          if (fld.text !== "") {
            aether.setConfig(af.key, fld.text)
            fld.text = ""
          }
        } else {
          if (fld.text !== af.current) aether.setConfig(af.key, fld.text)
        }
      }
      Component.onCompleted: if (!secret && af.current !== "") fld.text = af.current
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
    property bool isAdvanced: false
    property string category: "core"
    property bool filterWithSettings: true
    visible: filterWithSettings ? root.isFieldVisible(key, category, isAdvanced) : true
    width: parent.width
    foreground: root.foreground
    accent: root.accent
    fontFamily: root.fontFamily
    onChanged: function(v) { if (v !== aether[key]) aether.setConfig(key, v) }
  }

  component AetherToggle: Toggle {
    property string key: ""
    property bool isAdvanced: false
    property string category: "core"
    property bool filterWithSettings: true
    visible: filterWithSettings ? root.isFieldVisible(key, category, isAdvanced) : true
    width: parent.width
  }

  // -------------------------------------------------------------
  // TAB 1: TUNNEL — metrics, transport, scan/noize, quick actions
  // -------------------------------------------------------------
  Component {
    id: tabControlsComp

    Column {
      width: parent.width
      spacing: Style.space(12)

      // Live Stats & Connection Card
      BorderSurface {
        visible: aether.installed
        width: parent.width
        radius: Style.cornerRadius
        color: Color.cardFill || Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
        implicitHeight: statsCardCol.implicitHeight + Style.space(16)

        Column {
          id: statsCardCol
          width: parent.width - Style.space(20)
          anchors.centerIn: parent
          spacing: Style.space(10)

          // Status & Latency Row
          RowLayout {
            width: parent.width
            spacing: Style.space(6)

            Rectangle {
              width: Style.space(8)
              height: Style.space(8)
              radius: Style.space(4)
              color: aether.connected ? root.accent : (aether.running ? root.foreground : root.dim)
            }

            Text {
              text: aether.connected ? "TUNNEL CONNECTED" : (aether.running ? "CONNECTING…" : "DISCONNECTED")
              font.pixelSize: Style.font.caption
              font.bold: true
              color: aether.connected ? root.accent : (aether.running ? root.foreground : root.dim)
              font.family: root.fontFamily
            }

            Item { Layout.fillWidth: true }

            Text {
              visible: aether.connected && aether.latency > 0
              text: aether.latency + " ms"
              font.pixelSize: Style.font.caption
              font.bold: true
              color: aether.latency < 450 ? root.accent : root.urgent
              font.family: root.fontFamily
            }

            Text {
              text: "SOCKS5 :" + aether.proxyPort
              font.pixelSize: Style.font.caption
              color: root.dim
              font.family: root.fontFamily
            }
          }

          PanelSeparator { width: parent.width }

          // Extracted Metrics 2x2 Grid: Uptime, Traffic, Exit IP, Gateway
          GridLayout {
            width: parent.width
            columns: 2
            rowSpacing: Style.space(8)
            columnSpacing: Style.space(12)

            // 1. UPTIME
            Column {
              Layout.fillWidth: true
              spacing: Style.space(2)
              Text {
                text: "UPTIME"
                font.pixelSize: Style.font.caption
                font.bold: true
                color: root.dim
                font.family: root.fontFamily
              }
              Text {
                text: aether.running ? (aether.uptime !== "" ? aether.uptime : "Starting…") : "--"
                font.pixelSize: Style.font.body
                font.bold: true
                color: aether.running ? root.foreground : root.dim
                font.family: root.fontFamily
              }
            }

            // 2. TRAFFIC (Extracted live from daemon stats)
            Column {
              Layout.fillWidth: true
              spacing: Style.space(2)
              Text {
                text: "TRAFFIC (↓ / ↑)"
                font.pixelSize: Style.font.caption
                font.bold: true
                color: root.dim
                font.family: root.fontFamily
              }
              RowLayout {
                spacing: Style.space(4)
                Text {
                  text: aether.running && aether.traffic_down !== "" ? "↓ " + aether.traffic_down : "↓ 0 B"
                  font.pixelSize: Style.font.body
                  font.bold: true
                  color: aether.connected ? root.accent : root.dim
                  font.family: root.fontFamily
                }
                Text {
                  text: "•"
                  font.pixelSize: Style.font.caption
                  color: root.dim
                }
                Text {
                  text: aether.running && aether.traffic_up !== "" ? "↑ " + aether.traffic_up : "↑ 0 B"
                  font.pixelSize: Style.font.body
                  font.bold: true
                  color: aether.connected ? root.foreground : root.dim
                  font.family: root.fontFamily
                }
              }
            }

            // 3. EXIT IP
            Column {
              Layout.fillWidth: true
              spacing: Style.space(2)
              Text {
                text: "EXIT IP"
                font.pixelSize: Style.font.caption
                font.bold: true
                color: root.dim
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

            // 4. GATEWAY COLO
            Column {
              Layout.fillWidth: true
              spacing: Style.space(2)
              Text {
                text: "GATEWAY"
                font.pixelSize: Style.font.caption
                font.bold: true
                color: root.dim
                font.family: root.fontFamily
              }
              Text {
                text: aether.connected ? Model.formatColo(aether.colo, aether.loc) : (aether.running ? "Connecting…" : "--")
                font.pixelSize: Style.font.body
                font.bold: true
                color: aether.connected ? root.foreground : root.dim
                font.family: root.fontFamily
                elide: Text.ElideRight
              }
            }
          }
        }
      }

      PanelSeparator { width: parent.width }

      // Transport Selection. Grouped by the core's actual protocol model:
      // direct Cloudflare WARP carriers vs. third-party circumvention
      // networks whose routing mode is picked in the cards below.
      PanelSectionHeader {
        text: "TRANSPORT PROTOCOL"
        foreground: root.foreground
      }

      Column {
        width: parent.width
        spacing: Style.space(4)

        Text {
          width: parent.width
          text: "DIRECT WARP"
          font.pixelSize: Style.font.caption
          font.bold: true
          color: root.dim
          font.family: root.fontFamily
        }

        RowLayout {
          width: parent.width
          spacing: Style.space(4)

          Button {
            Layout.fillWidth: true
            text: "MASQUE · QUIC"
            selected: aether.protocol === "masque" && !aether.h2
            onClicked: aether.setProtocol("masque", false)
          }

          Button {
            Layout.fillWidth: true
            text: "MASQUE · HTTP/2"
            selected: aether.protocol === "masque" && aether.h2
            onClicked: aether.setProtocol("masque", true)
          }

          Button {
            Layout.fillWidth: true
            text: "WireGuard"
            selected: aether.protocol === "wg"
            onClicked: aether.setConfig("protocol", "wg")
          }
        }

        RowLayout {
          width: parent.width
          spacing: Style.space(4)

          Button {
            Layout.fillWidth: true
            text: "Gool (WG/MASQUE)"
            selected: aether.protocol === "gool"
            onClicked: aether.setConfig("protocol", "gool")
          }

          Button {
            Layout.fillWidth: true
            text: "Gool Classic (WIW)"
            selected: aether.protocol === "gool-classic"
            onClicked: aether.setConfig("protocol", "gool-classic")
          }

          Button {
            Layout.fillWidth: true
            text: "MIM"
            selected: aether.protocol === "mim"
            onClicked: aether.setConfig("protocol", "mim")
          }
        }

        Item { width: 1; height: Style.space(8) }

        Text {
          width: parent.width
          text: "CIRCUMVENTION"
          font.pixelSize: Style.font.caption
          font.bold: true
          color: root.dim
          font.family: root.fontFamily
        }

        RowLayout {
          width: parent.width
          spacing: Style.space(4)

          Button {
            Layout.fillWidth: true
            text: "Psiphon"
            selected: Model.isPsiphon(aether.protocol)
            onClicked: aether.setConfig("protocol", aether.protocol.indexOf("psiphon") === 0 ? aether.protocol : "psiphon")
          }

          Button {
            Layout.fillWidth: true
            text: "Tor"
            selected: Model.isTor(aether.protocol)
            onClicked: aether.setConfig("protocol", aether.protocol.indexOf("tor") === 0 ? aether.protocol : "tor")
          }
        }
      }

      // Inline Psiphon Transport Options Card
      BorderSurface {
        visible: Model.isPsiphon(aether.protocol)
        width: parent.width
        radius: Style.cornerRadius
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.08)
        borderSpec: Border.flat(root.accent, 1)
        implicitHeight: psiphonSubCol.implicitHeight + Style.space(16)

        Column {
          id: psiphonSubCol
          width: parent.width - Style.space(20)
          anchors.centerIn: parent
          spacing: Style.space(8)

          RowLayout {
            width: parent.width
            Text {
              Layout.fillWidth: true
              text: "PSIPHON ROUTING MODE"
              font.pixelSize: Style.font.caption
              font.bold: true
              color: root.accent
              font.family: root.fontFamily
            }
            Text {
              text: "127.0.0.1:" + (aether.psiphon_bind !== "" ? aether.psiphon_bind.split(":").pop() : "1821")
              font.pixelSize: Style.font.caption
              color: root.dim
              font.family: root.fontFamily
            }
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(4)

            Button {
              Layout.fillWidth: true
              text: "WARP → Psiphon"
              selected: aether.protocol === "psiphon"
              onClicked: aether.setConfig("protocol", "psiphon")
            }

            Button {
              Layout.fillWidth: true
              text: "Psiphon → WARP"
              selected: aether.protocol === "psiphon-reverse"
              onClicked: aether.setConfig("protocol", "psiphon-reverse")
            }

            Button {
              Layout.fillWidth: true
              text: "Psiphon Only"
              selected: aether.protocol === "psiphon-only"
              onClicked: aether.setConfig("protocol", "psiphon-only")
            }
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(4)

            Text {
              text: "Region:"
              font.pixelSize: Style.font.caption
              font.bold: true
              color: root.dim
              font.family: root.fontFamily
            }

            Button {
              text: "Auto"
              selected: aether.psiphon_region === ""
              onClicked: aether.setConfig("psiphon_region", "")
            }
            Button {
              text: "DE"
              selected: aether.psiphon_region === "DE"
              onClicked: aether.setConfig("psiphon_region", "DE")
            }
            Button {
              text: "US"
              selected: aether.psiphon_region === "US"
              onClicked: aether.setConfig("psiphon_region", "US")
            }
            Button {
              text: "NL"
              selected: aether.psiphon_region === "NL"
              onClicked: aether.setConfig("psiphon_region", "NL")
            }
            Button {
              text: "CH"
              selected: aether.psiphon_region === "CH"
              onClicked: aether.setConfig("psiphon_region", "CH")
            }

            Item { Layout.fillWidth: true }

            Button {
              text: "Copy Proxy"
              onClicked: aether.copyPsiphonSocksUrl()
            }
          }
        }
      }

      // Inline Tor Transport Options Card
      BorderSurface {
        visible: Model.isTor(aether.protocol)
        width: parent.width
        radius: Style.cornerRadius
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.08)
        borderSpec: Border.flat(root.accent, 1)
        implicitHeight: torSubCol.implicitHeight + Style.space(16)

        Column {
          id: torSubCol
          width: parent.width - Style.space(20)
          anchors.centerIn: parent
          spacing: Style.space(8)

          RowLayout {
            width: parent.width
            Text {
              Layout.fillWidth: true
              text: "TOR ROUTING MODE"
              font.pixelSize: Style.font.caption
              font.bold: true
              color: root.accent
              font.family: root.fontFamily
            }
            Text {
              text: "127.0.0.1:" + (aether.tor_bind !== "" ? aether.tor_bind.split(":").pop() : "1820")
              font.pixelSize: Style.font.caption
              color: root.dim
              font.family: root.fontFamily
            }
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(4)

            Button {
              Layout.fillWidth: true
              text: "WARP → Tor"
              selected: aether.protocol === "tor"
              onClicked: aether.setConfig("protocol", "tor")
            }

            Button {
              Layout.fillWidth: true
              text: "Tor → WARP"
              selected: aether.protocol === "tor-reverse"
              onClicked: aether.setConfig("protocol", "tor-reverse")
            }

            Button {
              Layout.fillWidth: true
              text: "Tor Only"
              selected: aether.protocol === "tor-only"
              onClicked: aether.setConfig("protocol", "tor-only")
            }
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(4)

            Text {
              text: "Relays:"
              font.pixelSize: Style.font.caption
              font.bold: true
              color: root.dim
              font.family: root.fontFamily
            }

            Button {
              text: "Auto"
              selected: aether.tor_relays === "" || aether.tor_relays === "auto"
              onClicked: aether.setConfig("tor_relays", "auto")
            }
            Button {
              text: "Only"
              selected: aether.tor_relays === "only"
              onClicked: aether.setConfig("tor_relays", "only")
            }
            Button {
              text: "Off"
              selected: aether.tor_relays === "off"
              onClicked: aether.setConfig("tor_relays", "off")
            }

            Item { Layout.fillWidth: true }

            Button {
              text: "Copy Proxy"
              onClicked: aether.copyTorSocksUrl()
            }
          }
        }
      }

      // Exit Location Selection Dropdown
      Column {
        width: parent.width
        spacing: Style.space(6)

        RowLayout {
          width: parent.width

          Text {
            text: "EXIT LOCATION"
            font.pixelSize: Style.font.caption
            font.bold: true
            color: root.dim
            font.family: root.fontFamily
          }

          Item { Layout.fillWidth: true }

          Button {
            text: root.customExitExpanded ? "Close Custom" : "Custom…"
            selected: root.customExitExpanded || (aether.exit_loc !== "" && !Model.isPresetExitLoc(aether.exit_loc))
            onClicked: root.customExitExpanded = !root.customExitExpanded
          }
        }

        Dropdown {
          width: parent.width
          showLabel: false
          value: aether.exit_loc
          foreground: root.foreground
          accent: root.accent
          fontFamily: root.fontFamily
          options: {
            var opts = [
              { value: "", label: "🌐 Worldwide (Any)" },
              { value: "DE,SE,NL", label: "🇪🇺 Safe EU (DE, SE, NL)" },
              { value: "!IR,AZ,RU", label: "🚫 Non-Censored (!IR, AZ, RU)" },
              { value: "US", label: "🇺🇸 United States (US)" },
              { value: "DE", label: "🇩🇪 Germany (DE)" },
              { value: "NL", label: "🇳🇱 Netherlands (NL)" },
              { value: "SE", label: "🇸🇪 Sweden (SE)" },
              { value: "GB", label: "🇬🇧 United Kingdom (GB)" },
              { value: "CH", label: "🇨🇭 Switzerland (CH)" },
              { value: "FR", label: "🇫🇷 France (FR)" },
              { value: "CA", label: "🇨🇦 Canada (CA)" },
              { value: "JP", label: "🇯🇵 Japan (JP)" },
              { value: "SG", label: "🇸🇬 Singapore (SG)" },
              { value: "FI", label: "🇫🇮 Finland (FI)" },
              { value: "PL", label: "🇵🇱 Poland (PL)" },
              { value: "AT", label: "🇦🇹 Austria (AT)" },
              { value: "IT", label: "🇮🇹 Italy (IT)" },
              { value: "ES", label: "🇪🇸 Spain (ES)" },
              { value: "AU", label: "🇦🇺 Australia (AU)" }
            ];
            if (aether.exit_loc !== "" && !Model.isPresetExitLoc(aether.exit_loc)) {
              opts.unshift({ value: aether.exit_loc, label: Model.formatExitLocWithFlag(aether.exit_loc) });
            }
            opts.push({ value: "custom", label: "✏️ Custom filter…" });
            return opts;
          }
          onChanged: function(v) {
            if (v === "custom") {
              root.customExitExpanded = true;
            } else {
              root.customExitExpanded = false;
              aether.setExitLoc(v);
            }
          }
        }

        // Collapsible Custom Text Field
        Column {
          visible: root.customExitExpanded || (aether.exit_loc !== "" && !Model.isPresetExitLoc(aether.exit_loc))
          width: parent.width
          spacing: Style.space(4)

          AetherField {
            key: "exit_loc"
            labelText: "Custom Filter (e.g. DE,FR or !IR,RU)"
            hintText: "Refuses any gateway not matching these country codes"
          }
        }
      }

      // Scan Profile
      AetherDropdown {
        key: "scan"
        filterWithSettings: false
        label: "SCAN MODE"
        value: aether.scan
        options: [
          { value: "balanced", label: "Balanced — collect a few, keep the fastest (default)" },
          { value: "turbo", label: "Turbo — first responder wins" },
          { value: "verified", label: "Verified — measured connect-ip edges, split multi-hop" },
          { value: "thorough", label: "Thorough — sweep whole ranges" },
          { value: "ironclad", label: "Ironclad — verify with real traffic" }
        ]
      }

      // Obfuscation / Noize
      AetherDropdown {
        key: "noize"
        filterWithSettings: false
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

        Button {
          Layout.fillWidth: true
          text: "Doctor"
          onClicked: {
            root.currentTab = "logs"
            root.logsSubTab = "doctor"
            aether.runDoctor()
            aether.fetchCommandPreview()
          }
        }
      }
    }
  }

  // -------------------------------------------------------------
  // TAB 2: SETTINGS — categorized configuration & engine management
  // -------------------------------------------------------------
  Component {
    id: tabSettingsComp

    Column {
      width: parent.width
      spacing: Style.space(12)

      // ---------------------------------------------------------
      // Configuration Profiles & Presets
      // ---------------------------------------------------------
      BorderSurface {
        width: parent.width
        radius: Style.cornerRadius
        color: Color.cardFill || Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
        implicitHeight: presetCol.implicitHeight + Style.space(16)

        Column {
          id: presetCol
          width: parent.width - Style.space(20)
          anchors.centerIn: parent
          spacing: Style.space(8)

          RowLayout {
            width: parent.width
            spacing: Style.space(6)

            Text {
              text: "CONFIGURATION PROFILE"
              font.pixelSize: Style.font.caption
              font.bold: true
              color: root.dim
              font.family: root.fontFamily
            }

            Item { Layout.fillWidth: true }

            Text {
              readonly property string activeId: Model.detectActivePreset(aether)
              readonly property int modCount: Model.countModifiedSettings(aether)
              text: activeId !== "" ? ("Active: " + (Model.PRESETS[activeId] ? Model.PRESETS[activeId].name : activeId))
                                    : (modCount > 0 ? ("Custom (" + modCount + " modified)") : "Default")
              font.pixelSize: Style.font.caption
              font.bold: true
              color: activeId !== "" ? root.accent : (modCount > 0 ? root.foreground : root.dim)
              font.family: root.fontFamily
            }
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(4)

            readonly property string activePreset: Model.detectActivePreset(aether)

            Button {
              Layout.fillWidth: true
              text: "Default"
              selected: parent.activePreset === "default"
              onClicked: aether.applyPreset("default")
            }
            Button {
              Layout.fillWidth: true
              text: "Stealth"
              selected: parent.activePreset === "stealth"
              onClicked: aether.applyPreset("stealth")
            }
            Button {
              Layout.fillWidth: true
              text: "Speed"
              selected: parent.activePreset === "speed"
              onClicked: aether.applyPreset("speed")
            }
            Button {
              Layout.fillWidth: true
              text: "Tor"
              selected: parent.activePreset === "tor_multihop"
              onClicked: aether.applyPreset("tor_multihop")
            }
            Button {
              Layout.fillWidth: true
              text: "Psiphon"
              selected: parent.activePreset === "psiphon_bypass"
              onClicked: aether.applyPreset("psiphon_bypass")
            }
          }

          Text {
            width: parent.width
            wrapMode: Text.Wrap
            text: Model.getPresetDescription(Model.detectActivePreset(aether))
            font.pixelSize: Style.font.caption
            color: root.dim
            font.family: root.fontFamily
          }
        }
      }

      // ---------------------------------------------------------
      // Search & Filter Controls
      // ---------------------------------------------------------
      RowLayout {
        width: parent.width
        spacing: Style.space(6)

        TextField {
          id: searchInput
          Layout.fillWidth: true
          placeholderText: "Search 97 settings (e.g. fragment, tls, dns, ech)…"
          text: root.settingsSearchQuery
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          foreground: root.foreground
          accent: root.accent
          onTextChanged: root.settingsSearchQuery = text
        }

        Button {
          visible: root.settingsSearchQuery !== ""
          text: "Clear"
          onClicked: {
            root.settingsSearchQuery = ""
            searchInput.text = ""
          }
        }
      }

      RowLayout {
        width: parent.width
        spacing: Style.space(4)

        Button {
          Layout.fillWidth: true
          text: root.showAdvancedSettings ? "Mode: Advanced (All 97 Settings)" : "Mode: Basic (Essential Settings)"
          selected: root.showAdvancedSettings
          onClicked: root.showAdvancedSettings = !root.showAdvancedSettings
        }

        Button {
          readonly property int modCount: Model.countModifiedSettings(aether)
          text: "Reset All"
          accent: root.urgent
          enabled: modCount > 0
          onClicked: root.confirmResetAll = true
        }
      }

      // Category Navigation Grid (2 rows x 4 columns, balanced alignment)
      GridLayout {
        width: parent.width
        columns: 4
        rowSpacing: Style.space(4)
        columnSpacing: Style.space(4)

        readonly property int modCount: Model.countModifiedSettings(aether)

        Button {
          Layout.fillWidth: true
          text: "All"
          selected: root.settingsCategory === "all"
          onClicked: root.settingsCategory = "all"
        }

        Button {
          Layout.fillWidth: true
          text: aether.core_update_available ? "Core •" : "Core"
          selected: root.settingsCategory === "core"
          onClicked: root.settingsCategory = "core"
        }

        Button {
          Layout.fillWidth: true
          text: "Network"
          selected: root.settingsCategory === "network"
          onClicked: root.settingsCategory = "network"
        }

        Button {
          Layout.fillWidth: true
          text: "TLS 1.3"
          selected: root.settingsCategory === "tls"
          onClicked: root.settingsCategory = "tls"
        }

        Button {
          Layout.fillWidth: true
          text: "Bypass"
          selected: root.settingsCategory === "circumvention"
          onClicked: root.settingsCategory = "circumvention"
        }

        Button {
          Layout.fillWidth: true
          text: "Routing"
          selected: root.settingsCategory === "routing"
          onClicked: root.settingsCategory = "routing"
        }

        Button {
          Layout.fillWidth: true
          text: "Zero Trust"
          selected: root.settingsCategory === "zerotrust"
          onClicked: root.settingsCategory = "zerotrust"
        }

        Button {
          Layout.fillWidth: true
          text: parent.modCount > 0 ? ("Modified (" + parent.modCount + ")") : "Modified"
          selected: root.settingsCategory === "modified"
          accent: parent.modCount > 0 ? root.accent : root.foreground
          onClicked: root.settingsCategory = "modified"
        }
      }

      // Empty State for Search or Modified filter
      BorderSurface {
        visible: (root.settingsSearchQuery !== "" || root.settingsCategory === "modified") && Model.filterSchema(root.settingsSearchQuery, root.settingsCategory, root.showAdvancedSettings, root.settingsCategory === "modified", aether).length === 0
        width: parent.width
        radius: Style.cornerRadius
        color: Color.cardFill || Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
        implicitHeight: Style.space(64)

        Column {
          anchors.centerIn: parent
          spacing: Style.space(4)
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.settingsCategory === "modified" ? "No settings have been modified from default" : ("No settings match \"" + root.settingsSearchQuery + "\"")
            font.family: root.fontFamily
            font.pixelSize: Style.font.body
            color: root.dim
          }
          Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.settingsCategory === "modified" ? "All options are currently using factory defaults." : (root.showAdvancedSettings ? "Try another keyword or clear search." : "Try switching to Advanced Mode to view all 97 settings.")
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            color: root.dim
          }
        }
      }

      // =========================================================
      // CATEGORY: CORE & ENGINE
      // =========================================================
      Column {
        width: parent.width
        spacing: Style.space(10)
        visible: root.isCategoryVisible("core")

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

              Item { Layout.fillWidth: true }

              Button {
                visible: aether.binary !== ""
                text: "Remove"
                enabled: !aether.actionInProgress
                onClicked: root.pendingRemovePath = aether.binary
              }
            }
          }
        }

        // Aether core update available banner
        BorderSurface {
          visible: aether.core_update_available
          width: parent.width
          radius: Style.cornerRadius
          color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.12)
          borderSpec: Border.flat(root.accent, 1)
          implicitHeight: updateCoreCol.implicitHeight + Style.space(20)

          Column {
            id: updateCoreCol
            width: parent.width - Style.space(24)
            anchors.centerIn: parent
            spacing: Style.space(8)

            Text {
              width: parent.width
              text: "Aether Core Update Available"
              color: root.accent
              font.bold: true
              font.family: root.fontFamily
              font.pixelSize: Style.font.subtitle
            }

            Text {
              width: parent.width
              wrapMode: Text.Wrap
              text: "A newer Aether core is pinned by the plugin (" + (aether.binaryVersion !== "" ? aether.binaryVersion : "installed") + " → " + aether.core_pinned_version + "). Update to get the latest core release."
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }

            Button {
              text: aether.installing ? "Downloading Official Release…" : "Update Core to " + (aether.core_pinned_version !== "" ? aether.core_pinned_version : "Latest")
              accent: root.accent
              bordered: true
              enabled: !aether.installing
              onClicked: aether.updateAetherCore()
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
          text: "Searched in order: custom path, ~/.local/share/omarchy-aether/bin, ~/Downloads/Aether, plugin bin/, ~/.local/bin, /usr/local/bin, /opt/aether, then $PATH."
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
                enabled: !aether.actionInProgress
                onClicked: root.pendingRemovePath = modelData
              }
            }
          }
        }

        Button {
          width: parent.width
          text: aether.installing ? "Downloading Official Aether Core…" : "Download Latest Official Release"
          enabled: !aether.installing
          accent: root.accent
          bordered: true
          onClicked: aether.installAether()
        }

        PanelSeparator { width: parent.width }

        PanelSectionHeader {
          visible: root.isSectionVisible(["scan", "noize", "h2", "perf", "log_level", "quick_reconnect", "no_data_check", "no_profile_retry", "mark"])
          text: "SYSTEM & ENGINE PROFILES"
          foreground: root.foreground
        }

        AetherDropdown {
          key: "scan"
          category: "core"
          label: "SCAN STRATEGY"
          value: aether.scan
          options: [
            { value: "balanced", label: "Balanced — collect a few, keep fastest (default)" },
            { value: "turbo", label: "Turbo — first responder wins" },
            { value: "verified", label: "Verified — measured connect-ip edges" },
            { value: "thorough", label: "Thorough — sweep entire subnet ranges" },
            { value: "ironclad", label: "Ironclad — live data-plane verified" }
          ]
        }

        AetherDropdown {
          key: "noize"
          category: "core"
          label: "NOIZE / OBFUSCATION PROFILE"
          value: aether.noize
          options: [
            { value: "firewall", label: "Firewall — default for MASQUE" },
            { value: "balanced", label: "Balanced — default for WireGuard" },
            { value: "light", label: "Light — subtle packet shaping" },
            { value: "gfw", label: "GFW — hardened against deep inspection" },
            { value: "aggressive", label: "Aggressive — maximum packet padding" },
            { value: "off", label: "Off — standard packet stream" }
          ]
        }

        AetherToggle {
          key: "h2"
          category: "core"
          label: "MASQUE over HTTP/2"
          description: "Use TCP HTTP/2 instead of QUIC (useful when UDP is blocked by ISP)"
          checked: aether.h2
          onClicked: aether.setConfig("h2", aether.h2 ? "0" : "1")
        }

        AetherDropdown {
          key: "perf"
          category: "core"
          isAdvanced: true
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
          category: "core"
          label: "LOG LEVEL"
          value: aether.log_level
          options: ["error", "warn", "info", "debug", "trace"]
        }

        AetherToggle {
          key: "quick_reconnect"
          category: "core"
          label: "Quick Reconnect"
          description: "Fast-resume connection using the last verified gateway"
          checked: aether.quick_reconnect
          onClicked: aether.setConfig("quick_reconnect", aether.quick_reconnect ? "0" : "1")
        }

        AetherToggle {
          key: "no_data_check"
          category: "core"
          isAdvanced: true
          label: "Skip Data-Plane Probe"
          description: "Skip HTTP probe verification (connects faster but less resilient)"
          checked: aether.no_data_check
          onClicked: aether.setConfig("no_data_check", aether.no_data_check ? "0" : "1")
        }

        AetherToggle {
          key: "no_profile_retry"
          category: "core"
          isAdvanced: true
          label: "No Obfuscation Profile Retry"
          description: "Do not retry other noise/padding profiles if connection fails"
          checked: aether.no_profile_retry
          onClicked: aether.setConfig("no_profile_retry", aether.no_profile_retry ? "0" : "1")
        }

        AetherToggle {
          key: "mark"
          category: "core"
          isAdvanced: true
          label: "Firewall Mark (SO_MARK 0xff)"
          description: "Attach mark for router / transparent tun2socks bypass (requires CAP_NET_ADMIN)"
          checked: aether.mark_enabled
          onClicked: aether.setConfig("mark", aether.mark_enabled ? "0" : "1")
        }

        ResponsiveFormGrid {
          id: coreTimingGrid
          width: parent.width

          AetherField { width: coreTimingGrid.cellWidth; key: "keepalive"; category: "core"; isAdvanced: true; labelText: "WireGuard keepalive (s)" }
          AetherField { width: coreTimingGrid.cellWidth; key: "validate_secs"; category: "core"; isAdvanced: true; labelText: "Data-plane validate (s)" }
          AetherField { width: coreTimingGrid.cellWidth; key: "startup_secs"; category: "core"; isAdvanced: true; labelText: "MASQUE startup deadline (s)" }
          AetherField { width: coreTimingGrid.cellWidth; key: "reconnect_secs"; category: "core"; isAdvanced: true; labelText: "Reconnect delay (s)" }
        }

        AetherField {
          key: "extra_args"
          category: "core"
          isAdvanced: true
          labelText: "Extra core arguments (verbatim)"
          hintText: "Appended as-is to core CLI arguments, split on spaces (e.g. --verbose or --ironclad-port 80)."
        }
      }

      // =========================================================
      // CATEGORY: NETWORK & PORTS
      // =========================================================
      Column {
        width: parent.width
        spacing: Style.space(10)
        visible: root.isCategoryVisible("network")

        PanelSectionHeader {
          visible: root.isSectionVisible(["ip"])
          text: "IP VERSION"
          foreground: root.foreground
        }

        RowLayout {
          visible: root.isSectionVisible(["ip"])
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

        PanelSectionHeader {
          visible: root.isSectionVisible(["socks_port", "http_proxy_port", "dns", "upstream", "routes_file"])
          text: "PORTS & RESOLVERS"
          foreground: root.dim
        }

        ResponsiveFormGrid {
          id: portsPair
          width: parent.width

          AetherField { width: portsPair.cellWidth; key: "socks_port"; category: "network"; labelText: "SOCKS5 port" }
          AetherField { width: portsPair.cellWidth; key: "http_proxy_port"; category: "network"; labelText: "HTTP CONNECT port (0 = off)" }
        }

        AetherField { key: "dns"; category: "network"; labelText: "Tunnel resolvers" }
        AetherField {
          key: "upstream"
          category: "network"
          isAdvanced: true
          labelText: "Upstream proxy URL"
          hintText: "e.g. socks5://127.0.0.1:9050. Non-zero port required."
        }
        AetherField { key: "routes_file"; category: "network"; isAdvanced: true; labelText: "Routes file (--routes)" }

        PanelSectionHeader {
          visible: root.isSectionVisible(["route_block", "route_direct"])
          text: "ROUTING RULES & BYPASS"
          foreground: root.dim
        }

        AetherField { key: "route_block"; category: "network"; isAdvanced: true; labelText: "Route block list (domains, CIDRs, port:, private)" }
        AetherField { key: "route_direct"; category: "network"; isAdvanced: true; labelText: "Route direct list (bypasses the tunnel)" }

        PanelSectionHeader {
          visible: root.isSectionVisible(["peer", "wg_peer", "gool_peer", "h2_peer", "wiw_outer", "wiw_inner", "mim_outer", "mim_inner"])
          text: "STATIC PEERS & ENDPOINTS"
          foreground: root.dim
        }

        ResponsiveFormGrid {
          id: peersGrid
          width: parent.width

          AetherField { width: peersGrid.cellWidth; key: "peer"; category: "network"; isAdvanced: true; labelText: "Forced peer (ip:port)" }
          AetherField { width: peersGrid.cellWidth; key: "wg_peer"; category: "network"; isAdvanced: true; labelText: "WireGuard peer (--wg-peer)" }
          AetherField { width: peersGrid.cellWidth; key: "gool_peer"; category: "network"; isAdvanced: true; labelText: "Gool peer (--gool-peer)" }
          AetherField { width: peersGrid.cellWidth; key: "h2_peer"; category: "network"; isAdvanced: true; labelText: "HTTP/2 peer (--h2-peer)" }
          AetherField { width: peersGrid.cellWidth; key: "wiw_outer"; category: "network"; isAdvanced: true; labelText: "WiW outer hop (ip:port)" }
          AetherField { width: peersGrid.cellWidth; key: "wiw_inner"; category: "network"; isAdvanced: true; labelText: "WiW inner hop (ip:port)" }
          AetherField { width: peersGrid.cellWidth; key: "mim_outer"; category: "network"; isAdvanced: true; labelText: "MIM outer hop (ip:port)" }
          AetherField { width: peersGrid.cellWidth; key: "mim_inner"; category: "network"; isAdvanced: true; labelText: "MIM inner hop (ip:port)" }
        }
      }

      // =========================================================
      // CATEGORY: TLS 1.3 & FINGERPRINT EVASION (Aether Core v2.4.0)
      // =========================================================
      Column {
        width: parent.width
        spacing: Style.space(10)
        visible: root.isCategoryVisible("tls")

        PanelSectionHeader {
          visible: root.isSectionVisible(["fragment", "fragment_size", "fragment_delay", "ech", "ech_dns", "ech_domain", "enable_ech_grease"])
          text: "TLS 1.3 CLIENTHELLO FRAGMENTATION & ECH"
          foreground: root.foreground
        }

        AetherToggle {
          key: "fragment"
          category: "tls"
          label: "ClientHello Fragmentation"
          description: "Fragment ClientHello across records to bypass deep packet inspection (DPI)"
          checked: aether.fragment
          onClicked: aether.setConfig("fragment", aether.fragment ? "0" : "1")
        }

        ResponsiveFormGrid {
          id: fragPair
          width: parent.width

          AetherField { width: fragPair.cellWidth; key: "fragment_size"; category: "tls"; labelText: "Fragment size (bytes, default 8-16)" }
          AetherField { width: fragPair.cellWidth; key: "fragment_delay"; category: "tls"; labelText: "Fragment delay (ms, default 2-10)" }
        }

        AetherDropdown {
          key: "ech"
          category: "tls"
          label: "ENCRYPTED CLIENT HELLO (ECH)"
          value: aether.ech
          options: [
            { value: "off", label: "Off — standard unencrypted SNI" },
            { value: "auto", label: "Auto — negotiate ECH via DoH / DNS" }
          ]
        }

        ResponsiveFormGrid {
          id: echGrid
          width: parent.width

          AetherField { width: echGrid.cellWidth; key: "ech_dns"; category: "tls"; isAdvanced: true; labelText: "ECH DoH resolver URL" }
          AetherField { width: echGrid.cellWidth; key: "ech_domain"; category: "tls"; isAdvanced: true; labelText: "ECH outer domain SNI" }
        }

        AetherToggle {
          key: "enable_ech_grease"
          category: "tls"
          isAdvanced: true
          label: "Enable ECH GREASE"
          description: "Send synthetic ECH GREASE extension when real ECH is not used"
          checked: aether.enable_ech_grease
          onClicked: aether.setConfig("enable_ech_grease", aether.enable_ech_grease ? "0" : "1")
        }

        PanelSectionHeader {
          visible: root.isSectionVisible(["tls_verify", "tls13_ciphers", "tls_ciphers", "tls_groups", "tls_key_shares", "tls_sigalgs", "tls_server_padding", "tls_cert_compression", "tls_alps", "enable_grease_sigalgs", "disable_grease", "disable_ocsp_stapling", "disable_sct", "disable_session_ticket", "disable_extension_permutation"])
          text: "CIPHERS & SIGNATURE SUITES (v2.4.0)"
          foreground: root.dim
        }

        AetherDropdown {
          key: "tls_verify"
          category: "tls"
          isAdvanced: true
          label: "TLS CERTIFICATE VERIFICATION"
          value: aether.tls_verify
          options: [
            { value: "auto", label: "Auto — required for Zero Trust, optional for WARP" },
            { value: "1", label: "Strict — enforce certificate verification on all connections" },
            { value: "0", label: "Disabled — allow unverified / self-signed upstream certs" }
          ]
        }

        AetherField { key: "tls13_ciphers"; category: "tls"; isAdvanced: true; labelText: "TLS 1.3 ciphers (--tls13-ciphers)" }
        AetherField { key: "tls_ciphers"; category: "tls"; isAdvanced: true; labelText: "TLS 1.2 ciphers (--tls-ciphers)" }

        ResponsiveFormGrid {
          id: tlsCurveGrid
          width: parent.width

          AetherField { width: tlsCurveGrid.cellWidth; key: "tls_groups"; category: "tls"; isAdvanced: true; labelText: "TLS curve groups (e.g. X25519:P-256)" }
          AetherField { width: tlsCurveGrid.cellWidth; key: "tls_key_shares"; category: "tls"; isAdvanced: true; labelText: "TLS key shares (e.g. X25519)" }
          AetherField { width: tlsCurveGrid.cellWidth; key: "tls_sigalgs"; category: "tls"; isAdvanced: true; labelText: "TLS signature algorithms" }
          AetherField { width: tlsCurveGrid.cellWidth; key: "tls_server_padding"; category: "tls"; isAdvanced: true; labelText: "Server name padding (bytes)" }
        }

        ResponsiveFormGrid {
          id: tlsAlpsGrid
          width: parent.width

          AetherField { width: tlsAlpsGrid.cellWidth; key: "tls_cert_compression"; category: "tls"; isAdvanced: true; labelText: "Cert compression (brotli/zstd)" }
          AetherDropdown {
            width: tlsAlpsGrid.cellWidth
            key: "tls_alps"
            category: "tls"
            isAdvanced: true
            label: "ALPS DRAFT"
            value: aether.tls_alps
            options: [
              { value: "", label: "Default — BoringSSL automatic" },
              { value: "new", label: "New draft" },
              { value: "old", label: "Legacy draft" }
            ]
          }
        }

        AetherToggle {
          key: "enable_grease_sigalgs"
          category: "tls"
          isAdvanced: true
          label: "GREASE Signature Algorithms"
          description: "Inject GREASE into signature algorithms extension"
          checked: aether.enable_grease_sigalgs
          onClicked: aether.setConfig("enable_grease_sigalgs", aether.enable_grease_sigalgs ? "0" : "1")
        }

        AetherToggle {
          key: "disable_grease"
          category: "tls"
          isAdvanced: true
          label: "Disable TLS GREASE"
          description: "Omit all GREASE extensions from ClientHello"
          checked: aether.disable_grease
          onClicked: aether.setConfig("disable_grease", aether.disable_grease ? "0" : "1")
        }

        AetherToggle {
          key: "disable_ocsp_stapling"
          category: "tls"
          isAdvanced: true
          label: "Disable OCSP Stapling"
          description: "Do not request OCSP stapled status"
          checked: aether.disable_ocsp_stapling
          onClicked: aether.setConfig("disable_ocsp_stapling", aether.disable_ocsp_stapling ? "0" : "1")
        }

        AetherToggle {
          key: "disable_sct"
          category: "tls"
          isAdvanced: true
          label: "Disable Signed Cert Timestamps"
          description: "Do not request Certificate Transparency SCTs"
          checked: aether.disable_sct
          onClicked: aether.setConfig("disable_sct", aether.disable_sct ? "0" : "1")
        }

        AetherToggle {
          key: "disable_session_ticket"
          category: "tls"
          isAdvanced: true
          label: "Disable Session Resumption Tickets"
          description: "Omit session resumption ticket extension"
          checked: aether.disable_session_ticket
          onClicked: aether.setConfig("disable_session_ticket", aether.disable_session_ticket ? "0" : "1")
        }

        AetherToggle {
          key: "disable_extension_permutation"
          category: "tls"
          isAdvanced: true
          label: "Disable Extension Permutation"
          description: "Preserve fixed order of TLS extensions instead of randomizing order"
          checked: aether.disable_extension_permutation
          onClicked: aether.setConfig("disable_extension_permutation", aether.disable_extension_permutation ? "0" : "1")
        }

        PanelSectionHeader {
          visible: root.isSectionVisible(["api_address", "api_host", "api_sni", "masque_sni"])
          text: "WARP API & GATEWAY SNI"
          foreground: root.dim
        }

        ResponsiveFormGrid {
          id: warpApiGrid
          width: parent.width

          AetherField { width: warpApiGrid.cellWidth; key: "api_address"; category: "tls"; isAdvanced: true; labelText: "WARP API endpoint (ip:port)" }
          AetherField { width: warpApiGrid.cellWidth; key: "api_host"; category: "tls"; isAdvanced: true; labelText: "WARP API Host header" }
          AetherField { width: warpApiGrid.cellWidth; key: "api_sni"; category: "tls"; isAdvanced: true; labelText: "WARP API TLS SNI" }
          AetherField { width: warpApiGrid.cellWidth; key: "masque_sni"; category: "tls"; isAdvanced: true; labelText: "MASQUE gateway SNI" }
        }
      }

      // =========================================================
      // CATEGORY: CIRCUMVENTION (TOR & PSIPHON)
      // =========================================================
      Column {
        width: parent.width
        spacing: Style.space(10)
        visible: root.isCategoryVisible("circumvention")

        PanelSectionHeader {
          visible: root.isSectionVisible(["psiphon_mode", "psiphon_region", "psiphon_bind", "psiphon_http", "psiphon_cdn_ips", "psiphon_cdn_sni", "psiphon_config"])
          text: "PSIPHON CIRCUMVENTION (V2.1)"
          foreground: root.foreground
        }

        Dropdown {
          visible: root.isSectionVisible(["psiphon_mode", "psiphon_region", "psiphon_bind", "psiphon_http", "psiphon_cdn_ips", "psiphon_cdn_sni", "psiphon_config"])
          width: parent.width
          label: "PSIPHON PROTOCOL MODE"
          value: root.psiphonMode(aether.protocol)
          foreground: root.foreground
          accent: root.accent
          fontFamily: root.fontFamily
          options: [
            { value: "off", label: "Disabled (use primary protocol)" },
            { value: "psiphon", label: "WARP → Psiphon (carry Psiphon inside tunnel)" },
            { value: "psiphon-reverse", label: "Psiphon → WARP (dial tunnel through Psiphon)" },
            { value: "psiphon-only", label: "Psiphon only — standalone proxy without WARP" }
          ]
          onChanged: function(v) { aether.setConfig("protocol", v === "off" ? "masque" : v) }
        }

        AetherDropdown {
          key: "psiphon_mode"
          category: "circumvention"
          label: "PSIPHON TRANSPORT MODE"
          value: aether.psiphon_mode
          options: [
            { value: "auto", label: "Auto — let Psiphon pick best egress" },
            { value: "cdn", label: "CDN — fronted meek through CDN only (firewall bypass)" },
            { value: "direct", label: "Direct — direct egress without CDN fronting" }
          ]
        }

        AetherField { key: "psiphon_region"; category: "circumvention"; labelText: "Psiphon egress country code (e.g. DE, US, NL, CH)" }

        ResponsiveFormGrid {
          id: psiphonGrid
          width: parent.width

          AetherField { width: psiphonGrid.cellWidth; key: "psiphon_bind"; category: "circumvention"; isAdvanced: true; labelText: "Psiphon SOCKS5 bind (default 127.0.0.1:1821)" }
          AetherField { width: psiphonGrid.cellWidth; key: "psiphon_http"; category: "circumvention"; isAdvanced: true; labelText: "Psiphon HTTP proxy bind address" }
          AetherField { width: psiphonGrid.cellWidth; key: "psiphon_cdn_ips"; category: "circumvention"; isAdvanced: true; labelText: "CDN fronting IP list (comma-separated)" }
          AetherField { width: psiphonGrid.cellWidth; key: "psiphon_cdn_sni"; category: "circumvention"; isAdvanced: true; labelText: "CDN fronting SNI names" }
        }

        AetherField { key: "psiphon_config"; category: "circumvention"; isAdvanced: true; labelText: "Psiphon custom JSON config file (--psiphon-config)" }

        PanelSectionHeader {
          visible: root.isSectionVisible(["tor_relays", "tor_relay_ports", "tor_bridges", "tor_bind", "tor_http", "tor_country", "tor_bridge_file", "tor_bridge", "tor_pt"])
          text: "TOR ONION NETWORK (V2.1)"
          foreground: root.foreground
        }

        Dropdown {
          visible: root.isSectionVisible(["tor_relays", "tor_relay_ports", "tor_bridges", "tor_bind", "tor_http", "tor_country", "tor_bridge_file", "tor_bridge", "tor_pt"])
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
          key: "tor_relays"
          category: "circumvention"
          label: "TOR ONIONOO RELAYS"
          value: aether.tor_relays !== "" ? aether.tor_relays : "auto"
          options: [
            { value: "auto", label: "Auto — Onionoo relays alongside BridgeDB (recommended)" },
            { value: "only", label: "Only — use Onionoo relays exclusively as bridges" },
            { value: "off", label: "Off — BridgeDB bridges only" }
          ]
        }

        AetherDropdown {
          key: "tor_relay_ports"
          category: "circumvention"
          label: "TOR RELAY PORTS"
          value: aether.tor_relay_ports !== "" ? aether.tor_relay_ports : "web"
          options: [
            { value: "web", label: "Web ports only (80 and 443 — firewall stealth)" },
            { value: "any", label: "Any ports — all running relay ports" }
          ]
        }

        AetherDropdown {
          key: "tor_bridges"
          category: "circumvention"
          label: "TOR BRIDGES"
          value: aether.tor_bridges
          options: [
            { value: "", label: "Auto — try plain Tor, fall back to bridges" },
            { value: "on", label: "Always use bridges" },
            { value: "off", label: "Never use bridges" }
          ]
        }

        ResponsiveFormGrid {
          id: torGrid
          width: parent.width

          AetherField { width: torGrid.cellWidth; key: "tor_bind"; category: "circumvention"; isAdvanced: true; labelText: "Tor proxy bind address" }
          AetherField { width: torGrid.cellWidth; key: "tor_http"; category: "circumvention"; isAdvanced: true; labelText: "Tor HTTP proxy address (--tor-http)" }
          AetherField { width: torGrid.cellWidth; key: "tor_country"; category: "circumvention"; labelText: "Bridge country (e.g. ir)" }
          AetherField { width: torGrid.cellWidth; key: "tor_bridge_file"; category: "circumvention"; isAdvanced: true; labelText: "Tor bridge list file (--tor-bridge-file)" }
        }

        AetherField { key: "tor_bridge"; category: "circumvention"; isAdvanced: true; labelText: "Custom bridge line (obfs4 1.2.3.4:443 …)" }
        AetherField { key: "tor_pt"; category: "circumvention"; isAdvanced: true; labelText: "Pluggable transport binary ([name=]/path)" }
      }

      // =========================================================
      // CATEGORY: SYSTEM ROUTING (ZEPTUN TUN)
      // =========================================================
      Column {
        width: parent.width
        spacing: Style.space(10)
        visible: root.isCategoryVisible("routing")

        PanelSectionHeader {
          visible: root.isSectionVisible(["sysroute_enabled", "sysroute_preset", "sysroute_mtu", "sysroute_dns_mode", "sysroute_dns_servers", "sysroute_fake_ip", "sysroute_dns_hijack", "sysroute_strict_route", "sysroute_auto_redirect", "sysroute_exclude", "sysroute_exclude_uids", "sysroute_persistent"])
          text: "ZEPTUN TUN ENGINE"
          foreground: root.foreground
        }

        BorderSurface {
          visible: root.isSectionVisible(["sysroute_enabled", "sysroute_preset", "sysroute_mtu", "sysroute_dns_mode", "sysroute_dns_servers", "sysroute_fake_ip", "sysroute_dns_hijack", "sysroute_strict_route", "sysroute_auto_redirect", "sysroute_exclude", "sysroute_exclude_uids", "sysroute_persistent"]) && aether.zeptun_available
          width: parent.width
          radius: Style.cornerRadius
          implicitHeight: Style.space(40)
          color: "transparent"
          borderSpec: Border.controlSpec("normal", root.foreground, root.accent)

          RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Style.space(10)
            anchors.rightMargin: Style.space(10)
            spacing: Style.space(8)

            Text {
              Layout.fillWidth: true
              text: aether.zeptun_binary !== "" ? aether.zeptun_binary : "Zeptun"
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              color: root.foreground
              elide: Text.ElideMiddle
            }

            Button {
              text: "Remove"
              enabled: !aether.actionInProgress
              onClicked: root.pendingRemoveZeptunPath = (aether.zeptun_binary !== "" ? aether.zeptun_binary : "zeptun")
            }
          }
        }

        Button {
          visible: root.isSectionVisible(["sysroute_enabled", "sysroute_preset", "sysroute_mtu", "sysroute_dns_mode", "sysroute_dns_servers", "sysroute_fake_ip", "sysroute_dns_hijack", "sysroute_strict_route", "sysroute_auto_redirect", "sysroute_exclude", "sysroute_exclude_uids", "sysroute_persistent"]) && !aether.zeptun_available
          width: parent.width
          text: aether.installing ? "Downloading Zeptun…" : "Download & Install Zeptun"
          enabled: !aether.installing
          accent: root.accent
          bordered: true
          onClicked: aether.runAction(["zeptun-install"], "Downloading Zeptun…")
        }

        AetherToggle {
          key: "sysroute_enabled"
          category: "routing"
          label: "System-Wide TUN Routing"
          description: "Route all OS network traffic transparently through Aether"
          checked: aether.sysroute_enabled
          onClicked: aether.setConfig("sysroute_enabled", aether.sysroute_enabled ? "0" : "1")
        }

        AetherDropdown {
          key: "sysroute_preset"
          category: "routing"
          label: "ROUTING NETWORK PROFILE"
          value: aether.sysroute_preset
          options: [
            { value: "desktop", label: "Desktop — standard MTU 1500, full offload" },
            { value: "mobile", label: "Mobile — battery-conscious, MTU 1420" },
            { value: "server", label: "Server — maximum throughput, minimal logs" }
          ]
        }

        ResponsiveFormGrid {
          id: sysrouteGrid
          width: parent.width

          AetherField { width: sysrouteGrid.cellWidth; key: "sysroute_mtu"; category: "routing"; labelText: "TUN device MTU (default 1500)" }
          AetherDropdown {
            width: sysrouteGrid.cellWidth
            key: "sysroute_dns_mode"
            category: "routing"
            label: "DNS MODE"
            value: aether.sysroute_dns_mode
            options: [
              { value: "systemd_resolved", label: "systemd-resolved" },
              { value: "hijack", label: "Direct hijack" },
              { value: "off", label: "Off" }
            ]
          }
        }

        AetherField { key: "sysroute_dns_servers"; category: "routing"; labelText: "In-tunnel DNS servers" }

        AetherToggle {
          key: "sysroute_fake_ip"
          category: "routing"
          label: "Fake-IP Address Pool"
          description: "Remote SOCKS5 DNS resolution (eliminates ISP leaks, recommended for Tor/Psiphon)"
          checked: aether.sysroute_fake_ip
          onClicked: aether.setConfig("sysroute_fake_ip", aether.sysroute_fake_ip ? "0" : "1")
        }

        AetherToggle {
          key: "sysroute_dns_hijack"
          category: "routing"
          isAdvanced: true
          label: "Hijack Outbound Port 53"
          description: "Capture all port 53 DNS queries to any IP"
          checked: aether.sysroute_dns_hijack
          onClicked: aether.setConfig("sysroute_dns_hijack", aether.sysroute_dns_hijack ? "0" : "1")
        }

        AetherToggle {
          key: "sysroute_strict_route"
          category: "routing"
          isAdvanced: true
          label: "Strict Routing (Leak Protection)"
          description: "Block unproxied traffic families to guarantee zero leakage"
          checked: aether.sysroute_strict_route
          onClicked: aether.setConfig("sysroute_strict_route", aether.sysroute_strict_route ? "0" : "1")
        }

        AetherToggle {
          key: "sysroute_auto_redirect"
          category: "routing"
          isAdvanced: true
          label: "Kernel TCP Redirection (nftables)"
          description: "Accelerate TCP directly inside kernel space via nftables netlink"
          checked: aether.sysroute_auto_redirect
          onClicked: aether.setConfig("sysroute_auto_redirect", aether.sysroute_auto_redirect ? "0" : "1")
        }

        AetherField { key: "sysroute_exclude"; category: "routing"; isAdvanced: true; labelText: "Excluded subnets (CIDRs bypassed from tunnel)" }
        AetherField { key: "sysroute_exclude_uids"; category: "routing"; isAdvanced: true; labelText: "Excluded Linux UIDs (users kept off tunnel)" }

        AetherToggle {
          key: "sysroute_persistent"
          category: "routing"
          isAdvanced: true
          label: "Persistent Auto-Start"
          description: "Automatically re-activate system routing whenever Aether connects"
          checked: aether.sysroute_persistent
          onClicked: aether.setConfig("sysroute_persistent", aether.sysroute_persistent ? "0" : "1")
        }
      }

      // =========================================================
      // CATEGORY: ZERO TRUST
      // =========================================================
      Column {
        width: parent.width
        spacing: Style.space(10)
        visible: root.isCategoryVisible("zerotrust")

        PanelSectionHeader {
          visible: root.isSectionVisible(["team", "access_id", "access_secret", "access_token", "access_email", "enroll_address", "gateway"])
          text: "CLOUDFLARE ZERO TRUST"
          foreground: root.foreground
        }

        AetherField { key: "team"; category: "zerotrust"; labelText: "Team organization slug" }

        ResponsiveFormGrid {
          id: accessGrid
          width: parent.width

          AetherField { width: accessGrid.cellWidth; key: "access_id"; category: "zerotrust"; isAdvanced: true; labelText: "Service token ID" }
          AetherField { width: accessGrid.cellWidth; secret: true; key: "access_secret"; category: "zerotrust"; isAdvanced: true; labelText: "Service token secret" }
          AetherField { width: accessGrid.cellWidth; secret: true; key: "access_token"; category: "zerotrust"; isAdvanced: true; labelText: "Enrolment token (JWT)" }
          AetherField { width: accessGrid.cellWidth; key: "access_email"; category: "zerotrust"; isAdvanced: true; labelText: "Enrolment email" }
          AetherField { width: accessGrid.cellWidth; key: "enroll_address"; category: "zerotrust"; isAdvanced: true; labelText: "Enrollment API host/address" }
        }

        AetherToggle {
          key: "gateway"
          category: "zerotrust"
          label: "Organization Gateway Inspection"
          description: "Route HTTP(S) through Zero Trust gateway"
          checked: aether.gateway
          onClicked: aether.setConfig("gateway", aether.gateway ? "0" : "1")
        }
      }

      // ---------------------------------------------------------
      // Configuration Management & Backup
      // ---------------------------------------------------------
      PanelSeparator {
        visible: root.settingsSearchQuery === "" && (root.settingsCategory === "all" || root.settingsCategory === "core")
        width: parent.width
      }

      PanelSectionHeader {
        visible: root.settingsSearchQuery === "" && (root.settingsCategory === "all" || root.settingsCategory === "core")
        text: "CONFIGURATION MANAGEMENT & BACKUP"
        foreground: root.foreground
      }

      BorderSurface {
        visible: root.settingsSearchQuery === "" && (root.settingsCategory === "all" || root.settingsCategory === "core")
        width: parent.width
        radius: Style.cornerRadius
        color: Color.cardFill || Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.04)
        implicitHeight: backupCol.implicitHeight + Style.space(20)

        Column {
          id: backupCol
          width: parent.width - Style.space(20)
          anchors.centerIn: parent
          spacing: Style.space(10)

          Text {
            width: parent.width
            text: "Export or restore full plugin state, or copy active environment variables to run in terminal sessions."
            wrapMode: Text.Wrap
            font.pixelSize: Style.font.caption
            color: root.dim
            font.family: root.fontFamily
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(6)

            TextField {
              id: backupPathInput
              Layout.fillWidth: true
              placeholderText: "~/aether-backup.env"
              text: "~/aether-backup.env"
              font.family: root.fontFamily
              font.pixelSize: Style.font.body
              foreground: root.foreground
              accent: root.accent
            }

            Button {
              text: "Export"
              accent: root.accent
              enabled: !aether.actionInProgress && backupPathInput.text.trim() !== ""
              onClicked: aether.exportConfig(backupPathInput.text.trim())
            }

            Button {
              text: "Import"
              enabled: !aether.actionInProgress && backupPathInput.text.trim() !== ""
              onClicked: root.pendingImportPath = backupPathInput.text.trim()
            }
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(6)

            Button {
              Layout.fillWidth: true
              text: "Copy SOCKS / HTTP Env"
              onClicked: aether.copyExportEnv()
            }

            Button {
              Layout.fillWidth: true
              text: "Copy curl Proxy Command"
              onClicked: aether.copyCurlSnippet()
            }
          }
        }
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

      // Zeptun update available banner
      BorderSurface {
        visible: aether.zeptun_available && aether.zeptun_update_available
        width: parent.width
        radius: Style.cornerRadius
        color: Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.12)
        borderSpec: Border.flat(root.accent, 1)
        implicitHeight: updateZeptunCol.implicitHeight + Style.space(20)

        Column {
          id: updateZeptunCol
          width: parent.width - Style.space(24)
          anchors.centerIn: parent
          spacing: Style.space(8)

          Text {
            width: parent.width
            text: "Zeptun Engine Update Available"
            color: root.accent
            font.bold: true
            font.family: root.fontFamily
            font.pixelSize: Style.font.subtitle
          }

          Text {
            width: parent.width
            wrapMode: Text.Wrap
            text: "A newer Zeptun engine is pinned by the plugin (" + (aether.zeptun_version !== "" ? aether.zeptun_version : "installed") + " → " + aether.zeptun_pinned_version + "). Update to keep system routing aligned with the plugin."
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          Button {
            text: aether.actionInProgress ? "Updating Zeptun…" : "Update Zeptun to " + (aether.zeptun_pinned_version !== "" ? aether.zeptun_pinned_version : "Latest")
            accent: root.accent
            bordered: true
            enabled: !aether.actionInProgress
            onClicked: aether.updateZeptun()
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
            visible: aether.zeptun_available
            text: (aether.zeptun_version !== "" ? aether.zeptun_version : "Zeptun") + (aether.zeptun_has_cap_net_admin ? " · CAP_NET_ADMIN" : " · Missing capability")
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            color: aether.zeptun_has_cap_net_admin ? root.accent : root.urgent
          }

          Text {
            width: parent.width
            visible: aether.zeptun_state === "RUNNING"
            text: {
              var line = "tun " + aether.zeptun_tun + " · pid " + aether.zeptun_pid + " · up " + aether.zeptun_uptime_s + "s"
              if (aether.sysroute_egress !== "") {
                line += " · egress " + Model.tunEgressLabel(aether.sysroute_egress_kind, aether.sysroute_egress)
              }
              return line
            }
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

      // Tor / Psiphon routing limitation warning card
      BorderSurface {
        visible: aether.sysroute_egress_kind === "tor" || aether.sysroute_egress_kind === "psiphon" || aether.protocol.indexOf("tor") === 0 || aether.protocol.indexOf("psiphon") === 0 || aether.sysroute_tor_psiphon_warning !== ""
        width: parent.width
        radius: Style.cornerRadius
        color: Qt.rgba(root.urgent.r, root.urgent.g, root.urgent.b, 0.12)
        borderSpec: Border.flat(root.urgent, 1)
        implicitHeight: loopWarningCol.implicitHeight + Style.space(20)

        Column {
          id: loopWarningCol
          width: parent.width - Style.space(24)
          anchors.centerIn: parent
          spacing: Style.space(6)

          RowLayout {
            width: parent.width
            spacing: Style.space(6)
            Text {
              text: "⚠"
              color: root.urgent
              font.bold: true
              font.pixelSize: Style.font.subtitle
            }
            Text {
              Layout.fillWidth: true
              text: "Tor / Psiphon Routing Limitation"
              color: root.urgent
              font.bold: true
              font.family: root.fontFamily
              font.pixelSize: Style.font.subtitle
            }
          }

          Text {
            width: parent.width
            wrapMode: Text.Wrap
            text: "• UDP Limitation: Tor and Psiphon SOCKS5 endpoints do not support UDP ASSOCIATE. Native UDP queries will fail over zeptun0.\n• TUN Loopback: Child egress processes (psiphon-tunnel-core, lyrebird) do not inherit SO_MARK 0xff across exec. Outbound helper sockets loop back into zeptun0 unless excluded.\n• Recommended Fix: Set UDP Mode to 'tcp' and enable 'Fake-IP' resolution, or configure UID exclusions."
            color: root.foreground
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
          }

          RowLayout {
            width: parent.width
            spacing: Style.space(6)

            Button {
              Layout.fillWidth: true
              text: "Enable Fake-IP & TCP UDP"
              accent: root.accent
              onClicked: {
                aether.setConfig("sysroute_fake_ip", "1")
                aether.setConfig("sysroute_udp_mode", "tcp")
              }
            }
          }
        }
      }

      // Engine binary card
      PanelSectionHeader {
        visible: aether.zeptun_available
        text: "ENGINE BINARY"
        foreground: root.foreground
      }

      BorderSurface {
        visible: aether.zeptun_available
        width: parent.width
        radius: Style.cornerRadius
        implicitHeight: Style.space(40)
        color: "transparent"
        borderSpec: Border.controlSpec("normal", root.foreground, root.accent)

        RowLayout {
          anchors.fill: parent
          anchors.leftMargin: Style.space(10)
          anchors.rightMargin: Style.space(10)
          spacing: Style.space(8)

          Text {
            Layout.fillWidth: true
            text: aether.zeptun_binary !== "" ? aether.zeptun_binary : "Zeptun"
            font.family: root.fontFamily
            font.pixelSize: Style.font.caption
            color: root.foreground
            elide: Text.ElideMiddle
          }

          Button {
            text: "Remove"
            enabled: !aether.actionInProgress
            onClicked: root.pendingRemoveZeptunPath = (aether.zeptun_binary !== "" ? aether.zeptun_binary : "zeptun")
          }
        }
      }

      // Presets & MTU
      PanelSectionHeader {
        visible: aether.zeptun_available
        text: "PRESET & MTU"
        foreground: root.foreground
      }

      RowLayout {
        visible: aether.zeptun_available
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          text: "Desktop"
          selected: aether.sysroute_preset === "desktop"
          onClicked: aether.setConfig("sysroute_preset", "desktop")
        }

        Button {
          Layout.fillWidth: true
          text: "Mobile"
          selected: aether.sysroute_preset === "mobile"
          onClicked: aether.setConfig("sysroute_preset", "mobile")
        }

        Button {
          Layout.fillWidth: true
          text: "Server"
          selected: aether.sysroute_preset === "server"
          onClicked: aether.setConfig("sysroute_preset", "server")
        }
      }

      AetherField {
        visible: aether.zeptun_available
        key: "sysroute_mtu"
        labelText: "TUN interface MTU"
        hintText: "Interface MTU. Desktop defaults to 8500 (with offloads); set to 1500, 1420, or 1280 if your link suffers from fragmentation."
      }

      // Traffic & Routing Rules
      PanelSectionHeader {
        visible: aether.zeptun_available
        text: "ROUTING & TRAFFIC SCOPE"
        foreground: root.foreground
      }

      RowLayout {
        visible: aether.zeptun_available
        width: parent.width
        spacing: Style.space(6)

        Button {
          Layout.fillWidth: true
          text: "IPv4 Only"
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

      Toggle {
        visible: aether.zeptun_available
        width: parent.width
        label: "Strict routing (leak protection)"
        description: "Block address families the tunnel does not carry (e.g. block IPv6 in IPv4-only mode) instead of leaking them unproxied."
        checked: aether.sysroute_strict_route
        onClicked: aether.setConfig("sysroute_strict_route", aether.sysroute_strict_route ? "0" : "1")
      }

      Toggle {
        visible: aether.zeptun_available
        width: parent.width
        label: "Auto-redirect TCP (nftables)"
        description: "Redirect TCP traffic into a kernel socket using nftables netlink, bypassing TUN device overhead for maximum throughput."
        checked: aether.sysroute_auto_redirect
        onClicked: aether.setConfig("sysroute_auto_redirect", aether.sysroute_auto_redirect ? "0" : "1")
      }

      AetherField {
        visible: aether.zeptun_available
        key: "sysroute_exclude"
        labelText: "Excluded subnets (CIDRs, comma-separated)"
        hintText: "Kept off the tunnel in addition to LAN, link-local, multicast, and Aether endpoints (e.g. 192.168.1.0/24)."
      }

      AetherField {
        visible: aether.zeptun_available
        key: "sysroute_exclude_uids"
        labelText: "Excluded UIDs (comma-separated)"
        hintText: "Keep specific local users or UID ranges off the tunnel (e.g. 1001, 1005-1010)."
      }

      // DNS Configuration
      PanelSectionHeader {
        visible: aether.zeptun_available
        text: "DNS ENGINE"
        foreground: root.foreground
      }

      AetherDropdown {
        visible: aether.zeptun_available
        key: "sysroute_dns_mode"
        label: "DNS MODE"
        value: aether.sysroute_dns_mode
        options: [
          { value: "systemd_resolved", label: "Hand over to systemd-resolved (~. default route)" },
          { value: "hijack", label: "Capture all DNS into tunnel resolver" },
          { value: "off", label: "Off — DNS follows physical routing" }
        ]
      }

      AetherField {
        visible: aether.zeptun_available
        key: "sysroute_dns_servers"
        labelText: "In-tunnel DNS servers (comma-separated)"
        hintText: "Upstream DNS reached through the tunnel (e.g. 1.1.1.1, 8.8.8.8, 9.9.9.9). Prevents ISP DNS poisoning."
      }

      Toggle {
        visible: aether.zeptun_available
        width: parent.width
        label: "Fake-IP resolution"
        description: "Resolve domain names remotely via SOCKS5 instead of local DNS. Eliminates all ISP DNS poisoning and leaks."
        checked: aether.sysroute_fake_ip
        onClicked: aether.setConfig("sysroute_fake_ip", aether.sysroute_fake_ip ? "0" : "1")
      }

      Toggle {
        visible: aether.zeptun_available
        width: parent.width
        label: "DNS hijack"
        description: "Capture port 53 DNS queries to any destination IP and force them into the in-tunnel resolver."
        checked: aether.sysroute_dns_hijack
        onClicked: aether.setConfig("sysroute_dns_hijack", aether.sysroute_dns_hijack ? "0" : "1")
      }

      // Stack & Transport
      PanelSectionHeader {
        visible: aether.zeptun_available
        text: "STACK & TRANSPORT"
        foreground: root.foreground
      }

      AetherDropdown {
        visible: aether.zeptun_available
        key: "sysroute_stack_mode"
        label: "TCP/IP STACK MODE"
        value: aether.sysroute_stack_mode
        options: [
          { value: "userspace", label: "Userspace — full user-space network stack (default)" },
          { value: "hybrid", label: "Hybrid — userspace / kernel combined" },
          { value: "system", label: "System — kernel NAT stack" }
        ]
      }

      AetherDropdown {
        visible: aether.zeptun_available
        key: "sysroute_congestion"
        label: "TCP CONGESTION CONTROL"
        value: aether.sysroute_congestion
        options: [
          { value: "cubic", label: "Cubic — optimized for high-bandwidth & latency (default)" },
          { value: "newreno", label: "NewReno — classic Reno congestion control" }
        ]
      }

      AetherDropdown {
        visible: aether.zeptun_available
        key: "sysroute_udp_mode"
        label: "UDP CARRIER"
        value: aether.sysroute_udp_mode
        options: [
          { value: "udp", label: "Native UDP (SOCKS5 UDP ASSOCIATE)" },
          { value: "tcp", label: "UDP over TCP (recommended for reliability)" }
        ]
      }

      Toggle {
        visible: aether.zeptun_available
        width: parent.width
        label: "TCP Fast Open (upstream)"
        description: "Enable TCP Fast Open (TFO) on upstream proxy connections to eliminate handshake round-trip latency."
        checked: aether.sysroute_tcp_fastopen
        onClicked: aether.setConfig("sysroute_tcp_fastopen", aether.sysroute_tcp_fastopen ? "0" : "1")
      }

      Toggle {
        visible: aether.zeptun_available
        width: parent.width
        label: "Hardware offloads"
        description: "Enable virtio-net header, TSO, USO, and checksum offload on the TUN interface."
        checked: aether.sysroute_offload
        onClicked: aether.setConfig("sysroute_offload", aether.sysroute_offload ? "0" : "1")
      }

      // Engine I/O & Diagnostics
      PanelSectionHeader {
        visible: aether.zeptun_available
        text: "ENGINE I/O & LOGGING"
        foreground: root.foreground
      }

      AetherDropdown {
        visible: aether.zeptun_available
        key: "sysroute_io_backend"
        label: "I/O BACKEND"
        value: aether.sysroute_io_backend
        options: [
          { value: "auto", label: "Auto — io_uring when available, else epoll" },
          { value: "io_uring", label: "io_uring — modern high-throughput Linux async I/O" },
          { value: "epoll", label: "epoll — classic Linux event polling" }
        ]
      }

      AetherDropdown {
        visible: aether.zeptun_available
        key: "sysroute_log_level"
        label: "ZEPTUN LOG LEVEL"
        value: aether.sysroute_log_level
        options: [
          { value: "warn", label: "Warn — warnings and errors only (default)" },
          { value: "info", label: "Info — connection events and engine state" },
          { value: "debug", label: "Debug — verbose internal state tracing" },
          { value: "err", label: "Error — errors only" }
        ]
      }

      Toggle {
        visible: aether.zeptun_available
        width: parent.width
        label: "Persistent auto-start"
        description: "Bring system routing up automatically whenever Aether is connected (survives reboot and Aether restarts, with bounded retries)."
        checked: aether.sysroute_persistent
        onClicked: aether.setConfig("sysroute_persistent", aether.sysroute_persistent ? "0" : "1")
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
  // TAB 4: LIVE LOGS & DIAGNOSTICS
  // -------------------------------------------------------------
  Component {
    id: tabLogsComp

    Column {
      width: parent.width
      spacing: Style.space(8)

      // Sub-tab Navigation
      RowLayout {
        width: parent.width
        spacing: Style.space(4)

        Button {
          Layout.fillWidth: true
          text: "Core Logs"
          selected: root.logsSubTab === "core"
          onClicked: {
            root.logsSubTab = "core"
            aether.setLogsView("aether")
          }
        }

        Button {
          Layout.fillWidth: true
          text: "Zeptun Logs"
          selected: root.logsSubTab === "zeptun"
          enabled: aether.zeptun_available
          onClicked: {
            root.logsSubTab = "zeptun"
            aether.setLogsView("zeptun")
          }
        }

        Button {
          Layout.fillWidth: true
          text: "Diagnostics"
          selected: root.logsSubTab === "doctor"
          onClicked: {
            root.logsSubTab = "doctor"
            aether.runDoctor()
            aether.fetchCommandPreview()
          }
        }
      }

      // --- Core or Zeptun Live Log Viewer ---
      Column {
        width: parent.width
        spacing: Style.space(8)
        visible: root.logsSubTab !== "doctor"

        RowLayout {
          width: parent.width

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

      // --- Doctor Diagnostics & CLI Command Preview ---
      Column {
        width: parent.width
        spacing: Style.space(8)
        visible: root.logsSubTab === "doctor"

        RowLayout {
          width: parent.width
          spacing: Style.space(6)

          Button {
            text: aether.doctorRunning ? "Checking…" : "Run Doctor"
            accent: root.accent
            enabled: !aether.doctorRunning
            onClicked: {
              aether.runDoctor()
              aether.fetchCommandPreview()
            }
          }

          Button {
            text: "Copy Report"
            onClicked: aether.copyToClipboard("=== AETHER COMMAND ===\n" + aether.commandPreview + "\n\n" + aether.doctorOutput, "Diagnostics report")
          }

          Item { Layout.fillWidth: true }
        }

        PanelSectionHeader {
          text: "ACTIVE CORE COMMAND LINE"
          foreground: root.foreground
        }

        BorderSurface {
          width: parent.width
          radius: Style.cornerRadius
          color: "#0a0a0f"
          borderSpec: Border.flat(root.dim, 1)
          implicitHeight: cmdCol.implicitHeight + Style.space(16)

          Column {
            id: cmdCol
            width: parent.width - Style.space(16)
            anchors.centerIn: parent
            spacing: Style.space(6)

            TextArea {
              width: parent.width
              readOnly: true
              wrapMode: TextEdit.WrapAnywhere
              font.family: "monospace"
              font.pixelSize: Style.font.caption
              color: root.accent
              text: aether.commandPreview !== "" ? aether.commandPreview : "(Generating CLI command preview…)"
            }

            Button {
              text: "Copy Command"
              onClicked: aether.copyToClipboard(aether.commandPreview, "CLI Command")
            }
          }
        }

        PanelSectionHeader {
          text: "SYSTEM HEALTH DIAGNOSTICS"
          foreground: root.foreground
        }

        BorderSurface {
          width: parent.width
          radius: Style.cornerRadius
          implicitHeight: Style.space(260)
          color: "#0a0a0f"
          borderSpec: Border.flat(root.dim, 1)

          ScrollView {
            anchors.fill: parent
            anchors.margins: Style.space(8)
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            TextArea {
              readOnly: true
              wrapMode: TextEdit.WrapAnywhere
              persistentSelection: false
              color: root.foreground
              selectionColor: Style.selectionFillFor(root.foreground, root.accent)
              selectedTextColor: root.foreground
              font.family: "monospace"
              font.pixelSize: Style.font.caption
              text: aether.doctorRunning
                ? "Running system diagnostics…"
                : (aether.doctorOutput !== "" ? aether.doctorOutput : "Click 'Run Doctor' to run health check.")
            }
          }
        }
      }
    }
  }
}
