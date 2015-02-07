import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

// xxxxxx for legacy versions of email and active sync plugins xxxxx

Dialog {
    allowedOrientations: Orientation.Portrait

    property Provider accountProvider
    property AccountManager accountManager
    property int accountId
    property bool isNewAccount

    property bool __sailfish_account_settings_dialog

    signal accountDeletionRequested()

    // should not be able to navigate back from the settings dialog when creating a new account,
    // as this makes it confusing as to whether the account will still be saved
    backNavigation: !isNewAccount || (_navigation == PageNavigation.Forward) // prevent jump on animation

    acceptDestinationAction: PageStackAction.Replace

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
}
