import QtQuick 2.0
import Sailfish.Silica 1.0

SettingItem {
    id: root

    property alias name: label.text
    property url iconSource
    property url pageSource
    property bool useHighlightColor: true

    implicitHeight: Theme.itemSizeSmall

    onClicked: pageStack.push(pageSource.toString(), {})

    Image {
        anchors.centerIn: parent
        source: (root.highlighted && root.iconSource != "" && root.useHighlightColor)
                ? root.iconSource + "?" + Theme.highlightColor
                : root.iconSource
        // assuming no items larger than ones in launcher
        height: Math.min(Theme.iconSizeLauncher, implicitHeight)
        width: Math.min(Theme.iconSizeLauncher, implicitWidth)
    }

    Label {
        id: label
        anchors.centerIn: parent.center
        visible: root.iconSource == ""
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
    }
}
