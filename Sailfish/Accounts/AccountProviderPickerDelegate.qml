import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    contentHeight: visible ? Theme.itemSizeSmall : 0

    onClicked: {
        root.providerSelected(model.index, model.providerName)
    }

    AccountIcon {
        id: icon
        x: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        source: model.providerIcon
    }
    Label {
        anchors {
            left: icon.right
            right: parent.right
            leftMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }
        truncationMode: TruncationMode.Fade
        text: model.providerDisplayName
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
    }
}
