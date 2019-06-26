import QtQuick 2.1
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property alias text: label.text
    property alias iconSource: icon.source
    property bool contentHighlighted
    property real topPadding: Theme.paddingLarge
    property real bottomPadding: 2*Theme.paddingLarge
    property alias font: label.font

    implicitHeight: content.height + topPadding + bottomPadding
    width: label.implicitWidth + 2*Theme.paddingMedium

    opacity: enabled ? 1.0 : 0.6

    Column {
        id: content

        y: topPadding
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: Theme.paddingSmall

        HighlightImage {
            id: icon
            anchors.horizontalCenter: parent.horizontalCenter
            highlighted: root.down || root.contentHighlighted
        }

        Label {
            id: label

            width: parent.width - 2*Theme.paddingMedium
            horizontalAlignment: Text.AlignHCenter
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.down || root.contentHighlighted ? Theme.highlightColor : Theme.primaryColor
            font.pixelSize: Theme.fontSizeSmall
            wrapMode: Text.Wrap
            textFormat: Text.AutoText
        }
    }
}
