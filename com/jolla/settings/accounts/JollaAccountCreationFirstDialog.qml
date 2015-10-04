import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import org.nemomobile.systemsettings 1.0
import com.jolla.settings.system 1.0
import com.jolla.settings.accounts 1.0

Dialog {
    id: root

    property AccountManager accountManager
    property Provider accountProvider

    property alias username: userCredentials.username
    property alias password: userCredentials.password

    property Item _termsOfServicePage
    property Item _privacyPolicyPage

    property bool checkMandatoryFields

    // left for compatibility with 1.0.0.5
    signal legalDocumentsAccepted()
    property var endDestination
    property var endDestinationInstance
    acceptDestination: endDestination
    onAcceptDestinationInstanceChanged: {
        endDestinationInstance = acceptDestinationInstance
    }

    // Anchor the "terms" section at the bottom of the screen or below the text fields depending on
    // the screen space available. This is not done as a binding to ensure the section does not
    // jump whenever the vkb opens/closes due to that triggering a change in the flickable height.
    function _positionBottomSection() {
        var fullContentHeight = mainContentColumn.height + termsColumn.height
        termsColumn.anchors.topMargin = fullContentHeight < flickable.height ? (flickable.height - fullContentHeight) : Theme.paddingLarge
    }

    canAccept: username !== ""
               && password !== ""
               && userCredentials.canValidateCredentials
               && acceptDestination != null

    Component.onCompleted: {
        _positionBottomSection()
    }

    SilicaFlickable {
        id: flickable

        anchors.fill: parent
        contentHeight: termsColumn.y + termsColumn.height

        VerticalScrollDecorator {}

        Column {
            id: mainContentColumn
            width: parent.width

            onHeightChanged: {
                root._positionBottomSection()
            }

            DialogHeader {
                dialog: root

                // Ensure checkMandatoryFields is set if 'accept' is tapped and some fields
                // are not valid
                Item {
                    id: headerChild
                    Connections {
                        target: headerChild.parent
                        onClicked: root.checkMandatoryFields = true
                    }
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraLarge
                color: Theme.highlightColor

                // Heading for page that requests user's username and password in order to create a Jolla account
                //% "Account Info"
                text: qsTrId("settings_accounts-he-account_info")
            }

            Label {
                id: detailsPromptLabel
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor

                //: Description for page that requests user's username and password in order to create a Jolla account
                //% "Enter your account details to continue."
                text: qsTrId("settings_accounts-la-account_info")
            }

            Item {
                width: parent.width
                height: Theme.itemSizeExtraSmall
            }

            JollaAccountCredentialsInput {
                id: userCredentials
                state: "createNewAccount"
                highlightInvalidFields: root.checkMandatoryFields
            }
        }

        Column {
            id: termsColumn

            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                top: mainContentColumn.bottom
            }

            spacing: Theme.paddingLarge

            onHeightChanged: {
                root._positionBottomSection()
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor

                //: Text above the links to the Terms of Service and Privacy Policy
                //% "By creating an account you accept:"
                text: qsTrId("settings_accounts-la-jolla_account_agreements_accept_description")
            }

            ClickableTextLabel {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall

                //: Link to page that displays Jolla Terms of Service
                //% "<u>Jolla Terms of Service</u>"
                text: qsTrId("settings_accounts-he-jolla_terms_of_service_link")

                onClicked: {
                    if (_termsOfServicePage === null) {
                        _termsOfServicePage = legaleseComponent.createObject(root)
                        var doc = jollaAccountUtil.termsOfService(Qt.locale().name)
                        if (doc.length == 2) {
                            _termsOfServicePage.headingText = doc[0]
                            _termsOfServicePage.bodyText = doc[1]
                        } else {
                            console.log("Unable to load Terms of Service for locale:", Qt.locale().name)
                            return
                        }
                    }
                    pageStack.push(_termsOfServicePage)
                }
            }

            ClickableTextLabel {
                width: parent.width
                font.pixelSize: Theme.fontSizeSmall

                //: Link to page that displays Jolla Privacy Policy
                //% "<u>Jolla Privacy Policy</u>"
                text: qsTrId("settings_accounts-he-jolla_privacy_policy_link")

                onClicked: {
                    if (_privacyPolicyPage === null) {
                        _privacyPolicyPage = legaleseComponent.createObject(root)
                        var doc = jollaAccountUtil.privacyPolicy(Qt.locale().name)
                        if (doc.length == 2) {
                            _privacyPolicyPage.headingText = doc[0]
                            _privacyPolicyPage.bodyText = doc[1]
                        } else {
                            console.log("Unable to load PrivacyPolicy for locale:", Qt.locale().name)
                            return
                        }
                    }
                    pageStack.push(_privacyPolicyPage)
                }
            }

            Label {
                width: parent.width
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor

                //: Asks user to read Jolla Terms of Service and Privacy Policy before accepting this dialog.
                //% "Please read both of these carefully before accepting."
                text: qsTrId("settings_accounts-la-jolla_account_agreements_please_read")
            }

            Item {
                width: 1
                height: 1
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            userCredentials.autoValidate = true
        }
    }

    onAcceptPendingChanged: {
        if (acceptPending === true) {
            checkMandatoryFields = true
            userCredentials.validateNewAccountCredentials()
        }
    }

    onAccepted: {
        // Left for compatibility with 1.0.0.5 updates
        root.legalDocumentsAccepted()
        root.focus = true
        userCredentials.autoValidate = false
    }

    JollaAccountUtilities {
        id: jollaAccountUtil
    }

    Component {
        id: legaleseComponent
        Page {
            id: legalesePage
            property string headingText
            property string bodyText

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: contentColumn.y + contentColumn.height

                Column {
                    id: contentColumn
                    y: Theme.itemSizeLarge
                    width: parent.width
                    spacing: Theme.paddingLarge

                    Label {
                        x: Theme.horizontalPageMargin
                        width: parent.width - x*2
                        font.pixelSize: Theme.fontSizeExtraLarge
                        color: Theme.highlightColor
                        text: legalesePage.headingText

                        // using big font size, so ensure text does not wrap within words
                        fontSizeMode: Text.Fit
                        height: implicitHeight
                        wrapMode: Text.WordWrap
                    }

                    Label {
                        x: Theme.horizontalPageMargin
                        width: parent.width - x*2
                        wrapMode: Text.Wrap
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: Theme.highlightColor
                        text: legalesePage.bodyText
                    }
                }

                VerticalScrollDecorator {}
            }
        }
    }
}
