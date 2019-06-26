// xxxxxx for legacy versions of email and active sync plugins xxxxxx

var _accountCreationQueue = []
var _firstSelectedProviderIndex = -1
var _currentCreationIndex = -1
var _lastSelectedProviderName = ""
var _accountPicker = null

function startAccountCreation(picker) {
    if (picker === null) {
        console.log("startAccountCreation(): AccountProviderPickerDialog instance not given!")
        return
    }
    initAccountCreationQueue(picker.providerCount)
    _firstSelectedProviderIndex = -1
    _currentCreationIndex = -1
    _lastSelectedProviderName = ""
    _accountPicker = picker
    picker.providerSelected.connect(_selectedProviderToCreate)
    picker.providerDeselected.connect(_deselectedProviderToCreate)
    picker.acceptPendingChanged.connect(function() {
        if (picker.acceptPending) {
            _currentCreationIndex = -1
            _firstSelectedProviderIndex = -1
            // Set _currentCreationIndex to the first selected provider
            for (var i=0; i<_accountCreationQueue.length; i++) {
                if (_accountCreationQueue[i].providerName !== "") {
                    _currentCreationIndex = i
                    break
                }
            }
            // now set the first creation page that will be the picker's acceptDestination
            if (_currentCreationIndex >= 0) {
                _setFirstAcceptDestination(picker)
            } else {
                _resetEndDestination(picker)
            }
        }
    })
    picker.accepted.connect(function() {
        if (_currentCreationIndex >= 0) {
            for (var i=_accountCreationQueue.length-1; i>0; i--) {
                if (_accountCreationQueue[i].providerName !== "") {
                    _lastSelectedProviderName = _accountCreationQueue[i].providerName
                    break
                }
            }
        }
    })
    picker.statusChanged.connect(function() {
        if (picker.status === PageStatus.Active) {
            // initialize the acceptDestination to the endDestination
            _resetEndDestination(picker)

            // Clear the cache if user started creation process then went back to the picker page
            var wentBack = _currentCreationIndex >= 0
            if (wentBack) {
                // reset any properties that may have changed during the last creation process
                _currentCreationIndex = -1
                _firstSelectedProviderIndex = -1
                _accountPicker = picker
                for (var i=0; i<_accountCreationQueue.length; i++) {
                    if (_accountCreationQueue[i].providerName !== "") {
                        // reset _firstSelectedProviderIndex and _currentCreationIndex to the first
                        // selected provider
                        if (_currentCreationIndex < 0 && _accountCreationQueue[i].providerName !== "") {
                            _currentCreationIndex = i
                            _firstSelectedProviderIndex = i
                        }
                    }
                    destroyCachedData(_accountCreationQueue[i])
                }
                // preload the page for the first selected provider
                if (_firstSelectedProviderIndex >= 0 && accountCreationManager.hasNetworkConnectivity) {
                    _cachedCreationPage(_firstSelectedProviderIndex, {})
                }
            }
        }
    })
}

function _setFirstAcceptDestination(picker) {
    if (_currentCreationIndex < 0) {
        console.log("Error: _setFirstAcceptDestination() called without _currentCreationIndex set")
        return
    }
    picker.acceptDestination = null
    if (!accountCreationManager.hasNetworkConnectivity) {
        var comp = Qt.createComponent(Qt.resolvedUrl("NetworkCheckDialog.qml"))
        if (comp.status == Component.Ready) {
            picker.acceptDestinationAction = PageStackAction.Push
            picker.acceptDestinationProperties = {}
            picker.acceptDestinationReplaceTarget = undefined
            picker.acceptDestination = comp.createObject(accountCreationManager, {
                    "acceptDestination": _firstCachedCreationPage({}),
                    "acceptDestinationAction": PageStackAction.Replace,
                    "acceptDestinationActionProperties": ({}),
                    "acceptDestinationReplaceTarget": undefined,
                    "networkManager": accountCreationManager._networkManager
            })
        }
    }
    if (picker.acceptDestination == null) {
        picker.acceptDestinationAction = PageStackAction.Push
        picker.acceptDestinationProperties = {}
        picker.acceptDestinationReplaceTarget = undefined
        picker.acceptDestination = _firstCachedCreationPage({})
    }
}

