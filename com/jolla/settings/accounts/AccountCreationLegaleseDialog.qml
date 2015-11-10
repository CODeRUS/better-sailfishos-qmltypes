import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.accounts 1.0

Dialog {
    id: root

    property string legaleseText
    property string externalUrlText
    property string externalUrlLink
    property alias userAgent: termsView.userAgent

    DialogHeader {
        id: header
        //: The "accept terms / data usage" dialog header
        //% "Consent"
        acceptText: qsTrId("jolla_settings_accounts_extensions-he-consent")
    }

    SilicaFlickable {
        id: flick
        anchors {
            top: header.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        clip: true
        contentHeight: consentLabel.height + termsButton.anchors.topMargin + termsButton.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        Label {
            id: consentLabel
            width: parent.width - x*2
            x: Theme.horizontalPageMargin
            color: Theme.highlightColor
            text: root.legaleseText
            wrapMode: Text.Wrap
            textFormat: Text.AutoText
            font.pixelSize: Theme.fontSizeSmall
        }

        Button {
            id: termsButton
            anchors {
                top: consentLabel.bottom
                topMargin: Theme.paddingLarge*2
                horizontalCenter: consentLabel.horizontalCenter
            }
            text: root.externalUrlText
            preferredWidth: Theme.buttonWidthLarge

            onClicked: {
                flick.visible = false
                consentLabel.visible = false
                termsButton.visible = false
                termsView.visible = true
            }
        }
    }

    SilicaWebView {
        id: termsView
        visible: false
        overridePageStackNavigation: true
        property string userAgent: "Mozilla/5.0 (Linux; U; Jolla; Sailfish; Mobile; rv:20.0) Gecko/20.0 Firefox/20.0 Sailfish Browser/1.0 like Safari/535.19"
        property bool _isScrolledToEnd: (termsView.contentY + termsView.height + 2) >= termsView.contentHeight
        property bool _isScrolledToBeginning: termsView.contentY <= 2
        property bool _isFinishedPanning: termsView.atXBeginning && termsView.atXEnd && !termsView.moving
        experimental.temporaryCookies: true
        experimental.deviceWidth: termsView.width
        experimental.deviceHeight: termsView.height
        experimental.userAgent: userAgent
        url: root.externalUrlLink
        anchors {
            top: header.bottom
            bottom: root.bottom
            left: root.left
            right: root.right
        }
    }
}
