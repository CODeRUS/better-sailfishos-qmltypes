/*
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

Dialog {
    id: root

    acceptDestinationAction: PageStackAction.Push // has to be, so this page continues to live, so it can call _updateCredentials() AFTER accepted()
    acceptDestination: AccountBusyPage { // intermediate page - to handle success/errors
        busyDescription: updatingAccountText
        infoDescription: accountUpdateErrorText
    }

    property alias account: account
    property alias providerIcon: accountSummary.icon
    property alias providerName: accountSummary.accountName
    property alias accountUserName: accountSummary.userName

    property string serviceName

    property string applicationName
    property string credentialsName
    property string symmetricKey

    property bool _checkMandatoryFields

    signal credentialsUpdated(var data, int identifier)
    signal credentialsUpdateError(string message)

    function setBusyStatus(busy, description, title) {
        var busyPage = acceptDestination
        if (busy) {
            busyPage.state = 'busy'
            if (!!description) {
                busyPage.busyDescription = description
            }
        } else {
            busyPage.state = 'info'
            if (!!title) {
                busyPage.infoHeading = title
            }
            if (!!description) {
                busyPage.infoDescription = description
            }
        }
    }

    function _updateCredentials() {
        if (account.hasSignInCredentials(applicationName, credentialsName)) {
            account.updateSignInCredentials(applicationName, credentialsName,
                                            account.signInParameters(serviceName, accountUserName, passwordField.text))
        } else {
            // build account configuration map, to avoid another asynchronous state round trip.
            var configValues = { "": account.configurationValues("") }
            var serviceNames = account.supportedServiceNames
            for (var si in serviceNames) {
                configValues[serviceNames[si]] = account.configurationValues(serviceNames[si])
            }
            accountFactory.recreateAccountCredentials(account.identifier, serviceName,
                                                      accountUserName, passwordField.text,
                                                      account.signInParameters(serviceName, accountUserName, passwordField.text),
                                                      applicationName, symmetricKey, credentialsName, configValues)
        }
    }

    canAccept: passwordField.text.length > 0

    onAcceptPendingChanged: {
        if (acceptPending === true) {
            _checkMandatoryFields = true
        }
    }

    onStatusChanged: {
        // we don't do this in onAccepted(), otherwise the _updateCredentials()
        // operation might complete before the page transition is completed,
        // in which case the attempt to then transition to the final destination
        // would fail.  So, we wait until the initial transition is complete, first.
        if (status == PageStatus.Inactive && result == DialogResult.Accepted) {
            _updateCredentials()
        } else if (status == PageStatus.Active) {
            // Reset the busy page status.
            setBusyStatus(true, acceptDestination.updatingAccountText)
        }
    }

    onRejected: {
        if (account.status === Account.SigningIn) {
            account.cancelSignInOperation()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + accountSummary.height + settingsColumn.height

        DialogHeader {
            id: header

            //: Sign in to the account
            //% "Sign in"
            acceptText: qsTrId("components_accounts-he-sign_in")
        }

        AccountSummary {
            id: accountSummary
            anchors.top: header.bottom
            userName: account.defaultCredentialsUserName
        }

        Column {
            id: settingsColumn

            anchors.top: accountSummary.bottom
            width: parent.width
            spacing: Theme.paddingLarge

            Label {
                //: Shown when sigin credentials need to be refreshed
                //% "Sign in to refresh credentials"
                text: qsTrId("components_accounts-la-sign_in_to_refresh_credentials")
                wrapMode: Text.Wrap
                //font.pixelSize: Theme.fontSizeExtraLarge
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                color: Theme.secondaryHighlightColor
            }

            PasswordField {
                id: passwordField
                errorHighlight: !text && _checkMandatoryFields

                //: Placeholder text for password
                //% "Enter password"
                placeholderText: qsTrId("components_accounts-ph-enter_new_password")

                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: root.focus = true
            }
        }
    }

    AccountFactory {
        id: accountFactory

        // For recreateAccountCredentials path
        onError: {
            var busyPage = acceptDestination
            root.setBusyStatus(false, busyPage.accountUpdateErrorText, busyPage.errorHeadingText)
            root.credentialsUpdateError(message)
        }
        onSuccess: root.credentialsUpdated(responseData, account.identifier)
    }

    Account {
        id: account

        // For updateSignInCredentials path
        onSignInCredentialsUpdated: root.credentialsUpdated(data, account.identifier)

        onSignInError: {
            var busyPage = acceptDestination
            root.setBusyStatus(false, busyPage.accountUpdateErrorText, busyPage.errorHeadingText)
            root.credentialsUpdateError(message)
        }
    }
}
