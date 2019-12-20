import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

ListItem {
    id: delegateItem
    property bool entriesInteractive
    property bool allowRemoveOnly

    signal accountRemoveRequested(int accountId)
    signal accountSyncRequested(int accountId)
    signal accountClicked(int accountId, string providerName)

    contentHeight: visible ? Math.max(Theme.itemSizeMedium, column.height + 2*Theme.paddingSmall) : 0
    menu: entriesInteractive ? menuComponent : null

    Component {
        id: menuComponent

        ContextMenu {
            MenuLabel {
                //: Displayed if the account is read-only
                //% "Account is read-only"
                text: qsTrId("components_accounts-la-account_read_only")
                visible: model.accountReadOnly
            }
            MenuItem {
                visible: model.providerName !== "jolla" && !model.accountReadOnly && !delegateItem.allowRemoveOnly
                text: model.accountEnabled
                        //: Disables a user account
                        //% "Disable"
                      ? qsTrId("components_accounts-me-disable")
                        //: Enables a user account
                        //% "Enable"
                      : qsTrId("components_accounts-me-enable")
                onClicked: {
                    accountModel.setAccountEnabled(model.accountId, !accountEnabled)
                }
            }

            MenuItem {
                visible: !model.accountReadOnly
                //: Deletes a user account
                //% "Delete"
                text: qsTrId("components_accounts-me-delete_account")
                onClicked: removeAccount()
            }

            MenuItem {
                //: Syncs the data for this account
                //% "Sync"
                text: qsTrId("components_accounts-me-sync")
                visible: model.accountEnabled
                        && (model.providerName === "activesync" || accountSyncManager.profileIds(model.accountId).length > 0)
                        && !delegateItem.allowRemoveOnly

                onClicked: {
                    delegateItem.accountSyncRequested(model.accountId)
                }
            }
        }
    }

    function removeAccount() {
        remorseDelete(function() { delegateItem.accountRemoveRequested(model.accountId) })
    }

    ListView.onRemove: animateRemoval()

    Binding {
        target: icon
        property: "opacity"
        when: !delegateItem.highlighted // don't change the opacity while the context menu is open
        value: model.accountEnabled && !syncIndicator.running ? 1.0 : 0.3
    }

    AccountIcon {
        id: icon
        x: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        source: model.accountIcon
    }
    BusyIndicator {
        id: syncIndicator
        anchors.centerIn: icon
        size: BusyIndicatorSize.Small
        height: width
        running: model.performingInitialSync && model.accountError === AccountModel.NoAccountError
    }
    Column {
        id: column
        anchors {
            left: icon.right
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        Label {
            id: accountName

            width: parent.width
            truncationMode: TruncationMode.Fade
            text: model.accountDisplayName
            color: {
                if (highlighted || model.accountError !== AccountModel.NoAccountError) {
                    return Theme.highlightColor
                }
                return model.accountEnabled
                        ? Theme.primaryColor
                        : Theme.rgba(Theme.primaryColor, 0.55)
            }
        }
        Label {
            id: accountUserName
            width: parent.width
            visible: text.length > 0
            truncationMode: TruncationMode.Fade
            text: {
                if (model.accountError === AccountModel.AccountNotSignedInError) {
                    //: The user has not logged into this account and needs to do so
                    //% "Not signed in"
                    return qsTrId("component_accounts-la-not_signed_in")
                }
                if (model.performingInitialSync) {
                    //: In the process of setting up this account
                    //% "Setting up account..."
                    return qsTrId("component_accounts-la-setting_up_account")
                }
                return model.accountUserName
            }
            color: {
                if (highlighted || model.accountError !== AccountModel.NoAccountError) {
                    return Theme.secondaryHighlightColor
                }
                return model.accountEnabled
                        ? Theme.secondaryColor
                        : Theme.rgba(Theme.secondaryColor, 0.3)
            }
        }
    }

    onClicked: {
        if (allowRemoveOnly) {
            openMenu()
        } else {
            delegateItem.accountClicked(model.accountId, model.providerName)
        }
    }
}
