import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import MeeGo.Connman 0.2
import com.jolla.settings.accounts 1.0

Item {
    id: root

    property bool running
    property AccountManager accountManager: AccountManager {}

    property var _trackedObjects: ({})

    signal credentialsUpdated(int updatedAccountId)
    signal credentialsUpdateError(string errorMessage)

    function showCredentialsPromptDialog(providerName, accountId, endDestination) {
        var props = {
            "providerName" : providerName,
            "accountId": accountId,
            "endDestination": endDestination,
            "endDestinationReplaceTarget": pageStack.currentPage
        }
        var credentialsPromptDialog = credentialsPromptDialogComponent.createObject(root, props)
        _trackedObjects[credentialsPromptDialog] = undefined
        credentialsPromptDialog.finished.connect(function() {
            delete _trackedObjects[credentialsPromptDialog]
            credentialsPromptDialog.destroy()
            root.running = false
        })
        credentialsPromptDialog.credentialsUpdated.connect(credentialsUpdated)
        pageStack.animatorPush(credentialsPromptDialog)
        root.running = true
    }

    function pushCredentialsUpdatePage(accountId, userName) {
        _showCredentialsUpdatePage(accountId, userName, PageStackAction.Push)
    }
    function replaceWithCredentialsUpdatePage(accountId) {
        _showCredentialsUpdatePage(accountId, "", PageStackAction.Replace)
    }

    function _showCredentialsUpdatePage(accountId, userName, pageStackAction) {
        var currentPage = pageStack.currentPage
        var replaceTarget = PageStackAction.Replace ? pageStack.previousPage(currentPage) : undefined
        var credentialsUpdater = _newCredentialsUpdater(userName)
        _trackedObjects[credentialsUpdater] = undefined
        credentialsUpdater.finished.connect(function() {
            delete _trackedObjects[credentialsUpdater]
            credentialsUpdater.destroy()
            root.running = false
        })
        credentialsUpdater.credentialsAgentReady.connect(function(credentialsAgent) {
            switch (pageStackAction) {
            case PageStackAction.Push:
                credentialsAgent.endDestination = currentPage
                credentialsAgent.endDestinationAction = PageStackAction.Pop
                credentialsAgent.endDestinationProperties = {}
                credentialsAgent.endDestinationReplaceTarget = undefined
                pageStack.animatorPush(credentialsAgent.initialPage)
                break
            case PageStackAction.Replace:
                credentialsAgent.endDestination = currentPage
                credentialsAgent.endDestinationAction = PageStackAction.Replace
                credentialsAgent.endDestinationProperties = {}
                credentialsAgent.endDestinationReplaceTarget = replaceTarget
                pageStack.animatorReplaceAbove(replaceTarget, credentialsAgent.initialPage)
                break
            default:
                throw new Error("AccountCredentialsManager: unsupported pageStackAction!", pageStackAction)
            }
        })
        credentialsUpdater.start(accountId)
        root.running = true
    }

    function _newCredentialsUpdater(userName) {
        var updater = credentialsUpdateComponent.createObject(root, { "userName": userName })
        updater.credentialsUpdated.connect(root.credentialsUpdated)
        updater.credentialsUpdateError.connect(root.credentialsUpdateError)
        return updater
    }

    property NetworkManager _networkManager: NetworkManager {}

    Component {
        id: credentialsUpdateComponent
        Account {
            property bool hasFinished
            property string userName

            property var _credentialsAgentRunner
            property bool _saving
            property bool _emitFinishedWhenSaved
            property bool _savingAfterCredentialsUpdated
            property bool _settingInitialCredentialsFlag
            property bool _reloadingPriorToLoweringCnuFlag

            signal credentialsAgentReady(var credentialsAgent)
            signal credentialsUpdated(int accountId)
            signal credentialsUpdateError(string errorMessage)
            signal finished()

            function start(accountId) {
                identifier = accountId
            }

            function _setCredentialsNeedUpdateFlag(needUpdate) {
                // set in the global service
                var allServiceNames = supportedServiceNames
                if (allServiceNames.length > 0) {
                    setConfigurationValue("", "CredentialsNeedUpdate", needUpdate)
                    // set the value on a per-service setting
                    var serviceName = allServiceNames[0]
                    setConfigurationValue(serviceName, "CredentialsNeedUpdate", needUpdate)
                    setConfigurationValue(serviceName, "CredentialsNeedUpdateFrom", "jolla-settings")
                    _saving = true
                    sync()
                }
            }

            function _credentialsUpdated(accountId) {
                if (accountId == identifier) {
                    // Set CredentialsNeedUpdate=false now that the new credentials have been set.
                    // Note that the update may have caused changes to the account, so first we
                    // need to reload the account.
                    _reloadingPriorToLoweringCnuFlag = true
                    identifier = 0
                    identifier = accountId
                } else {
                    // The updated account id is different from the original. This means the old
                    // account is no longer relevant and it's not necessary to set the credentials
                    // update flag, so just finish now.
                    credentialsUpdated(accountId)
                    _finish()
                }
            }

            function _finish() {
                if (_saving) {
                    _emitFinishedWhenSaved = true
                } else {
                    hasFinished = true
                    finished()
                }
            }

            function _loadCredentialsAgent() {
                if (_credentialsAgentRunner != null) {
                    return
                }
                var agentProperties = {
                    "accountManager": accountManager,
                    "accountProvider": accountManager.provider(providerName),
                    "userName": userName
                }
                if (agentProperties["accountProvider"] == null) {
                    throw new Error("Unable to obtain provider with name: " + providerName)
                }
                var runnerProperties = {
                    "agentComponentFileName": "/usr/share/accounts/ui/" + providerName + "-update.qml",
                    "agentProperties": agentProperties
                }
                _credentialsAgentRunner = agentRunnerComponent.createObject(root, runnerProperties)
                _credentialsAgentRunner.finished.connect(_finish)
                _credentialsAgentRunner.agent.credentialsUpdated.connect(_credentialsUpdated)
                _credentialsAgentRunner.agent.credentialsUpdateError.connect(credentialsUpdateError)
            }

            function _emitCredentialsReady() {
                _credentialsAgentRunner.agent.accountId = identifier
                credentialsAgentReady(_credentialsAgentRunner.agent)
            }

            onStatusChanged: {
                if (identifier == 0) {
                    return
                }
                if (status == Account.Initialized) {
                    if (_reloadingPriorToLoweringCnuFlag) {
                        _savingAfterCredentialsUpdated = true
                        _setCredentialsNeedUpdateFlag(false)
                        return
                    }
                    _loadCredentialsAgent()
                    var credentialsFlagAlreadySet = (configurationValues("")["CredentialsNeedUpdate"] === true)
                    if (_credentialsAgentRunner.agent.canCancelUpdate
                            || credentialsFlagAlreadySet) {
                        // credentials flag doesn't need to be set to true
                        _emitCredentialsReady()
                    } else {
                        // credentials update is irreversible, so the CredentialsNeedsUpdate flag
                        // must be cleared before the credentials agent page is shown, so that
                        // this flag is saved if the user cancels the update
                        _settingInitialCredentialsFlag = true
                        _setCredentialsNeedUpdateFlag(true)
                    }
                } else if (status == Account.Synced) {
                    if (_settingInitialCredentialsFlag) {
                        _settingInitialCredentialsFlag = false
                        _emitCredentialsReady()
                    }
                    if (_savingAfterCredentialsUpdated) {
                        _savingAfterCredentialsUpdated = false
                        credentialsUpdated(identifier)
                    }
                }
                if (_saving && status != Account.SyncInProgress) {
                    _saving = false
                    if (_emitFinishedWhenSaved) {
                        _emitFinishedWhenSaved = false
                        hasFinished = true
                        finished()
                    }
                }
            }
        }
    }

    Component {
        id: agentRunnerComponent
        AccountAgentRunner {}
    }

    Component {
        id: credentialsPromptDialogComponent
        Dialog {
            property string providerName
            property int accountId
            property var endDestination
            property var endDestinationReplaceTarget

            property Provider _provider: accountManager.provider(providerName)
            property var _credentialsUpdater

            signal credentialsUpdated(int updatedAccountId)
            signal finished()

            function _checkFinished() {
                if (_credentialsUpdater != null && _credentialsUpdater.hasFinished
                        && pageContainer == null) {
                    finished()
                }
            }

            function _credentialsAgentReady(credentialsAgent) {
                credentialsAgent.endDestination = endDestination
                credentialsAgent.endDestinationAction = PageStackAction.Replace
                credentialsAgent.endDestinationProperties = {}
                credentialsAgent.endDestinationReplaceTarget = endDestinationReplaceTarget

                if (_networkManager.state == "online") {
                    acceptDestination = credentialsAgent.initialPage
                } else {
                    acceptDestination = networkCheckComponent
                    acceptDestinationProperties = {
                        "acceptDestination": credentialsAgent.initialPage,
                        "acceptDestinationAction": PageStackAction.Replace
                    }
                }
            }

            onPageContainerChanged: {
                _checkFinished()
            }

            Component.onCompleted: {
                _credentialsUpdater = _newCredentialsUpdater(accountId)
                _credentialsUpdater.credentialsUpdated.connect(credentialsUpdated)
                _credentialsUpdater.finished.connect(_checkFinished)
                _credentialsUpdater.credentialsAgentReady.connect(_credentialsAgentReady)
                _credentialsUpdater.start(accountId)
            }

            DialogHeader {
                id: header
                //: Sign in to the account
                //% "Sign in"
                acceptText: qsTrId("settings_accounts-he-sign_in")
            }

            Column {
                anchors {
                    top: header.bottom
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                    right: parent.right
                    rightMargin: Theme.horizontalPageMargin
                }
                spacing: Theme.paddingLarge

                Label {
                    //: User needs to sign in to account
                    //% "Not signed in"
                    text: qsTrId("settings_accounts-he-not_signed_in")
                    font.pixelSize: Theme.fontSizeExtraLarge
                    width: parent.width
                    wrapMode: Text.Wrap
                    color: Theme.highlightColor
                }

                Label {
                    //: User needs to sign in to account to update the account credentials
                    //% "Sign in now to update your credentials for this account."
                    text: qsTrId("settings_accounts-la-sign_in_now_to_update_credentials")
                    font.pixelSize: Theme.fontSizeSmall
                    width: parent.width
                    height: implicitHeight + Theme.paddingMedium
                    wrapMode: Text.Wrap
                    color: Theme.rgba(Theme.highlightColor, 0.9)
                }

                Item {
                    width: parent.width
                    height: icon.height

                    AccountIcon {
                        id: icon
                        source: _provider.iconName
                    }
                    Label {
                        id: accountName
                        anchors {
                            left: icon.right
                            leftMargin: Theme.paddingLarge
                            right: parent.right
                            rightMargin: Theme.horizontalPageMargin
                            verticalCenter: parent.verticalCenter
                            verticalCenterOffset: -implicitHeight/2
                        }
                        truncationMode: TruncationMode.Fade
                        text: _provider.displayName
                        color: Theme.highlightColor
                    }
                    Label {
                        anchors {
                            left: icon.right
                            leftMargin: Theme.paddingLarge
                            top: accountName.bottom
                            right: parent.right
                        }
                        truncationMode: TruncationMode.Fade
                        text: _credentialsUpdater.displayName
                        color: Theme.secondaryHighlightColor
                    }
                }
            }
        }
    }

    Component {
        id: networkCheckComponent
        NetworkCheckDialog {
            networkManager: root._networkManager
        }
    }
}
