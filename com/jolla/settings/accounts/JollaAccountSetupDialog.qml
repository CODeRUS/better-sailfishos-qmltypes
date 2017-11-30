import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.accounts 1.0

Dialog {
    id: root

    property bool wizardMode
    property bool runningFromSettingsApp

    property string username: userCredentials.username
    property string password: userCredentials.password

    property var skipDestination
    property int skipDestinationAction
    property var skipDestinationProperties: ({})
    property var skipDestinationReplaceTarget

    signal accountCreated(var accountId)
    signal accountCreationError(var errorMessage)
    signal skipRequested()

    property Page _accountCreationPage
    property Page _signInBusyPage
    property int _animationDuration: 250
    property int _animationEasingType: Easing.InOutQuad

    //: Previous page
    //% "Previous"
    property string _previousPageText: qsTrId("settings_accounts-he-previous_page")

    //: Next page
    //% "Next"
    property string _nextPageText: qsTrId("settings_accounts-he-next_page")

    canAccept: userCredentials.canValidateCredentials
               && ((root.state == "createNewAccount" && userCredentials.usernameValid) || root.state == "signIn")
    acceptDestination: root.state == "createNewAccount" ? _accountCreationPage : _signInBusyPage

    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (_accountCreationPage != null) {
                _accountCreationPage.destroy()
                _accountCreationPage = null
            }
            _accountCreationPage = accountCreationComponent.createObject(root)

            if (_signInBusyPage != null) {
                _signInBusyPage.destroy()
                _signInBusyPage = null
            }
            _signInBusyPage = signInBusyComponent.createObject(root)

            userCredentials.autoValidate = true
        } else if (status == PageStatus.Activating && userCredentials.signInFailed) {
            // scroll to bottom so user sees the sign-in error message
            flickable.contentY = flickable.contentHeight - flickable.height
        }
    }

    onDone: {
        userCredentials.autoValidate = false
        focus = true
        if (result == DialogResult.Rejected) {
            userCredentials.cancel()
        }
    }

    onAcceptPendingChanged: {
        if (acceptPending) {
            focus = true
            userCredentials.highlightInvalidFields = true
            if (!canAccept && root.state == "createNewAccount") {
                userCredentials.validateNewAccountCredentials()
            }
        }
    }

    state: "signIn"
    states: [
        State {
            name: "signIn"
            PropertyChanges { target: userCredentials; state: "signIn" }
            PropertyChanges { target: signInSwitch; checked: true }
            PropertyChanges { target: newUserSwitch; checked: false }
            PropertyChanges { target: forgottenPasswordSection; state: "visible" }
            PropertyChanges {
                target: eulaReminder
                height: 0
                opacity: 0
                enabled: false
            }
        },
        State {
            name: "createNewAccount"
            PropertyChanges { target: userCredentials; state: "createNewAccount" }
            PropertyChanges { target: signInSwitch; checked: false }
            PropertyChanges { target: newUserSwitch; checked: true }
            PropertyChanges { target: forgottenPasswordSection; state: "hidden" }
            PropertyChanges {
                target: eulaReminder
                height: eulaReminder.implicitHeight
                opacity: 1
                enabled: true
            }
        }
    ]

    transitions: [
        Transition {
            from: "createNewAccount"; to: "signIn"
            reversible: true
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        property: "height"
                        duration: root._animationDuration * 0.5
                        easing.type: root._animationEasingType
                    }
                    NumberAnimation {
                        target: eulaReminder
                        property: "opacity"
                        duration: root._animationDuration * 0.5
                        easing.type: root._animationEasingType
                    }
                }
            }
        }
    ]

    Component {
        id: signInBusyComponent
        AccountBusyPage {
            busyDescription: signingInText

            onStatusChanged: {
                if (status == PageStatus.Active) {
                    if (root.state == "signIn") {
                        userCredentials.signIn()
                    }
                } else if (status == PageStatus.Deactivating && userCredentials.busy) {
                    userCredentials.cancel()
                }
            }
        }
    }

    JollaAccountUtilities {
        id: jollaAccountUtil
    }

    SilicaFlickable {
        id: flickable

        property int _baseHeight: contentColumn.height + (skipLink.visible ? skipLink.anchors.topMargin + skipLink.height : 0) + Theme.paddingLarge
        contentHeight: Math.max(_baseHeight, isPortrait ? Screen.height : Screen.width)
        anchors.fill: parent

        VerticalScrollDecorator {}

        Column {
            id: contentColumn
            width: parent.width

            DialogHeader {
                dialog: root
                acceptText: root.wizardMode ? root._nextPageText : defaultAcceptText
                cancelText: root.wizardMode ? root._previousPageText : defaultCancelText

                //: Heading for page that allows sign-up for a Jolla account
                //% "Add your Jolla account to get apps and updates"
                title: qsTrId("settings_accounts-he-add_jolla_account_to_get_apps_and_updates")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge * 2
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
                font.pixelSize: Theme.fontSizeExtraSmall
                color: Theme.highlightColor
                visible: !root.runningFromSettingsApp

                //% "Other accounts can be set up later from Settings | Accounts."
                text: qsTrId("settings_accounts-la-other_accounts_setup_later_from_settings")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
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

            TextSwitch {
                id: signInSwitch
                automaticCheck: false

                //: User selects this option if he/she already has a Jolla account
                //% "I have a Jolla account"
                text: qsTrId("settings_accounts-la-have_jolla_account_heading")

                //: User selects this option if he/she already has a Jolla account
                //% "You probably have a Jolla account if you have used a Jolla device, created an account at account.jolla.com or used our community platform at together.jolla.com."
                description: qsTrId("settings_accounts-la-have_jolla_account_description")

                onClicked: {
                    root.state = "signIn"
                }
            }

            TextSwitch {
                id: newUserSwitch
                automaticCheck: false

                //: User selects this option if he/she already has a Jolla account
                //% "I am a new user"
                text: qsTrId("settings_accounts-la-new_jolla_user_heading")

                //: User selects this option if he/she already has a Jolla account
                //% "Select this if you haven't used any Jolla devices or Jolla web services before."
                description: qsTrId("settings_accounts-la-new_jolla_user_description")

                onClicked: {
                    root.state = "createNewAccount"
                }
            }

            Item {
                width: 1
                height: Theme.paddingLarge
            }

            JollaAccountCredentialsInput {
                id: userCredentials
                animationDuration: root._animationDuration
                animationEasingType: root._animationEasingType

                onSignInRequested: {
                    if (root.state == "signIn" && root.canAccept) {
                        root.accept()
                    }
                }
                onAccountSignInSuccess: {
                    root.accountCreated(accountId)
                }
                onAccountSignInError: {
                    pageStack.pop(root)
                    root.accountCreationError(errorMessage)
                }
            }

            Item {
                width: 1
                height: Theme.paddingMedium
            }

            ClickableTextLabel {
                id: eulaReminder
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                font.pixelSize: Theme.fontSizeSmall

                //: Text above the link to the Terms of Service and Privacy Policy. (Text surrounded by %1 and %2 is underlined and colored differently)
                //% "By creating an account you accept the %1Jolla Terms of Service and Jolla Privacy Policy%2. Please read these carefully before moving forward."
                text: qsTrId("settings_accounts-la-jolla_account_agree_terms_and_privacy")
                                .arg("<u><font color=\"" + (pressed ? Theme.highlightColor : Theme.primaryColor) + "\">")
                                .arg("</font></u>")
                onClicked: {
                    pageStack.push(legaleseComponent)
                }
            }

            JollaAccountForgotPasswordInfo {
                id: forgottenPasswordSection
                animationDuration: root._animationDuration
                animationEasingType: root._animationEasingType
            }
        }

        Item {
            id: spacer
            anchors.top: contentColumn.bottom
            width: 1
            height: flickable.contentHeight - flickable._baseHeight
        }

        ClickableTextLabel {
            id: skipLink
            anchors {
                left: parent.left
                leftMargin: Theme.horizontalPageMargin
                top: spacer.bottom
                topMargin: Theme.itemSizeSmall
                right: parent.right
                rightMargin: anchors.leftMargin
            }
            verticalAlignment: Text.AlignBottom
            visible: !root.runningFromSettingsApp
            font.pixelSize: Theme.fontSizeSmall

            //: Alternative option if user doesn't want to create or sign into a Jolla account at the moment. (Text surrounded by %1 and %2 is underlined and colored differently)
            //% "%1Skip%2 Jolla account setup for now"
            text: qsTrId("settings_accounts-la-sign_in_skip_jolla_account_setup_for_now")
                            .arg("<u><font color=\"" + (pressed ? Theme.highlightColor : Theme.primaryColor) + "\">")
                            .arg("</font></u>")
            onClicked: {
                pageStack.push(skipConfirmationComponent)
            }
        }
    }

    Component {
        id: accountCreationComponent
        JollaAccountCreationSecondDialog {
            acceptDestination: busyComponent

            username: root.username
            password: root.password
            createAccountOnAccept: false
            acceptText: root.wizardMode ? root._nextPageText : ""
            cancelText: root.wizardMode ? root._previousPageText : ""

            onStatusChanged: {
                if (status == PageStatus.Inactive && result == DialogResult.Accepted) {
                    createAccount()
                }
            }
            onAccountCreated: {
                root.accountCreated(newAccountId)
            }
            onAccountCreationTypedError: {
                root.accountCreationError(errorMessage)
                acceptDestinationInstance.showError(errorCode, errorMessage)
            }
        }
    }

    Component {
        id: busyComponent
        AccountBusyPage {
            function showError(errorCode, errorMessage) {
                if (errorCode != AccountFactory.UnknownError && errorCode != AccountFactory.InternalError) {
                    infoDescription = errorMessage
                }
                state = "info"
            }

            infoExtraDescription: !root.runningFromSettingsApp
                    //% "Go back to try again, or skip now and add your Jolla account later from Settings | Accounts."
                  ? qsTrId("components_accounts-la-go_back_or_skip_jolla_account")
                  : ""
            infoButtonText: !root.runningFromSettingsApp ? skipButtonText : ""

            onInfoButtonClicked: {
                root.skipRequested()
            }
        }
    }

    Component {
        id: legaleseComponent
        JollaAccountLegaleseDialog {
            Component.onCompleted: {
                var termsOfService = jollaAccountUtil.termsOfService(Qt.locale().name)
                if (termsOfService.length == 2) {
                    termsOfServiceHeading = termsOfService[0]
                    termsOfServiceText = termsOfService[1]
                } else {
                    console.log("Unable to load Terms of Service for locale:", Qt.locale().name)
                }

                var privacyPolicy = jollaAccountUtil.privacyPolicy(Qt.locale().name)
                if (privacyPolicy.length == 2) {
                    privacyPolicyHeading = privacyPolicy[0]
                    privacyPolicyText = privacyPolicy[1]
                } else {
                    console.log("Unable to load Privacy Policy for locale:", Qt.locale().name)
                }
            }
        }
    }

    Component {
        id: skipConfirmationComponent
        Dialog {
            acceptDestination: root.skipDestination
            acceptDestinationAction: root.skipDestinationAction
            acceptDestinationProperties: root.skipDestinationProperties
            acceptDestinationReplaceTarget: root.skipDestinationReplaceTarget

            SilicaFlickable {
                anchors.fill: parent
                contentHeight: skipConfirmationContent.height

                DialogHeader {
                    id: header

                    //: Answer 'Yes' to the question "Are you sure want to skip?"
                    //% "Yes"
                    acceptText: qsTrId("settings_accounts-la-skip_yes")

                    //: Answer 'No' to the question "Are you sure want to skip?"
                    //% "No"
                    cancelText: qsTrId("settings_accounts-la-skip_no")

                    //: Heading for page where user can confirm whether to really skip Jolla account setup
                    //% "Are you sure you want to skip?"
                    title: qsTrId("settings_accounts-la-skip_confirmation")
                }

                Column {
                    id: skipConfirmationContent
                    anchors {
                        top: header.bottom
                        left: parent.left
                        right: parent.right
                    }
                    spacing: Theme.paddingLarge

                    Label {
                        x: Theme.horizontalPageMargin
                        width: parent.width - x*2
                        height: implicitHeight + Theme.paddingLarge*3
                        wrapMode: Text.WordWrap
                        color: Theme.highlightColor
                        font.pixelSize: Theme.fontSizeExtraSmall
                        //: Description of what user will miss if the option to set up a Jolla account is missed
                        //% "Without a Jolla account, you'll only get basic device functionality. You'll also miss out on OS updates and you won't be able to access the Jolla store."
                        text: qsTrId("settings_accounts-la-without_jolla_account")
                    }

                    Image {
                        anchors.horizontalCenter: parent.horizontalCenter
                        source: "image://theme/graphic-store-jolla-apps"
                    }
                }
            }
        }
    }
}
