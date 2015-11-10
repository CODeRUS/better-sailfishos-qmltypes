import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

AccountBusyPage {
    id: root

    /*
      The prepareAccount[...] methods arguments require these signon details:
        - signonSessionData (map) - session parameters containing ClientId/ClientKey, ConsumerKey/ConsumerSecret, etc
        - signonServiceName (string) - Which service should be signed onto by default
    */

    signal accountCreated(int accountId, var responseData)
    signal accountCreationError(string errorMessage)

    signal accountCredentialsUpdated(int accountId, var responseData)
    signal accountCredentialsUpdateError(string errorMessage)

    function prepareAccountCreation(accountProvider, signonServiceName, signonSessionData) {
        if (_busy) {
            console.log("OAuthAccountSetupPage: operation in progress")
            return
        }
        _busy = true

        // trigger signon / account creation
        var params = _prepareSignonParams(signonSessionData)
        accountFactory.createOAuthAccount(accountProvider.name, signonServiceName, params, "Jolla", "Jolla")
        webViewLoadedTimer.start()
    }

    function prepareAccountCredentialsUpdate(account, accountProvider, signonServiceName, signonSessionData) {
        if (_busy) {
            console.log("OAuthAccountSetupPage: operation in progress")
            return
        }
        _busy = true
        _accountToUpdate = account
        _recreatingCredentials = !account.hasSignInCredentials("Jolla", "Jolla")

        // update/create will trigger oauth web view
        if (_recreatingCredentials) {
            // the account somehow lost its credentials (perhaps due to fault during backup/restore)
            console.log("Account has no credentials specified - triggering recreation instead of update")
            // build account configuration map, to avoid another asynchronous state round trip.
            var configValues = { "": account.configurationValues("") }
            var serviceNames = account.supportedServiceNames
            for (var si in serviceNames) {
                configValues[serviceNames[si]] = account.configurationValues(serviceNames[si])
            }

            var params = _prepareSignonParams(signonSessionData)
            accountFactory.recreateOAuthAccountCredentials(account.identifier, signonServiceName,
                                                           params, "Jolla", "Jolla", configValues)
        } else {
            // set up our sign in parameters
            var sip = account.signInParameters(signonServiceName)
            for (var i in signonSessionData) {
                sip.setParameter(i, signonSessionData[i])
            }

            // also ensure that we set up embedding / etc correctly:
            if (typeof jolla_signon_ui_service !== "undefined") {
                sip.setParameter("Title", accountProvider.displayName)
                sip.setParameter("InProcessServiceName", jolla_signon_ui_service.inProcessServiceName)
                sip.setParameter("InProcessObjectPath", jolla_signon_ui_service.inProcessObjectPath)
                jolla_signon_ui_service.inProcessParent = webViewContainer
            }

            account.signInCredentialsUpdated.connect(_accountUpdateSucceeded)
            account.signInError.connect(_accountUpdateFailed)
            account.updateSignInCredentials("Jolla", "Jolla", sip)
        }

        webViewLoadedTimer.start()
    }

    function cancelSignIn() {
        if (_busy) {
            if (_accountToUpdate != null && _recreatingCredentials == false) {
                _accountToUpdate.cancelSignInOperation()
            } else {
                accountFactory.cancel()
            }
        }
    }

    function done(success, errorCode, errorMessage) {
        if (success) {
            backNavigation = false
        } else {
            backNavigation = true
        }
        if (errorCode !== undefined) {
            console.log("OAuth account creation error:", errorCode, errorMessage)
            if (errorCode !== AccountFactory.UnknownError && errorCode !== AccountFactory.InternalError) {
                if (errorMessage.length) {
                    infoDescription = errorMessage
                }
            }
            if (_accountToUpdate != null) {
                //% "The account credentials could not be updated."
                infoDescription = qsTrId("components_accounts-la-account_credentials_update_error")
                infoExtraDescription = ""
                infoButtonText = ""
            }
            state = "info"
        }
        if (_accountToUpdate != null) {
            _accountToUpdate.signInCredentialsUpdated.disconnect(_accountUpdateSucceeded)
            _accountToUpdate.signInError.disconnect(_accountUpdateFailed)
            _accountToUpdate = null
        }
        _recreatingCredentials = false
        _busy = false
    }

    //--------------------------------

    property bool _busy
    property Account _accountToUpdate
    property bool _recreatingCredentials

    function _accountUpdateSucceeded(data) {
        var accountId = _accountToUpdate.identifier
        done(true)
        accountCredentialsUpdated(accountId, data)
    }

    function _accountUpdateFailed(message, errorType) {
        console.log("OAuthAccountSetupPage: account update failed:", errorType, message)
        done(false, errorType, message)
        accountCredentialsUpdateError(message)
    }

    function _prepareSignonParams(signonSessionData) {
        // pass through the signon session data from the extension ui
        var params = {}
        for (var i in signonSessionData) {
            params[i] = signonSessionData[i]
        }

        // also ensure that we set up embedding / etc correctly:
        if (typeof jolla_signon_ui_service !== "undefined") {
            params["Title"] = accountProvider.displayName
            params["InProcessServiceName"] = jolla_signon_ui_service.inProcessServiceName
            params["InProcessObjectPath"] = jolla_signon_ui_service.inProcessObjectPath
            jolla_signon_ui_service.inProcessParent = webViewContainer
        }

        return params
    }

    backNavigation: true

    // Default to empty state to hide busy spinner. Without this, in landscape mode with the VKB
    // shown the busy spinner becomes visible as it is no longer hidden by webViewContainer.
    state: ""

    //: Message displayed while waiting for authentication process to load
    //% "Loading..."
    busyDescription: qsTrId("components_accounts-la-oauth_loading")

    Timer {
        id: webViewLoadedTimer
        interval: 5000
        onTriggered: {
            if (_accountToUpdate != null) {
                //: Message displayed while updating account details
                //% "Updating account..."
                root.busyDescription = qsTrId("components_accounts-la-updating_account")
            } else {
                root.busyDescription = root.creatingAccountText
            }
        }
    }

    AccountFactory {
        id: accountFactory
        onSuccess: {
            if (root._recreatingCredentials) {
                root.done(true)
                root._accountUpdateSucceeded(responseData)
            } else {
                root.done(true)
                root.accountCreated(newAccountId, responseData)
            }
        }
        onError: {
            if (root._recreatingCredentials) {
                root.done(false, errorCode, message)
                root._accountUpdateFailed(message, errorCode)
            } else {
                root.done(false, errorCode, message)
                root.accountCreationError(message)
            }
        }
    }

    PageHeader {
        id: pageHeader
    }

    Item {
        id: webViewContainer
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        // Ensure that the busy spinner is hidden when there are children of webViewContainer. This
        // prevents it from becoming visible when the VKB is shown.
        onChildrenChanged: root.state = (children.length === 0) ? "busy" : ""
    }
}
