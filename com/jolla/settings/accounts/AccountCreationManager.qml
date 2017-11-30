import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0
import org.nemomobile.configuration 1.0
import "accountcreationmanager.js" as ManagerScript

/*
This can be used to start the UI flow for creating a specific account (e.g. a Jolla account)
or for any account (by allowing the user to select from a displayed list).

For example, to start the Jolla account creation flow:


import com.jolla.settings.accounts 1.0

MyAppPage {
    id: root

    Button {
        text: "No Jolla account? Click here"
        onClicked: {
            accountCreationManager.startAccountCreationForProvider("jolla")
        }
    }

    AccountCreationManager {
        id: accountCreationManager

        // when user swipes forward after the last account set-up page, user should pop back
        // to the MyAppPage instance
        endDestination: root
        endDestinationAction: PageStackAction.Pop

        onAccountCreated: {
            console.log("FYI, created account with id:", newAccountId)
        }
    }
}


To start the generic account creation flow:

import com.jolla.settings.accounts 1.0

MyAppPage {
    id: root

    Button {
        text: "Create an account"
        onClicked: accountCreationManager.startAccountCreation()
    }

    AccountCreationManager {
        id: accountCreationManager

        // when user swipes forward after the last account set-up page, user should pop back
        // to the MyAppPage instance
        endDestination: root
        endDestinationAction: PageStackAction.Pop

        onAccountCreated: console.log("FYI, created account with id:", newAccountId)
    }
}

*/
Item {
    id: accountCreationManager

    // Holds the page that the user will swipe onto after the account creation process has finished.
    // The endDestinationAction and endDestinationProperties hold the action and properties for the
    // endDestination, as per PageStack's acceptDestinationAction and acceptDestinationProperties.
    property var endDestination
    property int endDestinationAction: PageStackAction.Pop
    property var endDestinationProperties: ({})
    property var endDestinationReplaceTarget

    property var serviceFilter: []

    signal accountCreated(int newAccountId, string providerName)
    signal accountCreationError(string errorMessage, string providerName)

    signal finished(bool success)   // success=true if all selected accounts were created, false otherwise

    property var _trackedObjects: ({})

    // xxxxxx for legacy versions of email and active sync plugins xxxxxx
    property QtObject _currSettingsPage

    function startAccountCreation() {
        pageStack.push(accountProviderPickerComponent)
    }

    function startAccountCreationForProvider(providerName, properties, pageStackOperation) {
        if (pageStackOperation === undefined) {
            pageStackOperation = PageStackAction.Animated
        }
        var agent = _accountCreationAgent(providerName, properties)
        if (accountFactory.haveNetworkConnectivity()) {
            pageStack.push(agent.initialPage, {}, pageStackOperation)
        } else {
            var props = {
                "acceptDestination": agent.initialPage,
                "acceptDestinationAction": PageStackAction.Replace
            }
            pageStack.push(networkCheckComponent, props, {}, pageStackOperation)
        }
    }

    function accountCreationPageForProvider(providerName, properties) {
        try {
            var agent = _accountCreationAgent(providerName, properties)
            return agent.initialPage
        } catch (e) {
            console.log("Could not create account page for \"", providerName, "\" error: ", e)
            return null
        }
    }

    // xxxxxx for legacy versions of email and active sync plugins xxxxxx
    function createSettingsPage(providerName, properties) {
        if (_currSettingsPage != null) {
            _currSettingsPage.destroy()
        }
        _currSettingsPage = ManagerScript.createSettingsPage(providerName, properties)
        return _currSettingsPage
    }

    function deleteAccount(accountId) {
        var account = _accountManager.account(accountId)
        if (account === null) {
            return
        }
        account.statusChanged.connect(function() {
            if (account.status === Account.Initialized) {
                var providerName = account.providerName
                if (providerName == "jolla") {
                    hasCreatedJollaAccountBefore.key = "/apps/jolla-settings/jolla_account_creation_achieved"
                    hasCreatedJollaAccountBefore.value = true
                    hasCreatedJollaAccountBefore.sync()
                }
                var accountIdentifier = account.identifier
                account.remove()
                syncAdapter.triggerSync(providerName, accountIdentifier)
            }
        })
    }

    function _accountCreationAgent(providerName, agentProperties) {
        agentProperties = agentProperties || {}
        agentProperties["accountManager"] = _accountManager
        agentProperties["accountProvider"] = _accountManager.provider(providerName)
        if (agentProperties["accountProvider"] == null) {
            throw new Error("Unable to obtain provider with name: " + providerName)
        }
        agentProperties["endDestination"] = Qt.binding(function() { return accountCreationManager.endDestination })
        agentProperties["endDestinationAction"] = Qt.binding(function() { return accountCreationManager.endDestinationAction })
        agentProperties["endDestinationProperties"] = Qt.binding(function() { return accountCreationManager.endDestinationProperties })
        agentProperties["endDestinationReplaceTarget"] = Qt.binding(function() { return accountCreationManager.endDestinationReplaceTarget })
        var runnerProperties = {
            "agentComponentFileName": "/usr/share/accounts/ui/" + providerName + ".qml",
            "agentProperties": agentProperties
        }
        var runner = agentRunnerComponent.createObject(accountCreationManager, runnerProperties)
        _trackedObjects[runner] = undefined
        runner.finished.connect(function() {
            delete _trackedObjects[runner]
            runner.destroy()
        })
        runner.completedCreation.connect(function() {
            accountCreationManager.finished(true)
        })
        runner.agent.accountCreated.connect(function(accountId) {
            accountCreationManager.accountCreated(accountId, providerName)
        })
        runner.agent.accountCreationError.connect(function(errorMessage) {
            accountCreationManager.accountCreationError(providerName, errorMessage)
        })
        return runner.agent
    }

    AccountFactory { id: accountFactory }

    ConfigurationValue {
        id: hasCreatedJollaAccountBefore
    }

    AccountSyncAdapter { id: syncAdapter }

     // used by accountcreationmanager.js
    property AccountManager _accountManager: AccountManager {}

    Component {
        id: accountProviderPickerComponent
        Page {
            SilicaFlickable {
                anchors.fill: parent
                contentHeight: accountPickerHeader.height + accountPicker.height + Theme.paddingLarge

                PageHeader {
                    id: accountPickerHeader
                }
                AccountProviderPicker {
                    id: accountPicker
                    anchors {
                        left: parent.left
                        right: parent.right
                        top: accountPickerHeader.bottom
                    }
                    serviceFilter: accountCreationManager.serviceFilter
                    _accountManager: accountCreationManager._accountManager

                    onProviderSelected: {
                        accountCreationManager.startAccountCreationForProvider(providerName, {})
                    }
                }
                VerticalScrollDecorator {}
            }
        }
    }

    Component {
        id: networkCheckComponent
        NetworkCheckDialog { }
    }

    Component {
        id: agentRunnerComponent
        AccountAgentRunner {}
    }
}
