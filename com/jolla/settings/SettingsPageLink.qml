import QtQuick 2.0
import Sailfish.Silica 1.0

SettingItem {
    id: root

    property alias name: label.text
    property url iconSource
    property url pageSource
    property bool useHighlightColor: true
    property int leftMargin: Theme.horizontalPageMargin
    property int rightMargin: Theme.horizontalPageMargin

    onClicked: pageStack.animatorPush(pageSource.toString())

    implicitHeight: Math.max(Theme.itemSizeSmall, label.height + 2 * Theme.paddingMedium)

    Image {
        id: icon
        x: root.leftMargin
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
            rightMargin: root.rightMargin
        }
    }
}
