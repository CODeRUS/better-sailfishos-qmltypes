import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import com.jolla.startupwizard 1.0
import com.jolla.settings.accounts 1.0

Dialog {
    id: root

    // Note: since the previous language picker page may load this page as the acceptDestination
    // and then change the chosen language any number of times, this page and the next must use
    // StartupWizardManager::translatedText() to show any translated text to ensure the new
    // translation texts are loaded.

    property string localeName
    property StartupWizardManager startupWizardManager

    Flickable {
        id: flickable

        property int _baseHeight: dialogHeader.height + contentColumn.height + bottomLabel.anchors.topMargin + bottomLabel.height + 2*Theme.paddingLarge
        contentHeight: Math.max(_baseHeight, isPortrait ? Screen.height : Screen.width)
        anchors.fill: parent

        DialogHeader {
            id: dialogHeader
            dialog: root
            cancelText: startupWizardManager.translatedText("startupwizard-he-previous_page", root.localeName)  // translation string defined in WizardDialogHeader
            acceptText: {
                //: Agree to and accept the legal terms of Sailfish OS End User License Agreement. User must agree to this before beginning to use the Jolla device.
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

            Image {
                source: "image://theme/icon-os-state-update?" + startupWizardManager.defaultHighlightColor()
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraLarge
                color: startupWizardManager.defaultHighlightColor()
                text: {
                    //% "End User License Agreement"
                    qsTrId("startupwizard-he-eula") // trigger Qt Linguist translation
                    return startupWizardManager.translatedText("startupwizard-he-eula", root.localeName)
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: startupWizardManager.defaultHighlightColor()
                text: {
                    //: %1 = a copy of the translated text of startupwizard-he-agree
                    //% "Jolla runs Sailfish OS. By selecting '%1' and starting to use Sailfish OS you agree to the Sailfish OS End User License Agreement."
                    qsTrId("startupwizard-la-sailfish_eula_intro") // trigger Qt Linguist translation
                    return startupWizardManager.translatedText("startupwizard-la-sailfish_eula_intro", root.localeName)
                            .arg(dialogHeader.acceptText)
                }
            }

            WizardClickableLabel {
                width: parent.width
                font.pixelSize: Theme.fontSizeExtraSmall
                color: startupWizardManager.defaultHighlightColor()
                text: {
                    //: Text surrounded by %1 and %2 is underlined and colored differently
                    //% "Please read the %1Sailfish OS End User License Agreement%2 carefully before accepting."
                    qsTrId("startupwizard-la-sailfish_eula_read_carefully") // trigger Qt Linguist translation
                    return startupWizardManager.translatedText("startupwizard-la-sailfish_eula_read_carefully", root.localeName)
                            .arg("<u><font color=\"" + (pressed ? startupWizardManager.defaultHighlightColor() : startupWizardManager.defaultPrimaryColor()) + "\">")
                            .arg("</font></u>")
                }

                onClicked: {
                    var translatedText = startupWizardManager.termsOfUse(root.localeName)
                    if (translatedText.length === 2) {
                        var props = {
                            "headingText": translatedText[0],
                            "bodyText": translatedText[1]
                        }
                        pageStack.push(fullTermsComponent, props)
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
            id: bottomLabel
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
            text: {
                //: Text surrounded by %1 and %2 is underlined and colored differently
                //% "%1Reject the Sailfish OS End User License Agreement%2 and turn the device off"
                qsTrId("startupwizard-la-reject_sailfish_eula_and_turn_off") // trigger Qt Linguist translation
                return startupWizardManager.translatedText("startupwizard-la-reject_sailfish_eula_and_turn_off", root.localeName)
                        .arg("<u><font color=\"" + (pressed ? startupWizardManager.defaultHighlightColor() : startupWizardManager.defaultPrimaryColor()) + "\">")
                        .arg("</font></u>")
            }

            onClicked: {
                pageStack.push(rejectDialogComponent)
            }
        }
    }

    Component {
        id: fullTermsComponent

        Dialog {
            id: fullTermsDialog

            property string headingText
            property string bodyText

            forwardNavigation: false

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: header.height + termsTextColumn.height + Theme.paddingLarge*2

                WizardDialogHeader {
                    id: header
                    acceptText: ""
                    title: fullTermsDialog.headingText
                }

                Column {
                    id: termsTextColumn
                    anchors {
                        top: header.bottom
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }
                    spacing: Theme.paddingLarge

                    Label {
                        width: parent.width
                        height: implicitHeight + Theme.paddingLarge
                        wrapMode: Text.Wrap
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: startupWizardManager.defaultHighlightColor()
                        text: fullTermsDialog.bodyText
                    }
                }

                VerticalScrollDecorator {}
            }
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
                    title: {
                        //% "Are you sure you want to reject the Sailfish OS End User License Agreement?"
                        qsTrId("startupwizard-he-reject_eula_heading_text") // trigger Qt Linguist translation
                        return startupWizardManager.translatedText("startupwizard-he-reject_eula_heading_text", root.localeName)
                    }
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
                        text: {
                            //% "If you cannot accept the terms of this Agreement after having purchased a product incorporating Software, please return the product containing the Software to the seller within the return period provided for in the seller's return policy for a full refund. If you purchased the product directly from us, the applicable return period is stated in our Jolla Return Policy, available at http://www.jolla.com/care."
                            qsTrId("startupwizard-la-reject_eula_body_text") // trigger Qt Linguist translation
                            return startupWizardManager.translatedText("startupwizard-la-reject_eula_body_text", root.localeName)
                        }
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
                                rejectDialog.enabled = false
                                rejectDialog.backNavigation = false
                                rejectDialogFlickable.opacity = 0
                                shutdownScreen.opacity = 1
                            }
                        }
                    }
                }

                VerticalScrollDecorator {}
            }

            ShutDownItem {
                id: shutdownScreen
                opacity: 0
                message: {
                    //: Shut down message
                    //% "Goodbye!"
                    qsTrId("startupwizard-la-goodbye") // trigger Qt Linguist translation
                    return startupWizardManager.translatedText("startupwizard-la-goodbye", root.localeName)
                }

                onOpacityAnimationFinished: if (opacity == 1) startupWizardManager.triggerShutdown()
            }
        }
    }
}
