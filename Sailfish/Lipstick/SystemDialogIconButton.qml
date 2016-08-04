import QtQuick 2.1
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    property alias text: label.text
    property string iconSource
    property bool contentHighlighted
    property real topPadding: Theme.paddingLarge
    property real bottomPadding: 2*Theme.paddingLarge
    property alias font: label.font

    implicitHeight: content.height + topPadding + bottomPadding
    width: label.implicitWidth + 2*Theme.paddingMedium

    Column {
        id: content

        y: topPadding
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: Theme.paddingSmall

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            source: root.iconSource + "?" + (root.down || root.contentHighlighted ? Theme.highlightColor
                                                                                  : Theme.primaryColor)
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
