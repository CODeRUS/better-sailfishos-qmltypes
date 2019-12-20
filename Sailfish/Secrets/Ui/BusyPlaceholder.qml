import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    property alias active: busyIndicator.running
    property alias text: label.text
    property alias indicatorSize: busyIndicator.size

    width: parent.width
    spacing: Theme.paddingSmall

    opacity: active ? 1.0 : 0.0
    Behavior on opacity { FadeAnimation {}}

    BusyIndicator {
        id: busyIndicator
        running: false
        height: active ? implicitHeight : 0
        size: BusyIndicatorSize.Medium
        anchors.horizontalCenter: parent.horizontalCenter
    }

    InfoLabel {
        id: label
        font.pixelSize: Theme.fontSizeLarge
        height: text ? implicitHeight : 0
    }
}
