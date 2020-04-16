import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: providerDelegate

    contentHeight: visible ? Theme.itemSizeSmall : 0

    AccountIcon {
        id: icon
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        source: model.providerIcon
    }
    Label {
        anchors {
            left: icon.right
            right: parent.right
            leftMargin: Theme.paddingLarge
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        truncationMode: TruncationMode.Fade
        text: model.providerDisplayName
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }
}
