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

    property alias username: usernameField.text
    property alias password: passwordField.text

    property Item _termsOfServicePage
    property Item _privacyPolicyPage
    property bool _validPassword: passwordField.text.length > 5
    property bool _validConfirmedPassword: _validPassword && passwordField.text === passwordConfirmField.text
    property int _usernameStatus: AccountFactory.UsernameNotChecked
    property bool _checkingUsername

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
               && _validPassword
               && _validConfirmedPassword
               && _usernameStatus == AccountFactory.UsernameAvailable
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

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
                visible: text != ""
                text: {
                    //: Hint text for changing keyboard layout on spacebar long press, translate only for non-latin languages
                    //% ""
                    var translation = qsTrId("settings_accounts-la-vkb_layout_change_hint")
                    return (translation === "settings_accounts-la-vkb_layout_change_hint")
                            ? ""
                            : translation
                }
            }

            Item {
                width: parent.width
                height: Theme.itemSizeExtraSmall
            }

            AccountUsernameField {
                id: usernameField
                onFocusChanged: {
                    if (!focus
                            && root._usernameStatus != AccountFactory.UsernameAvailable
                            && root.status == PageStatus.Active) {
                        checkUsername()
                    }
                }
                onTextChanged: {
                    root._usernameStatus = AccountFactory.UsernameNotChecked
                    if (!root._checkingUsername) {
                        usernameCheckTimer.restart()
                    }
                }

                errorHighlight: (!text && checkMandatoryFields)
                                || (text && root._usernameStatus != AccountFactory.UsernameAvailable)

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: passwordField.focus = true
            }

            Item {
                width: parent.width
                height: usernameCheckLabel.text.length
                        ? usernameCheckLabel.implicitHeight + Theme.paddingLarge*2
                        : 0
                Behavior on height { NumberAnimation {} }
                clip: true

                Rectangle {
                    anchors {
                        fill: parent
                        topMargin: Theme.paddingMedium
                        bottomMargin: Theme.paddingMedium
                    }

                    color: Theme.highlightBackgroundColor
                    opacity: Theme.highlightBackgroundOpacity
                }

                Label {
                    id: usernameCheckLabel
                    anchors {
                        left: parent.left
                        leftMargin: Theme.horizontalPageMargin
                        right: usernameCheckSpinner.running ? usernameCheckSpinner.left : parent.right
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    wrapMode: Text.Wrap
                    font.pixelSize: Theme.fontSizeExtraSmall
                    color: Theme.highlightColor
                    text: {
                        if (root._checkingUsername) {
                            //: Tells the user that the username availability is being checked
                            //% "Checking username availability"
                            return qsTrId("settings_accounts-username_checking_availability")
                        } else if (root._usernameStatus == AccountFactory.UsernameAvailable) {
                            //: The entered username is available
                            //% "Username is available"
                            return qsTrId("settings_accounts-la_username_available")
                        } else if (root._usernameStatus == AccountFactory.UsernameNotAvailable) {
                            //: The entered username is not available as it is already taken
                            //% "Sorry, this username is already taken"
                            return qsTrId("settings_accounts-username_already_taken")
                        } else if (root._usernameStatus == AccountFactory.UsernameInvalid) {
                            //: The entered username is invalid
                            //% "A username can only contain letters, numbers, periods, underscores, hyphens and the @ symbol."
                            return qsTrId("settings_accounts-la_username_invalid")
                        } else if (root._usernameStatus == AccountFactory.UsernameCheckError) {
                            //: Tells the user that we couldn't check whether the username was available due to network or other error
                            //% "Unable to check username availability"
                            return qsTrId("settings_accounts-la-username_cannot_check")
                        } else if (root._usernameStatus == AccountFactory.UsernameCheckSslError) {
                            //: The entered username is invalid
                            //% "Unable to check username availability. Make sure the system date and time are correct in Settings | System | Date and time."
                            return qsTrId("settings_accounts-la_username_ssl_error")
                        } else {
                            return ""
                        }
                    }
                }

                BusyIndicator {
                    id: usernameCheckSpinner
                    anchors {
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }
                    size: BusyIndicatorSize.ExtraSmall
                    running: root._checkingUsername
                }
            }

            AccountPasswordField {
                id: passwordField
                errorHighlight: (!text && checkMandatoryFields) || (text && !_validPassword)

                EnterKey.onClicked: passwordConfirmField.focus = true
            }

            TextField {
                id: passwordConfirmField
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                echoMode: TextInput.Password
                errorHighlight: !root._validConfirmedPassword

                enabled: passwordField.text || text
                opacity: enabled ? 1 : 0.5
                Behavior on opacity { FadeAnimation { } }

                //% "Re-enter password"
                label: qsTrId("settings_accounts-la-password_confirm")

                //% "Re-enter password"
                placeholderText: qsTrId("settings_accounts-ph-password_confirm")

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: root.focus = true
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

    onAcceptPendingChanged: {
        if (acceptPending === true) {
            checkMandatoryFields = true
            if (root.username.length > 0 && root._usernameStatus != AccountFactory.UsernameAvailable) {
                // username is non-empty but last check failed or result was unknown, try again
                checkUsername()
            }
        }
    }

    onAccepted: {
        // Left for compatibility with 1.0.0.5 updates
        root.legalDocumentsAccepted()
    }

    function checkUsername() {
        if (_usernameStatus == AccountFactory.UsernameNotChecked
                && !_checkingUsername
                && usernameField.text != "") {
            _checkingUsername = true
            jollaAccountUtil.checkUsernameAvailability(usernameField.text)
        }
    }

    Timer {
        id: usernameCheckTimer
        interval: 2500
        onTriggered: {
            if (!root._checkingUsername) {
                root.checkUsername()
            }
        }
    }

    JollaAccountUtilities {
        id: jollaAccountUtil
        onUsernameCheckFinished: {
            root._usernameStatus = result
            root._checkingUsername = false
        }
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
