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
        id: icon
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        source: (root.highlighted && root.iconSource != "" && root.useHighlightColor)
                ? root.iconSource + "?" + Theme.highlightColor
                : root.iconSource
    }
    Label {
        id: label
        truncationMode: TruncationMode.Fade
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor
        anchors {
            left: icon.right
            leftMargin: icon.width > 0 ? Theme.paddingMedium : 0
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
    }
}
