import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

Page {
    id: root

    allowedOrientations: Orientation.Portrait

    property QtObject _accountSyncAdapter
    property QtObject _settingsLoader
    property QtObject _settingsAgentRunner
    property QtObject _credentialsUpdater

    function _deleteAccountFromSettings(accountId) {
        //: Deleting this account in 5 seconds
        //% "Removing account"
        accountDeletionRemorse.execute(qsTrId("settings-accounts-la-remove_account"),
                                       function() { accountCreationManager.deleteAccount(accountId) } )
    }

    function _showSettings(providerName, accountId, showCredentialsPromptDialog) {
        if (_settingsLoader != null) {
            _settingsLoader.destroy()
        }
        _settingsLoader = settingsLoaderComponent.createObject(root)
        _settingsLoader.finished.connect(function() {
            if (showCredentialsPromptDialog) {
                var delayedSettingsAgent = _accountSettingsAgent(providerName, 0)  // accountId is not set until credentials are updated
                if (_credentialsUpdater != null) {
                    _credentialsUpdater.destroy()
                }
                var credentialsUpdaterComponent = Qt.createComponent(Qt.resolvedUrl("AccountCredentialsUpdater.qml"))
                if (credentialsUpdaterComponent.status != Component.Ready) {
                    throw new Error("Unable to load AccountCredentialsUpdater.qml")
                }
                _credentialsUpdater = credentialsUpdaterComponent.createObject(root, {"accountManager": accountManager})
                _credentialsUpdater.credentialsUpdated.connect(function(updatedAccountId) {
                    // ensure the settingsAgent resets its account details when the credentials are updated
                    delayedSettingsAgent.accountId = updatedAccountId
                })
                _credentialsUpdater.showCredentialsPromptDialog(providerName, accountId, delayedSettingsAgent.initialPage)
            } else {
                var settingsAgent = _accountSettingsAgent(providerName, accountId)
                pageStack.push(settingsAgent.initialPage)
            }

        })
        _settingsLoader.start(accountId)
    }

    function _accountSettingsAgent(providerName, accountId) {
        var agentProperties = {
            "accountManager": accountManager,
            "accountProvider": accountManager.provider(providerName),
            "accountsHeaderText": accountsView.headerItem.title,
            "accountId": accountId
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
            root._deleteAccountFromSettings(accountId)
        })
        return _settingsAgentRunner.agent
    }

    AccountCreationManager {
        id: accountCreationManager

        endDestination: root
        _accountManager: accountManager
    }

    AccountManager {
        id: accountManager
    }

    RemorsePopup {
        id: accountDeletionRemorse
    }

    Component {
        id: accountSyncAdapterComponent
        AccountSyncAdapter { }
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

    AccountsListView {
        id: accountsView

        anchors.fill: parent
        entriesInteractive: true

        header: PageHeader {
            //: Heading of the main Accounts page
            //% "Accounts"
            title: qsTrId("settings_accounts-he-page_accounts")
        }

        onAccountClicked: {
            var showCredentialsPrompt = model.getByAccount(accountId).accountError == AccountModel.AccountNotSignedInError
            root._showSettings(providerName, accountId, showCredentialsPrompt)
        }

        onAccountRemoveRequested: {
            accountCreationManager.deleteAccount(accountId)
        }

        onAccountSyncRequested: {
            if (root._accountSyncAdapter == null) {
                root._accountSyncAdapter = accountSyncAdapterComponent.createObject(root)
            }
            root._accountSyncAdapter.triggerSync(accountId)
        }

        PullDownMenu {
            MenuItem {
                //: Initiates adding a new account
                //% "Add account"
                text: qsTrId("components_accounts-me-add_account")
                onClicked: accountCreationManager.startAccountCreation()
            }
        }

        ViewPlaceholder {
            enabled: accountsView.count == 0

            //% "No accounts"
            text: qsTrId("components_accounts-he-no_accounts")
        }
    }
}