function _resetEndDestination(obj) {
    // reset action and destination first to avoid pagestack warning about invalid combinations
    // of action + destination when the new values are set
    obj.acceptDestinationAction = PageStackAction.Push
    obj.acceptDestination = undefined

    // endDestination* properties are public, so assign these as bindings in case they change dynamically
    obj.acceptDestinationAction = Qt.binding(function() { return accountCreationManager.endDestinationAction })
    obj.acceptDestinationProperties = Qt.binding(function() { return accountCreationManager.endDestinationProperties })
    obj.acceptDestinationReplaceTarget = Qt.binding(function() { return accountCreationManager.endDestinationReplaceTarget })
    obj.acceptDestination = Qt.binding(function() { return accountCreationManager.endDestination })
}

function _setSkipToForCreationPage(creationPage, skipDestination) {
    if (skipDestination == null) {
        // This is the last creation page in the sequence
        creationPage.skipDestinationStackAction = Qt.binding(function() { return accountCreationManager.endDestinationAction })
        creationPage.skipDestinationProperties = Qt.binding(function() { return accountCreationManager.endDestinationProperties })
        creationPage.skipDestinationReplaceTarget = Qt.binding(function() { return accountCreationManager.endDestinationReplaceTarget })
        creationPage.skipDestination = Qt.binding(function() { return accountCreationManager.endDestination })
    } else {
        // enable the equivalent of replaceAbove(_accountPicker), so that if user skips this
        // account creation page and goes to the next, then swipes backwards, we go back to
        // the account picker
        creationPage.skipDestinationStackAction = PageStackAction.Replace
        creationPage.skipDestinationProperties = {}
        creationPage.skipDestinationReplaceTarget = _accountPicker
        creationPage.skipDestination = skipDestination
    }
}

function prepareAccountCreationWithProvider(providerName, properties) {
    initAccountCreationQueue(1)
    _currentCreationIndex = 0
    _firstSelectedProviderIndex = 0
    _lastSelectedProviderName = providerName

    _accountCreationQueue[0].providerName = providerName
    return _firstCachedCreationPage(properties)
}

function createAccountCreationPage(providerName, properties) {
    if (providerName === "") {
        console.log("No account provider name given!")
        return null
    }
    var provider = _accountManager.provider(providerName)
    if (!provider) {
        throw new Error("Unable to obtain provider with name: " + providerName)
    }
    var componentFileName = "/usr/share/accounts/ui/" + providerName + ".qml"
    var comp = Qt.createComponent(componentFileName)
    if (comp.status !== Component.Ready) {
        throw new Error("Unable to load account creation page "
                        + componentFileName + ": " + comp.errorString())
    }
    if (!properties.hasOwnProperty("accountProvider")) {
        properties["accountProvider"] = provider
    }
    if (!properties.hasOwnProperty("accountManager")) {
        properties["accountManager"] = _accountManager
    }
    var obj = comp.status === Component.Ready
            ? comp.createObject(accountCreationManager, properties)
            : null
    if (obj === null) {
        console.log("Error: cannot load account creation page for " + providerName)
        return null
    }
    obj.statusChanged.connect(function(){
        // Once this page becomes visible, we load its post-creation page and settings page as well
        // as the next account creation page in the sequence
        if (obj.status === PageStatus.Active) {
            if (!_providerInitialized(providerName)) {
                _setProviderInitialized(providerName, true)
                var nextCreationPageIndex = _incrementAccountCreationIndex()

                // Set the page that we move to if the user skips creating this account (this will be
                // the next creation page in the sequence, or the endDestination if there are no more pages)
                var nextAccountCreationPage = _cachedCreationPage(nextCreationPageIndex, {})
                if (nextAccountCreationPage != null) {
                    _setNextAccountCreationPage(providerName, nextAccountCreationPage)
                }
                _setSkipToForCreationPage(obj, nextAccountCreationPage)
            }
            // Create the creationBusyDialog and settings page for this account.
            if (obj.creationBusyDialog == null) {
                var settingsProperties = {
                    "accountProvider": obj.accountProvider,
                    "isNewAccount": true
                }
                obj.creationBusyDialog = _createCreationBusyDialog(providerName, settingsProperties)
            } else if (obj.creationBusyDialog.settingsPage != null) {
                 _setupSettingsPage(obj.creationBusyDialog.settingsPage, providerName)
            }
        }
    })
    obj.accountCreated.connect(function(accountId) {
        accountCreationManager.accountCreated(accountId, providerName)
    })
    obj.accountCreationError.connect(function() {
        accountCreationManager.accountCreationError(providerName)
        if (providerName === _lastSelectedProviderName) {
            accountCreationManager.finished(false)
        }
    })
    obj.rejected.connect(function() {
        accountCreationManager.finished(false)
    })
    return obj
}

