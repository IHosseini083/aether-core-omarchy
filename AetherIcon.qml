import QtQuick
import QtQuick.Shapes
import qs.Commons
import qs.Ui

Item {
  id: root

  property real iconSize: Style.font.icon
  property color color: Color.foreground
  property color accentColor: Color.accent
  property color badgeColor: Color.urgent
  property bool active: false
  property bool connecting: false
  property bool crossed: false
  property bool warning: false

  width: iconSize
  height: iconSize
  implicitWidth: iconSize
  implicitHeight: iconSize

  readonly property real cx: width / 2
  readonly property real cy: height / 2

  Shape {
    id: glyph
    anchors.fill: parent
    layer.enabled: true
    layer.samples: 4

    // Outer geometric shield / diamond
    ShapePath {
      strokeColor: root.active ? root.accentColor : root.color
      strokeWidth: Math.max(1.5, root.iconSize * 0.1)
      fillColor: "transparent"
      capStyle: ShapePath.RoundCap
      joinStyle: ShapePath.RoundJoin

      startX: root.cx
      startY: root.iconSize * 0.12

      PathLine { x: root.iconSize * 0.88; y: root.iconSize * 0.44 }
      PathLine { x: root.cx; y: root.iconSize * 0.88 }
      PathLine { x: root.iconSize * 0.12; y: root.iconSize * 0.44 }
      PathLine { x: root.cx; y: root.iconSize * 0.12 }
    }

    // Inner core node / tunnel vertex
    ShapePath {
      strokeColor: "transparent"
      fillColor: root.active ? root.accentColor : root.color

      startX: root.cx
      startY: root.cy - root.iconSize * 0.14

      PathLine { x: root.cx + root.iconSize * 0.14; y: root.cy }
      PathLine { x: root.cx; y: root.cy + root.iconSize * 0.14 }
      PathLine { x: root.cx - root.iconSize * 0.14; y: root.cy }
      PathLine { x: root.cx; y: root.cy - root.iconSize * 0.14 }
    }
  }

  // Connecting pulse animation
  SequentialAnimation on opacity {
    running: root.connecting
    loops: Animation.Infinite
    NumberAnimation { to: 0.3; duration: 600; easing.type: Easing.InOutQuad }
    NumberAnimation { to: 1.0; duration: 600; easing.type: Easing.InOutQuad }
  }

  // Disconnected slash line
  Rectangle {
    visible: root.crossed && !root.active && !root.connecting
    anchors.centerIn: parent
    width: parent.width * 1.25
    height: Math.max(2, parent.height * 0.12)
    radius: height / 2
    color: root.color
    opacity: 0.8
    rotation: -45
  }

  // Error / warning badge
  BorderSurface {
    visible: root.warning
    width: Math.max(8, parent.width * 0.44)
    height: width
    radius: width / 2
    color: root.badgeColor
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    borderSpec: Border.flat(Color.popups.background, 1)

    Text {
      anchors.centerIn: parent
      text: "!"
      color: Color.background
      font.family: Style.font.family
      font.pixelSize: Math.max(7, parent.height * 0.75)
      font.bold: true
    }
  }
}
