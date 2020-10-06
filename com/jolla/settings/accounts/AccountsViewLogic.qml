/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

Item {
    property Item accountsPage
    property string title
    property var model
    property int deletingAccountId: -1

    property QtObject _settingsLoader
    property QtObject _settingsAgentRunner
    property QtObject _credentialsUpdater
    property alias accountCreationManager: accountCreationManager

    function _deleteAccountFromSettings(accountId) {
        deletingAccountId = accountId
        //: User is informed that account was deleted
        //% "Deleted account"
        var remorse = Remorse.popupAction(accountsPage, qsTrId("settings-accounts-la-deleted_account"),
                                       function() { accountCreationManager.deleteAccount(accountId) } )
        remorse.canceled.connect(function() { deletingAccountId = -1 })
    }

    function _showSettings(providerName, accountId, credentialsNeedUpdate) {
        if (_settingsLoader != null) {
            _settingsLoader.destroy()
        }
        _settingsLoader = settingsLoaderComponent.createObject(accountsPage)
        _settingsLoader.finished.connect(function() {
            if (credentialsNeedUpdate) {
                var delayedSettingsAgent = _accountSettingsAgent(providerName, 0)  // accountId is not set until credentials are updated
                if (_credentialsUpdater != null) {
                    _credentialsUpdater.destroy()
                }
                var credentialsUpdaterComponent = Qt.createComponent(Qt.resolvedUrl("AccountCredentialsUpdater.qml"))
                if (credentialsUpdaterComponent.status != Component.Ready) {
                    throw new Error("Unable to load AccountCredentialsUpdater.qml")
                }
                _credentialsUpdater = credentialsUpdaterComponent.createObject(accountsPage, {"accountManager": accountManager})
                _credentialsUpdater.credentialsUpdated.connect(function(updatedAccountId) {
                    // ensure the settingsAgent resets its account details when the credentials are updated
                    delayedSettingsAgent.accountId = updatedAccountId
                })
                _credentialsUpdater.pushCredentialsUpdatePage(accountId, delayedSettingsAgent.initialPage)
            } else {
                var settingsAgent = _accountSettingsAgent(providerName, accountId)
                pageStack.push(settingsAgent.initialPage)
            }
        })
        _settingsLoader.start(accountId)
    }

    function _accountSettingsAgent(providerName, accountId) {
        var accountRef = model.getByAccount(accountId)
        var agentProperties = {
            "accountManager": accountManager,
            "accountProvider": accountManager.provider(providerName),
            "accountsHeaderText": title,
            "accountId": accountId,
            "accountIsReadOnly": accountRef.accountReadOnly,
            "accountIsLimited": accountRef.accountLimited,
            "accountIsProvisioned": accountRef.accountProvisioned,
            "accountNotSignedIn": (accountRef.accountError === AccountModel.AccountNotSignedInError)
        }
        if (agentProperties["accountProvider"] == null) {
            throw new Error("Unable to obtain provider with name: " + providerName)
        }
        var runnerProperties = {
            "agentComponentFileName": "/usr/share/accounts/ui/" + providerName + "-settings.qml",
            "agentProperties": agentProperties
        }
        var agentRunnerComponent = Qt.createComponent(Qt.resolvedUrl("AccountAgentRunner.qml"))
        if (agentRunnerComponent.status != Component.Ready) {
            throw new Error("Unable to load AccountAgentRunner.qml")
        }
        if (_settingsAgentRunner != null) {
            _settingsAgentRunner.destroy()
        }
        _settingsAgentRunner = agentRunnerComponent.createObject(accountCreationManager, runnerProperties)
        _settingsAgentRunner.finished.connect(function() {
            _settingsAgentRunner.destroy()
            _settingsAgentRunner = null
        })
        _settingsAgentRunner.agent.accountDeletionRequested.connect(function() {
            _deleteAccountFromSettings(accountId)
        })
        return _settingsAgentRunner.agent
    }

    AccountCreationManager {
        id: accountCreationManager

        endDestination: accountsPage
        _accountManager: accountManager
    }

    AccountManager {
        id: accountManager
    }

    RemorsePopup {
        id: accountDeletionRemorse
    }

    AccountSyncAdapter {
        id: accountSyncAdapter
    }

    Component {
        id: settingsLoaderComponent
        AccountSyncManager {
            signal finished

            function start(accountId) {
                if (createAllProfiles(accountId) == 0) {
                    finished()
                }
            }

            onAllProfilesCreated: {
                finished()
            }
            onAllProfileCreationError: {
                console.log("AccountsPage: unable to create missing profiles for account", accountId)
                finished()
            }
        }
    }

    function accountClicked(accountId, providerName) {
        var credentialsNeedUpdate = model.getByAccount(accountId).accountError === AccountModel.AccountNotSignedInError
        _showSettings(providerName, accountId, credentialsNeedUpdate)
    }

    function accountRemoveRequested(accountId) {
        accountCreationManager.deleteAccount(accountId)
    }

    function accountSyncRequested(accountId) {
        accountSyncAdapter.triggerSync(accountId)
    }
}
