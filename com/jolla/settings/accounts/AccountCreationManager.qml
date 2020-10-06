/*
 * Copyright (c) 2013 - 2019 Jolla Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import Sailfish.Policy 1.0
import MeeGo.Connman 0.2
import com.jolla.settings.accounts 1.0
import org.nemomobile.configuration 1.0
import org.nemomobile.systemsettings 1.0
import Nemo.Notifications 1.0

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
    property var providerFilter: []

    signal accountCreated(int newAccountId, string providerName)
    signal accountCreationError(string errorMessage, string providerName)

    signal finished(bool success)   // success=true if all selected accounts were created, false otherwise

    property var _trackedObjects: ({})

    function startAccountCreation() {
        if (AccessPolicy.accountCreationEnabled)
            pageStack.animatorPush(accountProviderPickerComponent)
        else
            disableByMdm.publish()
    }

    function startAccountCreationForProvider(providerName, properties, pageStackOperation) {
        if (pageStackOperation === undefined) {
            pageStackOperation = PageStackAction.Animated
        }
        var agent = _accountCreationAgent(providerName, properties)
        if (hasNetworkConnectivity) {
            pageStack.animatorPush(agent.initialPage, {}, pageStackOperation)
        } else {
            var props = {
                "acceptDestination": agent.initialPage,
                "acceptDestinationAction": PageStackAction.Replace
            }
            pageStack.animatorPush(networkCheckComponent, props, {}, pageStackOperation)
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
                syncAdapter.triggerSync(accountIdentifier)
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

    ConfigurationValue {
        id: hasCreatedJollaAccountBefore
    }

    AccountSyncAdapter { id: syncAdapter }

    property AccountManager _accountManager: AccountManager {}
    property var _networkManagerFactory: NetworkManagerFactory {}
    readonly property bool hasNetworkConnectivity: _networkManagerFactory.instance.state == "online"

    Component {
        id: accountProviderPickerComponent

        Page {
            SilicaFlickable {
                anchors.fill: parent
                contentHeight: accountPickerHeader.height + accountPicker.height + Theme.paddingLarge

                PageHeader {
                    id: accountPickerHeader
                    //% "Add account"
                    title: qsTrId("settings-accounts-la-add_account")
                }

                AccountProviderPicker {
                    id: accountPicker

                    anchors {
                        left: parent.left
                        right: parent.right
                        top: accountPickerHeader.bottom
                    }
                    excludeProvidersForUncreatableAccounts: true
                    serviceFilter: accountCreationManager.serviceFilter
                    providerFilter: accountCreationManager.providerFilter

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
        NetworkCheckDialog {
        }
    }

    Component {
        id: agentRunnerComponent
        AccountAgentRunner {}
    }

    Notification {
        id: disableByMdm

        isTransient: true
        urgency: Notification.Critical
        icon: "icon-lock-warning"

        //: %1 is operating system name without OS suffix
        //% "Account creation disabled by %1 Device Manager"
        previewBody: qsTrId("settings_accounts-la-account_creation_disabled_by_device_manager").arg(aboutSettings.baseOperatingSystemName)
    }

    AboutSettings {
        id: aboutSettings
    }
}
