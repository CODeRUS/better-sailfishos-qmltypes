import QtQuick 2.1
import Sailfish.Silica 1.0

Column {
    id: root

    property int horizontalAlignment: Text.AlignLeft
    property bool highlighted
    property alias description: simDescription.text
    property alias operator: operator.text
    property bool selected
    property bool valid
    property int innerMargin: Theme.paddingLarge * 2

    readonly property bool leftAligned: horizontalAlignment === Text.AlignLeft

    spacing: Theme.paddingSmall

    anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        topMargin: Theme.paddingMedium
        leftMargin: leftAligned ? innerMargin : Theme.paddingLarge
        rightMargin: !leftAligned ? innerMargin : Theme.paddingLarge
    }

    Row {
        id: simText

        spacing: Theme.paddingSmall
        x: leftAligned ? 0 : root.width - width

        Image {
            id: simImage
            source: "image://theme/graphic-simcard" + (root.highlighted ? "?" + Theme.highlightColor : "")
            anchors.bottom: simDescription.baseline
        }

        Label {
            id: simDescription
            anchors.bottom: parent.bottom
            color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
            width: Math.min(implicitWidth, root.width - simImage.width - simText.spacing)
            fontSizeMode: Text.HorizontalFit
        }
    }

    Rectangle {
        anchors.left: simText.left
        anchors.right: simText.right

        // Same rounding as with presence indicator.
        height: Theme.paddingSmall
        radius: Math.round(height / 3)

        color: root.selected ? Theme.presenceColor(Theme.PresenceAvailable) : "transparent"
        Behavior on color { ColorAnimation { duration: 200 } }

        border {
            color: root.highlighted && !root.selected ? Theme.rgba(Theme.highlightColor, 0.8) : Theme.rgba(Theme.primaryColor, 0.4)
            width: root.selected ? 0 : Math.round(Theme.paddingSmall / 4)
        }
    }

    Label  {
        id: operator
        width: parent.width
        font.pixelSize: Theme.fontSizeExtraSmall
        horizontalAlignment: contentWidth > Math.ceil(width) ? Text.AlignLeft : root.horizontalAlignment
        truncationMode: valid ? TruncationMode.Fade : TruncationMode.None
        wrapMode: valid ? Text.NoWrap : Text.WordWrap
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
    }
}
