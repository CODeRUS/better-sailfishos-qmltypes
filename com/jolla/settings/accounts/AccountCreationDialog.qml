import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

// xxxxxx for legacy versions of email and active sync plugins xxxxxx

Dialog {
    id: root
    allowedOrientations: Orientation.Portrait

    // If this dialog is a sub-dialog in the sequence of creation pages for a particular account,
    // set this property to the root creation page to automatically bind the appropriate account
    // creation properties of this dialog to that of the root creation page.
    property Item rootAccountCreationPage

    // If true, acceptDestination* properties are bound to skipDestination* properties, otherwise this
    // will move onto creationBusyDialog. Note this has no effect if the acceptDestination binding
    // has been overridden.
    property bool canSkip

    //% "Skip"
    property string skipText: qsTrId("components_accounts-he-skip")

    // Automatically provided by the creation manager. Can be overridden if necessary.
    property Provider accountProvider: rootAccountCreationPage != null ? rootAccountCreationPage.accountProvider : null
    property AccountManager accountManager: rootAccountCreationPage != null ? rootAccountCreationPage.accountManager : null

    // Once this dialog becomes active, this property in the root creation page is automatically
    // set to an instance of AccountCreationBusyDialog.qml.
    // This can be overridden to set a custom creationBusyDialog page.
    property Item creationBusyDialog: rootAccountCreationPage != null ? rootAccountCreationPage.creationBusyDialog : null

    // Once this dialog becomes active, these properties in the root creation page are automatically
    // set by the creation manager.
    // These should not be changed as the account creation manager sets them automatically. In any
    // case, they are only referred to by the acceptDestination* properties, so those can be
    // tweaked instead.
    property var skipDestination: rootAccountCreationPage != null ? rootAccountCreationPage.skipDestination : null
    property int skipDestinationStackAction: rootAccountCreationPage != null ? rootAccountCreationPage.skipDestinationStackAction : PageStackAction.Pop
    property var skipDestinationProperties: rootAccountCreationPage != null ? rootAccountCreationPage.skipDestinationProperties : ({})
    property var skipDestinationReplaceTarget: rootAccountCreationPage != null ? rootAccountCreationPage.skipDestinationReplaceTarget : undefined

    // This should be emitted when the account is successfully created.
    signal accountCreated(int newAccountId)

    // This should be emitted when the account creation fails.
    signal accountCreationError(string errorMessage)
    signal accountCreationTypedError(int errorCode, string errorMessage)

    acceptDestination: canSkip && skipDestination !== undefined ? skipDestination : creationBusyDialog
    acceptDestinationAction: canSkip && skipDestination !== undefined ? skipDestinationStackAction : PageStackAction.Replace
    acceptDestinationProperties: canSkip && skipDestination !== undefined ? skipDestinationProperties : ({})
    acceptDestinationReplaceTarget: canSkip && skipDestination !== undefined ? skipDestinationReplaceTarget : undefined

    onAccountCreated: {
        if (creationBusyDialog !== null) {
            creationBusyDialog.accountCreationSucceeded(newAccountId)
        }
    }

    // AccountCreationManager caches this page to ensure account changes are saved after
    // the page is popped, but this means the vkb may remain visible due to a textfield
    // in the page keeping the focus, so ensure the focus is removed
    onAcceptPendingChanged: {
        if (acceptPending) {
            root.focus = true
        }
    }
    onStatusChanged: {
        if (status == PageStatus.Inactive) {
            root.focus = true
        }
    }

    onAccountCreationError: handleTypedAccountCreationError(AccountFactory.UnknownError, errorMessage)
    onAccountCreationTypedError: handleTypedAccountCreationError(errorCode, errorMessage)
    function handleTypedAccountCreationError(errorCode, errorMessage) {
        if (creationBusyDialog !== null) {
            creationBusyDialog.accountCreationFailed(errorCode, errorMessage)
        } else {
            // this signal may be received before the page becomes active and creationBusyDialog is set
            creationBusyDialogChanged.connect(function() {
                if (creationBusyDialogChanged !== null) {
                    creationBusyDialog.accountCreationFailed(errorCode, errorMessage)
                }
            })
        }
    }
}
