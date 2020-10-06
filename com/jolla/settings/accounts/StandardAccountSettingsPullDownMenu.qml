import QtQuick 2.0
import Sailfish.Silica 1.0

PullDownMenu {
    id: root

    property bool allowCredentialsUpdate: true
    property bool allowSync: true
    property bool allowDelete: true
    property bool allowDeleteLimited: true

    signal credentialsUpdateRequested
    signal accountDeletionRequested
    signal syncRequested

    MenuLabel {
        //: Displayed if the account is read-only
        //% "Account is read-only"
        text: qsTrId("accounts-la-account_read_only")
        visible: !root.allowDelete
    }

    MenuLabel {
        //: Displayed if the account is limited
        //% "Changes to account are limited"
        text: qsTrId("accounts-la-account_limited")
        visible: !root.allowDeleteLimited
    }

    MenuItem {
        //: Updates account log-in details
        //% "Update log-in details"
        text: qsTrId("accounts-me-update_credentials")
        visible: root.allowCredentialsUpdate
        onClicked: {
            credentialsUpdateRequested()
        }
    }

    MenuItem {
        //: Deletes the account
        //% "Delete account"
        text: qsTrId("accounts-me-delete_account")
        visible: root.allowDelete && root.allowDeleteLimited
        onClicked: {
            accountDeletionRequested()
        }
    }

    MenuItem {
        //: Syncs the data for this account
        //% "Sync"
        text: qsTrId("accounts-me-sync")
        visible: root.allowSync
        onClicked: {
            syncRequested()
        }
    }
}
