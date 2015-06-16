import QtQuick 2.0
import Sailfish.Silica 1.0

SettingItem {
    id: root

    property alias name: label.text
    property url iconSource
    property int depth

    height: row.height

    onClicked: {
        pageStack.push("SettingsPage.qml", {
                           "name": root.name,
                           "entryPath": root.entryPath,
                           "depth": root.depth
                       })
    }

    Row {
        id: row
        height: Theme.itemSizeSmall
        x: Theme.horizontalPageMargin

        Image {
            id: icon
            source: (root.down && root.iconSource != "") ? root.iconSource + "?" + Theme.highlightColor : root.iconSource
            anchors.verticalCenter: parent.verticalCenter
        }
        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            color: root.down ? Theme.highlightColor : Theme.primaryColor
        }
    }
}
