import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    property alias startText: startLabel.text
    property alias endText: endLabel.text
    property alias icon: icon.source
    property bool error

    signal startClicked()
    signal endClicked()

    width: row.width
    height: row.height

    BackgroundItem {
        id: startMouseArea
        x: -Theme.paddingSmall
        width: icon.x + Theme.paddingSmall
        height: row.height
        onClicked: parent.startClicked()
    }

    BackgroundItem {
        id: endMouseArea
        x: icon.x + icon.width
        width: row.width - x + Theme.paddingSmall
        height: parent.height
        onClicked: parent.endClicked()
    }

    Row {
        id: row
        width: childrenRect.width
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingSmall

        Label {
            id: startLabel
            color: startMouseArea.pressed ? Theme.highlightColor
                                          : (error ? Theme.errorColor : Theme.primaryColor)
            font.pixelSize: Theme.fontSizeMedium

            Text {
                //% "Starts"
                text: qsTrId("sailfish_calendar-la-datewidget_starts")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors.horizontalCenter: startLabel.horizontalCenter
                anchors.bottom: parent.top
            }
        }

        Image {
            id: icon
            anchors.verticalCenter: startLabel.verticalCenter
        }

        Label {
            id: endLabel
            color: endMouseArea.pressed ? Theme.highlightColor
                                        : (error ? Theme.errorColor : Theme.primaryColor)
            font.pixelSize: Theme.fontSizeMedium

            Text {
                //% "Ends"
                text: qsTrId("sailfish_calendar-la-datewidget_ends")
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                anchors.horizontalCenter: endLabel.horizontalCenter
                anchors.bottom: parent.top
            }
        }
    }
}
