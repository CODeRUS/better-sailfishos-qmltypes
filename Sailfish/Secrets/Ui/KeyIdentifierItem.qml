import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    id: root

    property bool displayCollection
    property alias text: keyLabel.text
    signal remove

    contentHeight: Theme.itemSizeSmall

    function _remove() {
        remorseDelete(function() {
            root.remove()
        })
    }

    menu: Component {
        ContextMenu {
            MenuItem {
                //% "Delete"
                text: qsTrId("secrets_ui-me-delete")
                onClicked: _remove()
            }
        }
    }

    Column {
        id: column
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - 2 * x

        Label {
            id: keyLabel
            text: model.name
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
            width: parent.width
        }

        Label {
            id: collectionLabel

            visible: displayCollection
            text: displayCollection ? model.collection : ""
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            height: text.length > 0 ? implicitHeight : 0
            truncationMode: TruncationMode.Fade
            width: parent.width
        }
    }
}
