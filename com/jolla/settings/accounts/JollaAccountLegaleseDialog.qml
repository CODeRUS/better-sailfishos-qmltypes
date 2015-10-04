import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: root

    property alias termsOfServiceHeading: tosHeading.text
    property alias termsOfServiceText: tosText.text

    property alias privacyPolicyHeading: privacyHeading.text
    property alias privacyPolicyText: privacyText.text

    forwardNavigation: false

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + legaleseColumn.height

        DialogHeader {
            id: header
            acceptText: ""

            //: Return to previous page
            //% "Go back"
            cancelText: qsTrId("components_accounts-he-go_back")
        }

        Column {
            id: legaleseColumn
            anchors.top: header.bottom
            x: Theme.horizontalPageMargin
            width: parent.width - x*2

            Label {
                id: tosHeading
                width: parent.width
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            Label {
                id: tosText
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            Label {
                id: privacyHeading
                width: parent.width
                font.pixelSize: Theme.fontSizeLarge
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }

            Label {
                id: privacyText
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
                wrapMode: Text.Wrap
            }
        }

        VerticalScrollDecorator {}
    }
}
