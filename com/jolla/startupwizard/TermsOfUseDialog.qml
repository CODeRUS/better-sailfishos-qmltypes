import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import com.jolla.settings.accounts 1.0
import com.jolla.settings.system 1.0

Dialog {
    id: root

    // Note: since the previous language picker page may load this page as the acceptDestination
    // and then change the chosen language any number of times, this page and the next must use
    // StartupWizardManager::translatedText() to show any translated text to ensure the new
    // translation texts are loaded.

    property string localeName
    property StartupWizardManager startupWizardManager
    property TermsOfUseManager termsOfUseManager

    property int party: StartupWizardManager.SailfishOS

    property alias dialogHeader: dialogHeader

    property alias headerText: headerLabel.text
    property string summaryText
    property string linkText
    property string rejectLinkText
    property string rejectHeaderText
    property string rejectBodyText

    signal shutdown()

    function loadFullTermsOfUse(localeName) {
        return termsOfUseManager.platformTermsOfUse(localeName)
    }

    Flickable {
        id: flickable

        property int _baseHeight: dialogHeader.height + contentColumn.height + rejectLabel.anchors.topMargin + rejectLabel.height + 2*Theme.paddingLarge
        contentHeight: Math.max(_baseHeight, isPortrait ? Screen.height : Screen.width)
        anchors.fill: parent

        DialogHeader {
            id: dialogHeader
            dialog: root
            cancelText: startupWizardManager.translatedText("startupwizard-he-previous_page", root.localeName)  // translation string defined in WizardDialogHeader
            acceptText: {
                //: Agree to and accept the legal terms of Sailfish OS End User License Agreement. User must agree to this before beginning to use the device.
                //% "Agree"
                qsTrId("startupwizard-he-agree") // trigger Qt Linguist translation
                return startupWizardManager.translatedText("startupwizard-he-agree", root.localeName)
            }
        }

        Column {
            id: contentColumn
            anchors {
                top: dialogHeader.bottom
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            spacing: Theme.paddingLarge

            Label {
                id: headerLabel

                width: parent.width
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraLarge
                color: startupWizardManager.defaultHighlightColor()
            }

            Label {
                id: summaryLabel
                width: parent.width
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: startupWizardManager.defaultHighlightColor()
                text: root.summaryText.arg(dialogHeader.acceptText)
            }

            WizardClickableLabel {
                id: linkLabel
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: startupWizardManager.defaultHighlightColor()
                text: root.linkText
                            .arg("<u><font color=\"" + (pressed ? startupWizardManager.defaultHighlightColor() : startupWizardManager.defaultPrimaryColor()) + "\">")
                            .arg("</font></u>")

                onClicked: {
                    var translatedText = root.loadFullTermsOfUse(root.localeName)
                    if (translatedText.length === 2) {
                        var props = {
                            "headingText": translatedText[0],
                            "bodyText": translatedText[1]
                        }
                        pageStack.animatorPush(fullTermsComponent, props)
                    }
                }
            }
        }

        Item {
            id: spacer
            anchors.top: contentColumn.bottom
            width: 1
            height: flickable.contentHeight - flickable._baseHeight
        }

        WizardClickableLabel {
            id: rejectLabel
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                top: spacer.bottom
                topMargin: Theme.itemSizeSmall
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            font.pixelSize: Theme.fontSizeExtraSmall
            color: startupWizardManager.defaultHighlightColor()
            text: root.rejectLinkText
                    .arg("<u><font color=\"" + (pressed ? startupWizardManager.defaultHighlightColor() : startupWizardManager.defaultPrimaryColor()) + "\">")
                    .arg("</font></u>")

            onClicked: {
                pageStack.animatorPush(rejectDialogComponent)
            }
        }
    }

    Component {
        id: fullTermsComponent

        FullTermsDialog {
            bodyTextColor: startupWizardManager.defaultHighlightColor()
        }
    }


    Component {
        id: rejectDialogComponent

        Dialog {
            id: rejectDialog

            property bool _shutdownTriggered

            forwardNavigation: false

            SilicaFlickable {
                id: rejectDialogFlickable

                anchors.fill: parent
                contentHeight: header.height + contentColumn.height + Theme.paddingLarge

                Behavior on opacity { NumberAnimation { duration: 1000 } }

                DialogHeader {
                    id: header

                    cancelText: {
                        //: Return to the previous page
                        //% "Go back"
                        qsTrId("startupwizard-he-go_back") // trigger Qt Linguist translation
                        return startupWizardManager.translatedText("startupwizard-he-go_back", root.localeName)
                    }
                    acceptText: ""
                    title: root.rejectHeaderText
                }

                Column {
                    id: contentColumn
                    anchors.top: header.bottom
                    width: parent.width
                    spacing: Theme.itemSizeLarge    // extra spacing after button

                    Label {
                        x: Theme.horizontalPageMargin
                        width: parent.width - x*2
                        wrapMode: Text.Wrap
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.highlightColor
                        text: root.rejectBodyText
                    }

                    Button {
                        anchors.horizontalCenter: parent.horizontalCenter
                        preferredWidth: Theme.buttonWidthLarge
                        text: {
                            //: User chooses to reject the Sailfish OS End User License Agreement and turn off the device.
                            //% "Reject and turn off"
                            qsTrId("startupwizard-bt-reject_button") // trigger Qt Linguist translation
                            return startupWizardManager.translatedText("startupwizard-bt-reject_button", root.localeName)
                        }

                        onClicked: {
                            if (!rejectDialog._shutdownTriggered) {
                                rejectDialog._shutdownTriggered = true
                                rejectDialogFlickable.opacity = 0
                                root.shutdown()
                            }
                        }
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }
}
