import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: root

    property alias statusText: statusLabel.text
    property alias busyIndicatorRunning: busyIndicator.running
    property alias headingText : headingLabel.text
    property alias informationLabel: informationLabel.text

    acceptDestinationAction: PageStackAction.Replace
    canAccept: false

    DialogHeader {
        id: header
        opacity: root.canAccept ? 1 : 0
    }

    Column {
        anchors.centerIn: parent
        spacing: Theme.paddingLarge
        visible: busyIndicatorRunning

        Label {
            id: statusLabel
            width: root.width - Theme.horizontalPageMargin*2
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            color: Theme.rgba(Theme.highlightColor, 0.6)
        }

        BusyIndicator {
            id: busyIndicator
            anchors.horizontalCenter: parent.horizontalCenter
            size: BusyIndicatorSize.Large
            running: true
        }
    }

    Column {
        id: infoColumn
        visible: !busyIndicatorRunning
        anchors.top: header.bottom
        x: Theme.horizontalPageMargin
        width: parent.width - x*2
        spacing: Theme.paddingLarge

        Label {
            id: headingLabel
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraLarge
            color: Theme.highlightColor
        }

        Label {
            id: informationLabel
            width: parent.width
            wrapMode: Text.Wrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.rgba(Theme.highlightColor, 0.9)
        }
    }
}