function createSettingsPage(providerName, properties) {
    var componentFileName = "/usr/share/accounts/ui/" + providerName + "-settings.qml"
    var comp = Qt.createComponent(componentFileName)
    if (comp.status !== Component.Ready) {
        console.log("Loading default settings, custom settings not loadable for", providerName, ":", comp.errorString())
        comp = Qt.createComponent(Qt.resolvedUrl("StandardAccountSettingsDialog.qml"))
    }
    if (!properties.hasOwnProperty("accountManager")) {
        properties["accountManager"] = _accountManager
    }
    var obj = comp.status === Component.Ready
            ? comp.createObject(accountCreationManager, properties)
            : null
    if (obj === null) {
        console.log("Error: cannot load StandardAccountSettingsDialog.qml:", comp.errorString())
        return null
    }
    _setupSettingsPage(obj, providerName)
    return obj
}

function _setupSettingsPage(obj, providerName) {
    // If this is for a brand new account, the destination of the settings page is the account
    // creation page for the next provider in the queue
    var isLastCreationPage = false
    if (obj.isNewAccount && obj.acceptDestination == undefined) {
        obj.acceptDestination = _nextAccountCreationPage(providerName)
        if (obj.acceptDestination == null) {
            // change acceptDestination to the endDestination
            isLastCreationPage = true
            _accountPicker = null
            _resetEndDestination(obj)
        } else {
            // do the equivalent of replaceAbove(_accountPicker) so that if user swipes back from
            // the next account creation page, we return to the account picker
            obj.acceptDestinationAction = PageStackAction.Replace
            obj.acceptDestinationProperties = {}
            obj.acceptDestinationReplaceTarget = _accountPicker
        }
    }
    obj.accepted.connect(function() {
        if (obj.isNewAccount) {
            if (isLastCreationPage) {
                accountCreationManager.finished(true)
            }
        }
    })
    obj.rejected.connect(function() {
        if (obj.isNewAccount) {
            accountCreationManager.deleteAccount(obj.accountId)
            accountCreationManager.finished(false)
        }
    })
}

function clearAccountCreationQueue() {
    if (_accountCreationQueue.length === 0) {
        return
    }
    for (var i=0; i<_accountCreationQueue.length; i++) {
        destroyCachedData(_accountCreationQueue[i])
    }
    _accountCreationQueue = []
}

function destroyCachedData(data)
{
    data.initialized = false
    if (data.creationPage !== undefined) {
        data.creationPage.destroy()
        data.creationPage = undefined
    }
    if (data.creationBusyDialog !== undefined) {
        data.creationBusyDialog.destroy()
        data.creationBusyDialog = undefined
    }
    if (data.settingsPage !== undefined) {
        data.settingsPage.destroy()
        data.settingsPage = undefined
    }
    data.nextAccountCreationPage = null
}

