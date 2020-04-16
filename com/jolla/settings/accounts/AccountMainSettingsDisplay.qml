import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import org.nemomobile.systemsettings 1.0

Item {
    id: root

    property Provider accountProvider
    property bool accountEnabled
    property bool accountEnabledReadOnly
    property bool accountIsProvisioned
    property alias accountUserName: accountSummary.userName
    property alias accountDisplayName: accountDisplayNameField.text
    property var nextFocusItem

    AboutSettings {
        id: aboutSettings
    }

    property bool _changingAccountStatus

    width: parent.width
    height: accountSummary.height
            + statusCombo.height
            + statusCombo.anchors.topMargin
            + accountDisplayNameField.height
            + Theme.paddingLarge

    onAccountEnabledChanged: {
        if (!_changingAccountStatus) {
            statusCombo.currentIndex = accountEnabled ? 0 : 1
        }
    }

    Component.onCompleted: {
        statusCombo.currentIndex = accountEnabled ? 0 : 1
    }

    function _changeAccountStatus(enableAccount) {
        _changingAccountStatus = true
        accountEnabled = enableAccount
        _changingAccountStatus = false
    }

    AccountSummary {
        id: accountSummary

        icon: root.accountProvider.iconName
        accountName:  root.accountProvider.displayName
    }

    ComboBox {
        id: statusCombo
        anchors.top: accountSummary.bottom
        enabled: !root.accountEnabledReadOnly
        description: {
            if (root.accountIsProvisioned && root.accountEnabledReadOnly) {
                if (accountEnabled) {
                    //: Indicates that the account is currently enabled by MDM
                    //: %1 is an operating system name without the OS suffix
                    //% "Enabled by %1 Device Manager"
                    return qsTrId("settings-accounts-la-account_enabled_by_mdm")
                        .arg(aboutSettings.baseOperatingSystemName)
                } else {
                    //: Indicates that the account is currently disabled by MDM
                    //: %1 is an operating system name without the OS suffix
                    //% "Disabled by %1 Device Manager"
                    return qsTrId("settings-accounts-la-account_disabled_by_mdm")
                        .arg(aboutSettings.baseOperatingSystemName)
                }
            } else {
                return ""
            }
        }

        //: Indicates whether the account is currently enabled
        //% "Account status"
        label: qsTrId("settings-accounts-me-account_status")

        menu: ContextMenu {
            MenuItem {
                //: Indicates the account is currently enabled and active
                //% "Active"
                text: qsTrId("settings-accounts-me-account_active")
                onClicked: root._changeAccountStatus(true)
            }
            MenuItem {
                //: Indicates the account is currently not enabled
                //% "Disabled"
                text: qsTrId("settings-accounts-me-account_disabled")
                onClicked: root._changeAccountStatus(false)
            }
        }
    }

    TextField {
        id: accountDisplayNameField
        anchors.top: statusCombo.bottom
        width: parent.width

        //: Short name or summary for a user account
        //% "Description"
        label: qsTrId("components_accounts-la-account_description")
        placeholderText: label

        EnterKey.iconSource: !!root.nextFocusItem
                             ? "image://theme/icon-m-enter-next"
                             : "image://theme/icon-m-enter-close"
        EnterKey.onClicked: {
            if (!!root.nextFocusItem) {
                root.nextFocusItem.focus = true
            } else {
                root.focus = true
            }
        }
    }
}
