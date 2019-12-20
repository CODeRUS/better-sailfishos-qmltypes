import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    property alias title: titleLabel.text
    property alias description: descriptionLabel.text
    property real topPadding: 2*Theme.paddingLarge
    property real bottomPadding: Theme.paddingLarge

    property alias titleFont: titleLabel.font
    property alias titleColor: titleLabel.color
    property alias descriptionColor: descriptionLabel.color

    property alias titleTextFormat: titleLabel.textFormat

    height: content.height + topPadding + bottomPadding
    width: (Screen.sizeCategory >= Screen.Large) ? Screen.height / 2 : parent.width
    anchors.horizontalCenter: parent.horizontalCenter

    Column {
        id: content

        width: parent.width - 2*x
        x: (Screen.sizeCategory < Screen.Large) ? Theme.horizontalPageMargin : 0
        y: topPadding
        spacing: Theme.paddingLarge

        Label {
            id: titleLabel

            visible: text !== ""
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }

        Label {
            id: descriptionLabel

            visible: text !== ""
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeMedium
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
