import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Dialog {
    id: root

    property AccountManager accountManager

    // Required for compatibility with jolla-store implementation.
    property Provider accountProvider
    property Item creationBusyDialog
    acceptDestination: creationBusyDialog

    property bool createAccountOnAccept: true

    signal signInFinished(bool success)

    signal accountCreated(int newAccountId)
    signal accountCreationTypedError(int errorCode, string errorMessage)

    function startAccountCreation() {
        accountFactory.beginCreation()
    }

    function _busyDialogFinished() {
        if (creationBusyDialog.status == PageStatus.Inactive) {
            signInState.state = ""
            creationBusyDialog.statusChanged.disconnect(_busyDialogFinished)
        }
    }

    canAccept: field_username.text !== "" && field_password.text !== ""

    onAccepted: {
        if (createAccountOnAccept) {
            startAccountCreation()
        }
    }

    onRejected: {
        if (creationBusyDialog != null) {
            _busyDialogFinished()
        }
    }

    // Required for compatibility with jolla-store implementation.
    // It expects creationBusyDialog (an instance of AccountCreationBusyDialog) to be notified of
    // the account creation result.
    onAccountCreated: {
        if (creationBusyDialog != null) {
            creationBusyDialog.accountCreationSucceeded(newAccountId)
        }
    }
    onAccountCreationTypedError: {
        if (creationBusyDialog != null) {
            creationBusyDialog.accountCreationFailed(errorCode, errorMessage)
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active && creationBusyDialog != null) {
            signInState.state = "signing-in"
            creationBusyDialog.statusChanged.connect(_busyDialogFinished)
        } else if (status == PageStatus.Inactive) {
            root.focus = true
        }
    }

    // can't use Binding here (QTBUG-33444)
    StateGroup {
        id: signInState
        states: State {
            name: "signing-in"
            PropertyChanges {
                target: creationBusyDialog

                //: Notifies the device is in the process of signing into the account
                //% "Signing in..."
                progressStatusText: qsTrId("components_accounts-la-signing_into_account")
            }
        }
    }

    AccountFactory {
        id: accountFactory

        function beginCreation() {
            // this function does not register a new user
            // but instead, creates an account on the device
            // for the existing user specified.
            createExistingJollaAccount(field_username.text,
                                       field_password.text,
                                       "Jolla", "Jolla")
        }

        onError: {
            console.log("JollaAccountSignInDialog error:", message)
            root.accountCreationTypedError(errorCode, message)
            root.signInFinished(false)
        }

        onSuccess: {
            root.accountCreated(newAccountId)
            root.signInFinished(true)
        }
    }

    Column {
        width: parent.width

        DialogHeader {
            dialog: root
        }


        Column {
            width: parent.width - Theme.paddingLarge*2

            Row {
                x: Theme.paddingLarge
                spacing: Theme.paddingLarge
                height: accountIcon.height + spacing

                AccountIcon {
                    id: accountIcon
                    width: Theme.iconSizeLarge
                    height: width
                    source: root.accountProvider.iconName
                }

                Label {
                    anchors.verticalCenter: accountIcon.verticalCenter
                    text: root.accountProvider.displayName
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeLarge
                }
            }

            Label {
                x: Theme.paddingLarge
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

            TextField {
                id: field_username
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase

                //% "Username"
                label: qsTrId("settings_accounts-la-username")

                //% "Enter username"
                placeholderText: qsTrId("settings_accounts-ph-username")

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: field_password.focus = true
            }

            TextField {
                id: field_password
                width: parent.width
                inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
                echoMode: TextInput.Password

                //% "Password"
                label: qsTrId("settings_accounts-la-password")

                //% "Enter password"
                placeholderText: qsTrId("settings_accounts-ph-password")

                EnterKey.enabled: field_username.text.length > 0 && field_password.text.length > 0
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: root.accept()
            }
        }
    }
}
