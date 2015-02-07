import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: sideArea

    anchors.fill: parent

    property real offset: Math.max(rightPeek.offset, leftPeek.offset)
    property bool pressed: rightPeek.pressed || leftPeek.pressed
    property bool peekEnabled

    signal released()

    MouseArea {
        id: rightPeek

        property real offset: pressed
                              ? Math.min(1.0, Math.max(0.0, (width - mouseX) / (parent.width / 4)))
                              : 0.0

        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: 24 * xScale
        enabled: peekEnabled

        onReleased: {
            sideArea.released()
        }
    }

    MouseArea {
        id: leftPeek

        property real offset: pressed
                              ? Math.min(1.0, Math.max(0.0, mouseX / (parent.width / 4)))
                              : 0.0

        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
        }
        width: 24 * xScale
        enabled: peekEnabled

        onReleased: {
            sideArea.released()
        }
    }
}
