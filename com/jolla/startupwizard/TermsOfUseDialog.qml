import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.startupwizard 1.0
import com.jolla.settings.accounts 1.0

Dialog {
    id: root

    function _termsLinkText(pressed) {
        //: Text surrounded by %1 and %2 is underlined and colored differently
        //% "Please read the %1Sailfish OS Terms of Use%2 carefully before accepting."
        return qsTrId("startupwizard-la-sailfish_terms_read_carefully")
                        .arg("<u><font color=\"" + (pressed ? wizardManager.defaultHighlightColor() : wizardManager.defaultPrimaryColor()) + "\">")
                        .arg("</font></u>")
    }

    // this dialog is displayed before the ambience dialog, so make sure background is not visible
    Rectangle {
        anchors.fill: parent
        color: "black"
    }

    StartupWizardManager {
        id: wizardManager
    }

    DialogHeader {
        id: dialogHeader
        dialog: root
        _backgroundVisible: false
    }

    Column {
        anchors {
            top: dialogHeader.bottom
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
        spacing: Theme.paddingLarge

        TermsOfUseHeading {
            width: parent.width
            color: wizardManager.defaultHighlightColor()
        }

        Label {
            width: parent.width
            wrapMode: Text.WordWrap
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.rgba(wizardManager.defaultHighlightColor(), 0.9)

            //% "Jolla runs Sailfish OS. By selecting Accept and starting to use Sailfish OS you agree to the Sailfish OS Terms of Use."
            text: qsTrId("startupwizard-la-sailfish_terms_description")
        }

        WizardClickableLabel {
            width: parent.width
            font.pixelSize: Theme.fontSizeExtraSmall
            color: Theme.rgba(wizardManager.defaultHighlightColor(), 0.9)
            text: root._termsLinkText(pressed)

            onClicked: {
                var translatedText = wizardManager.termsOfUse()
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

    TermsOfUseOptions {
        anchors {
            bottom: parent.bottom
            bottomMargin: Theme.paddingLarge * 2
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }

        onAcceptClicked: root.accept()
        onRejectClicked: wizardManager.triggerShutdown()
    }

    Component {
        id: fullTermsComponent

        Dialog {
            id: fullTermsDialog

            property string headingText
            property string bodyText

            acceptDestination: root.acceptDestination
            acceptDestinationAction: PageStackAction.Replace

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: header.height + termsTextColumn.height + Theme.paddingLarge*2

                DialogHeader {
                    id: header
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

                    TermsOfUseHeading {
                        width: parent.width
                        color: wizardManager.defaultHighlightColor()
                        text: fullTermsDialog.headingText
                    }

                    Label {
                        width: parent.width
                        height: implicitHeight + Theme.paddingLarge
                        wrapMode: Text.Wrap
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.rgba(wizardManager.defaultHighlightColor(), 0.9)
                        text: fullTermsDialog.bodyText
                    }

                    TermsOfUseOptions {
                        width: parent.width

                        onAcceptClicked: fullTermsDialog.accept()
                        onRejectClicked: wizardManager.triggerShutdown()
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }
}
