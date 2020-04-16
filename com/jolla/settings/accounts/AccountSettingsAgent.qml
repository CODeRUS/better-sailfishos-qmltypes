import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

/*
    This component is used to implement an account settings UI plugin.

    When the settings for this account need to be displayed, an instance of this component is created
    and the initialPage is pushed onto the page stack.

    The implementation must:

    1) Set the initialPage property (i.e. the first page in the account flow) to a page
    2) Emit accountDeletionRequested() signal and pop the page when the user wants to delete the
       account.

    The accountId property will automatically be set to the ID of the account to be displayed.
*/
Item {
    id: accountSettingsAgent

    // Provided for convenience; these will be set to valid values on construction
    property int accountId
    property Provider accountProvider
    property AccountManager accountManager
    property string accountsHeaderText  // translated string; can be used as the page header title on this page.

    // Set this to true to delay the deletion of this instance after all of its pages have been popped
    // from the page stack.
    property bool delayDeletion

    // This will be set to true if the account should be read only (not editable) in the UI.
    property bool accountIsReadOnly

    // This will be set to true if the account is a provisioned (MDM) account.
    property bool accountIsProvisioned

    // This will be set to true if the account is not signed in.
    property bool accountNotSignedIn

    property Page initialPage

    signal accountDeletionRequested()

    FirstTimeUseCounter {
        id: firstTimeUseCounter
        limit: 3
        defaultValue: 1 // display hint twice for existing users
        key: "/sailfish/accounts/settings_autosave_hint_count"

        onActiveChanged: {
            if (active) {
                var comp = Qt.createComponent("AccountSettingsSaveHint.qml")
                if (comp.status == Component.Ready) {
                    var obj = comp.createObject(initialPage)
                    obj.hintShownChanged.connect(function() {
                        if (obj.hintShown) {
                            firstTimeUseCounter.increase()
                        }
                    })
                }
            }
        }
    }

    AccountFactory {
        id: accountFactory
    }

    Component.onCompleted: {
        if (accountId > 0) {
            accountFactory.ensureAccountSyncProfiles(accountId)
        }
    }
}
