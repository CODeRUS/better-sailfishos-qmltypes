import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import com.jolla.settings.accounts 1.0

// Required for compatibility with jolla-store implementation
// and also for the legacy account creation flow implemented by accountcreationmanager.js.

AccountBusyDialog {
    id: root

    // The settings page for the created account. It is automatically set as the acceptDestination
    // of this dialog.
    property Item settingsPage

    property bool _autoAccept

    function accountCreationSucceeded(newAccountId) {
        // Set AccountSettingsDialog::accountId so that the settings page will load this new account
        if (settingsPage !== null
                && settingsPage.__sailfish_account_settings_dialog !== undefined) {
            settingsPage.accountId = newAccountId
        }
        stopBusyIndicator(AccountFactory.NoError, "") // success, needs no informative text.
    }

    function accountCreationFailed(errorCode, errorMessage) {
        if (typeof(errorCode) == 'string') {
            // backward compatibility shim
            var msg = errorCode
            stopBusyIndicator(AccountFactory.UnknownError, msg)
        } else {
            stopBusyIndicator(errorCode, errorMessage) // pass along the error message
        }
    }

    acceptDestination: settingsPage

    //: Notifies user that the account is currently being created.
    //% "Creating account..."
    progressStatusText: qsTrId("components_accounts-la-creating_account")

    canAccept: false

    on_ResetState: {
        canAccept = false
        _autoAccept = false
        errorState.state = ""
    }

    onAccountTaskFinished: {
        if (success) {
            errorState.state = ""
            canAccept = true
            if (!pageStack.busy && pageStack.currentPage === root) {
                accept()
            } else {
                _autoAccept = true
            }
        } else {
            _autoAccept = false
            errorState.state = settingsPage !== null ? "error-with-destination" : "error"
        }
    }

    StateGroup {
        id: errorState
        states: [
            State {
                name: "error"
                PropertyChanges {
                    target: root
                    canAccept: root.acceptDestination != null && root.acceptDestination != undefined
                }
            },
            State {
                name: "error-with-destination"
                extend: "error"
                PropertyChanges {
                    target: root
                    acceptDestinationAction: settingsPage.acceptDestinationAction
                    acceptDestinationProperties: settingsPage.acceptDestinationProperties
                    acceptDestinationReplaceTarget: settingsPage.acceptDestinationReplaceTarget
                    acceptDestination: settingsPage.acceptDestination
                }
            }
        ]
    }

    Connections {
        target: pageStack
        onBusyChanged: {
            if (!pageStack.busy) {
                if (pageStack.currentPage !== root) {
                    _resetState()
                } else if (root._autoAccept && root.canAccept) {
                    accept()
                }
            }
        }
    }
}
