import QtQuick 2.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property string text
    property color primaryColor: Theme.primaryColor
    property bool emergency
    property bool showWhiteBackgroundByDefault

    visible: text !== ""
    contentItem.radius: 4
    highlighted: showWhiteBackgroundByDefault || down

    highlightedColor: {
        if (emergency) {
            return "white"
        }
        return Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    }

    Rectangle {
        anchors.fill: parent
        anchors.margins: 2
        color: "#4c0000"
        radius: 4
        visible: root.showWhiteBackgroundByDefault && root.down
    }

    Label {
        x: Math.round((root.width - width) / 2)
        y: root.height - baselineOffset - Theme.paddingLarge
        width: Math.min(implicitWidth, parent.width - 2*Theme.paddingSmall)
        text: root.text
        font.pixelSize: Theme.fontSizeMedium
        font.bold: root.emergency
        fontSizeMode: Text.HorizontalFit

        color: {
            if (root.emergency) {
                if (showWhiteBackgroundByDefault) {
                    return root.down ? "white" : "black"
                }
                return root.highlighted ? "black" : "white"
            }
            return root.highlighted ? Theme.highlightColor : root.primaryColor
        }
    }
}
