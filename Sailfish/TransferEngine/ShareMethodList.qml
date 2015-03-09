import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

SilicaListView {
    id: rootList

    property url source
    property variant content: ({})

    property string listHeader // deprecated
    property alias filter: transferMethodsModel.filter

    model: SailfishTransferMethodsModel { id: transferMethodsModel }

    width: parent.width
    height: Theme.itemSizeSmall * transferMethodsModel.count

    onListHeaderChanged: console.log("ShareMethodList.listHeader deprecated")
    delegate: BackgroundItem {
        id: backgroundItem

        width: rootList.width

        Label {
            id: displayNameLabel
            // Plugins may provide translation id and the translation for the display name
            // This module already loads plugin translations so let's make sure that also
            // display name is translated if it contains the id..
            text: qsTrId(displayName)
            color: backgroundItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
            x: Theme.paddingLarge
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, parent.width - 2*Theme.paddingLarge)
        }
        SecondaryLabel {
            text: userName
            color: backgroundItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            truncationMode: TruncationMode.Fade
            anchors {
                left: displayNameLabel.right
                leftMargin: Theme.paddingSmall
                right: parent.right
                rightMargin: Theme.paddingLarge
                verticalCenter: parent.verticalCenter
            }
            visible: text.length > 0
        }

        onClicked: {
            pageStack.push(shareUIPath, {
                               source: rootList.source,
                               content: rootList.content,
                               methodId: methodId,
                               displayName: displayName,
                               accountId: accountId,
                               accountName: userName
                           })
        }
    }
}