function _selectedProviderToCreate(index, providerName) {
    // mark provider as selected
    _accountCreationQueue[index].providerName = providerName

    // Pre-emptively load the first account creation page that is selected in the dialog,
    // otherwise this loading causes a blocking delay when the picker is accepted.
    if ((_firstSelectedProviderIndex < 0 || index < _firstSelectedProviderIndex)
            && accountCreationManager.hasNetworkConnectivity) {
        _firstSelectedProviderIndex = index
        _cachedCreationPage(index, {})
    }
}

function _deselectedProviderToCreate(index, providerName) {
    // mark provider as unselected
    _accountCreationQueue[index].providerName = ""
}

function initAccountCreationQueue(initialLength) {
    if (_accountCreationQueue.length > 0) {
        clearAccountCreationQueue()
    }
    for (var i=0; i<initialLength; i++) {
        var data = {
            "initialized": false,
            "providerName": "",
            "creationPage": undefined,
            "creationBusyDialog": undefined,
            "settingsPage": undefined,
            "nextAccountCreationPage": undefined    // reference to next creation page in sequence, don't destroy!
        }
        _accountCreationQueue.push(data)
    }
}

function _providerInitialized(providerName) {
    for (var i=0; i<_accountCreationQueue.length; i++) {
        if (_accountCreationQueue[i].providerName == providerName) {
            return _accountCreationQueue[i].initialized
        }
    }
    return false
}

function _setProviderInitialized(providerName) {
    for (var i=0; i<_accountCreationQueue.length; i++) {
        if (_accountCreationQueue[i].providerName == providerName) {
            _accountCreationQueue[i].initialized = true
        }
    }
}

function _incrementAccountCreationIndex() {
    do {
        _currentCreationIndex++
    } while (_currentCreationIndex < _accountCreationQueue.length
             && _accountCreationQueue[_currentCreationIndex].providerName === "")
    return _currentCreationIndex
}

function _cachedCreationPage(index, properties) {
    if (index < 0 || index >= _accountCreationQueue.length) {
        return null
    }
    var data = _accountCreationQueue[index]
    var page = data.creationPage
    if (page === undefined) {
        page = createAccountCreationPage(data.providerName, properties)
        _accountCreationQueue[index].creationPage = page
    }
    return page
}

function _setNextAccountCreationPage(providerName, page) {
    for (var i=0; i<_accountCreationQueue.length; i++) {
        if (_accountCreationQueue[i].providerName == providerName) {
            _accountCreationQueue[i].nextAccountCreationPage = page
            break
        }
    }
}

function _nextAccountCreationPage(providerName) {
    for (var i=0; i<_accountCreationQueue.length; i++) {
        if (_accountCreationQueue[i].providerName == providerName) {
            return _accountCreationQueue[i].nextAccountCreationPage
        }
    }
    return null
}

function _createCreationBusyDialog(providerName, settingsProperties) {
    var page = null
    for (var i=0; i<_accountCreationQueue.length; i++) {
        var data = _accountCreationQueue[i]
        if (data.providerName === providerName) {
            if (data.creationBusyDialog != null) {
                data.creationBusyDialog.destroy()
            }
            var comp = Qt.createComponent(Qt.resolvedUrl("AccountCreationBusyDialog.qml"))
            if (comp.status !== Component.Ready) {
                console.log("Error: cannot load AccountCreationBusyDialog.qml!", comp.errorString())
                return null
            }
            var settingsPage = createSettingsPage(providerName, settingsProperties)
            if (_accountCreationQueue[i].settingsPage != null) {
                _accountCreationQueue[i].settingsPage.destroy()
            }
            _accountCreationQueue[i].settingsPage = settingsPage
            page = comp.createObject(accountCreationManager, {"settingsPage": settingsPage})
            _accountCreationQueue[i].creationBusyDialog = page
            break
        }
    }
    return page
}

function _firstCachedCreationPage(properties) {
    for (var i=0; i<_accountCreationQueue.length; i++) {
        var data = _accountCreationQueue[i]
        if (data.providerName !== "") {
            return _cachedCreationPage(i, properties)
        }
    }
    return null
}
