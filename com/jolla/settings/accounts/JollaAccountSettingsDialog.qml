import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import com.jolla.settings.accounts 1.0

// Required for compatibility with jolla-store implementation.
// It requires a dialog with these properties:
//    - accountProvider
//    - accountManager
//    - isNewAccount
//    - accountId

Dialog {
    id: root

    property Provider accountProvider
    property AccountManager accountManager
    property bool isNewAccount
    property alias accountId: settingsDisplay.accountId

    // for AccountCreationBusyDialog
    property bool __sailfish_account_settings_dialog

    backNavigation: false

    onAccepted: {
        settingsDisplay.saveAccount()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + settingsDisplay.height + Theme.paddingLarge

        DialogHeader {
            id: header
        }

        JollaAccountSettingsDisplay {
            id: settingsDisplay
            anchors.top: header.bottom
            accountProvider: root.accountProvider
            accountManager: root.accountManager
            accountEnabledReadOnly: true
            autoEnableAccount: true
        }
    }
}
