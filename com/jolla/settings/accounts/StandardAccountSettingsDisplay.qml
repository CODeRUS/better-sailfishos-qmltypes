import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Column {
    id: root

    property bool autoEnableAccount
    property alias accountEnabled: mainAccountSettings.accountEnabled
    property alias accountEnabledReadOnly: mainAccountSettings.accountEnabledReadOnly
    property bool settingsModified

    property bool accountValid: _initialized && accountSignedIn && account.status !== Account.Error
    property bool accountSignedIn

    property Provider accountProvider
    property AccountManager accountManager
    property alias account: accountObj
    property int accountId
    property alias nextFocusItem: mainAccountSettings.nextFocusItem

    property alias accountUserName: mainAccountSettings.accountUserName

    default property alias _children: contentColumn.data

    signal aboutToSaveAccount()
    signal accountInitialized()
    signal accountSaveCompleted(var success)
    signal accountSaveSynced()

    function reload(newAccountId) {
        accountId = 0
        _initialized = false
        accountId = newAccountId
    }

    function saveAccount(blockingSave) {
        // credentials may have expired while settings display was visible.
        // update the local value, otherwise sync may overwrite it with wrong value.
        var credentialsNeedUpdate = accountManager.credentialsNeedUpdate(root.accountId)

        if (!accountValid) {
            return
        }
        if (settingsModified
                || account.status == Account.Modified
                || _originalEnabled != mainAccountSettings.accountEnabled
                || _originalDisplayName != mainAccountSettings.accountDisplayName
                || accountSignedIn === credentialsNeedUpdate) {
            // something has changed.  Store the changes to the database.
            _resetUnsavedSettings()
            account.enabled = mainAccountSettings.accountEnabled
            account.displayName = mainAccountSettings.accountDisplayName
            account.setConfigurationValue("", "CredentialsNeedUpdate", credentialsNeedUpdate)

            // allow sub-components to apply any settings changes
            aboutToSaveAccount()

            // now sync
            _saving = true
            if (blockingSave) {
                account.blockingSync()
            } else {
                account.sync()
            }
            return true
        }
        return false
    }

    function saveAccountAndSync() {
        if (!accountValid) {
            return
        }
        if (saveAccount()) {
            root._syncProfileWhenAccountSaved = true
        } else {
            syncAdapter.triggerSync(account)
        }
    }

    function testHasCheckedSwitch(repeater) {
        var hasCheckedSwitch = false
        for (var i = 0; i < repeater.count; ++i) {
            hasCheckedSwitch |= repeater.itemAt(i).checked
        }
        return hasCheckedSwitch
    }

    property bool _initialized
    property bool _originalEnabled
    property string _originalDisplayName
    property bool _syncProfileWhenAccountSaved
    property bool _saving

    function _resetUnsavedSettings() {
        // we don't want to sync the account when the user accepts
        // the dialog unless something has actually changed.
        // To detect changes, we cache the "global" settings.
        _originalEnabled = account.enabled
        _originalDisplayName = account.displayName
    }

    width: parent.width

    AccountSyncAdapter {
        id: syncAdapter
        accountManager: root.accountManager
    }

    Account {
        id: accountObj

        identifier: root.accountId

        onStatusChanged: {
            if (status === Account.Initialized) {
                root._resetUnsavedSettings()
                root._initialized = true
                var credentialsNeedUpdate = configurationValues("")["CredentialsNeedUpdate"] // NOTE: read from global service!  jolla-signon-ui mediates this.
                root.accountSignedIn = (credentialsNeedUpdate === undefined || !credentialsNeedUpdate || credentialsNeedUpdate === 'false')
                mainAccountSettings.accountEnabled = root.autoEnableAccount || account.enabled
                root.accountInitialized()
            } else if (status === Account.Synced) {
                // success
                accountSaveSynced()
                if (root._syncProfileWhenAccountSaved) {
                    root._syncProfileWhenAccountSaved = false
                    syncAdapter.triggerSync(account)
                }
            } else if (status === Account.Error) {
                // display "error" dialog
            } else if (status === Account.Invalid) {
                // successfully deleted
            }
            if (root._saving && status != Account.SyncInProgress) {
                root._saving = false
                root.accountSaveCompleted(status == Account.Synced)
            }
        }
    }

    visible: root.accountValid

    AccountMainSettingsDisplay {
        id: mainAccountSettings
        accountProvider: root.accountProvider
        accountUserName: account.defaultCredentialsUserName
        accountDisplayName: account.displayName
    }

    Column {
        id: contentColumn
        width: parent.width
        visible: root.accountEnabled
    }
}
