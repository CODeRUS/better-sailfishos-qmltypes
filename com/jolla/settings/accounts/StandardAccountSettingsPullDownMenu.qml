import QtQuick 2.0
import Sailfish.Silica 1.0

PullDownMenu {
    id: root

    property bool allowCredentialsUpdate: true
    property bool allowSync: true

    signal credentialsUpdateRequested
    signal accountDeletionRequested
    signal syncRequested

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
