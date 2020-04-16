import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Item {
    id: root

    property bool running
    property AccountManager accountManager: AccountManager {}

    property var _trackedObjects: ({})

    signal credentialsUpdated(int updatedAccountId)
    signal credentialsUpdateError(string errorMessage)

    function pushCredentialsUpdatePage(accountId, endDestination) {
        _showCredentialsUpdatePage(accountId, PageStackAction.Push, endDestination)
    }

    function replaceWithCredentialsUpdatePage(accountId, endDestination) {
        _showCredentialsUpdatePage(accountId, PageStackAction.Replace, endDestination)
    }

    function _showCredentialsUpdatePage(accountId, pageStackAction, endDestination) {
        var currentPage = pageStack.currentPage
        var action = pageStackAction
        var replaceTarget = (action === PageStackAction.Replace) ? endDestination || pageStack.previousPage(currentPage) : undefined

        var credentialsUpdater = _newCredentialsUpdater()
        _trackedObjects[credentialsUpdater] = undefined
        credentialsUpdater.finished.connect(function() {
            delete _trackedObjects[credentialsUpdater]
            credentialsUpdater.destroy()
            root.running = false
        })
        credentialsUpdater.credentialsAgentReady.connect(function(credentialsAgent) {
            switch (action) {
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
                throw new Error("AccountCredentialsManager: unsupported pageStackAction!", action)
            }
        })
        credentialsUpdater.start(accountId)
        root.running = true
    }

    function _newCredentialsUpdater() {
        var updater = credentialsUpdateComponent.createObject(root)
        updater.credentialsUpdated.connect(root.credentialsUpdated)
        updater.credentialsUpdateError.connect(root.credentialsUpdateError)
        return updater
    }

    Component {
        id: credentialsUpdateComponent
        Account {
            property bool hasFinished

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
                    "accountProvider": accountManager.provider(providerName)
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

            // In reality this Component should be only used if Account has "CredentialsNeedUpdate"
            // set to true. Currently all <providerName>-settings.qml plugins and others are already
            // checking that flag. There's accountNotSignedIn in the AccountSettingsAgent.
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
}
