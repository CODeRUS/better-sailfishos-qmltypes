import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Messages 1.0

Column {
    property bool centerAlign
    property alias font: label.font
    property alias color: label.color

    anchors {
        left: parent.left
        right: parent.right
        margins: Theme.horizontalPageMargin
        verticalCenter: parent.verticalCenter
    }

    Label {
        id: label

        text: model.display
        width: Math.min(implicitWidth, parent.width)
        truncationMode: TruncationMode.Fade
        anchors.horizontalCenter: centerAlign ? parent.horizontalCenter : undefined
        ContactPresenceIndicator {
            anchors {
                verticalCenter: parent.verticalCenter
                left: parent.right
                leftMargin: Theme.paddingMedium
            }
            visible: !MessageUtils.isSMS(model.localUid) && menu.people.length === 1
            presenceState: MessageUtils.presenceForPersonAccount(menu.people[0], localUid, remoteUid)
        }
    }

    Label {
        font.pixelSize: Theme.fontSizeExtraSmall
        width: Math.min(implicitWidth, parent.width)
        truncationMode: TruncationMode.Fade
        anchors.horizontalCenter: centerAlign ? parent.horizontalCenter : undefined
        color: label.color
        opacity: Theme.opacityHigh

        text: model.phoneNumberText
        visible: text !== ""
    }
}
