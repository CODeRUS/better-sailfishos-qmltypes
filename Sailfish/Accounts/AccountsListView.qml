import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

SilicaListView {
    id: root

    //-------------- api

    property alias filterType: accountModel.filterType
    property alias filter: accountModel.filter
    property bool entriesInteractive

    signal accountClicked(int accountId, string providerName)
    signal accountRemoveRequested(int accountId)
    signal accountSyncRequested(int accountId)

    //-------------- impl

    property bool _hideJollaAccount

    model: AccountModel { id: accountModel }

    delegate: ListItem {
        id: delegateItem

        enabled: root.entriesInteractive
        contentHeight: visible ? Theme.itemSizeMedium : 0
        visible: !root._hideJollaAccount || model.providerName !== "jolla"
        menu: root.entriesInteractive ? menuComponent : null

        Component {
            id: menuComponent

            ContextMenu {
                MenuItem {
                    visible: model.providerName !== "jolla"
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
                    //: Removes a user account
                    //% "Remove"
                    text: qsTrId("components_accounts-me-remove_account")
                    onClicked: removeAccount()
                }

                MenuItem {
                    //: Syncs the data for this account
                    //% "Sync"
                    text: qsTrId("components_accounts-me-sync")
                    visible: model.accountEnabled
                            && (model.providerName === "activesync" || accountSyncManager.profileIds(model.accountId).length > 0)

                    onClicked: {
                        root.accountSyncRequested(model.accountId)
                    }
                }
            }
        }

        function removeAccount() {
            //: Deleting this account in 5 seconds
            //% "Removing account"
            remorseAction(qsTrId("component_accounts-la-remove_account"),
                          function() { root.accountRemoveRequested(model.accountId) })

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
            size: BusyIndicatorSize.Medium
            width: sourceSize.width * .75
            height: width
            running: model.performingInitialSync && model.accountError === AccountModel.NoAccountError
        }
        Label {
            id: accountName
            anchors {
                left: icon.right
                leftMargin: Theme.paddingLarge
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
                verticalCenterOffset: accountUserName.text === "" ? 0 : -implicitHeight/2
            }
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
            anchors {
                left: icon.right
                leftMargin: Theme.paddingLarge
                top: accountName.bottom
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
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

        onClicked: {
            root.accountClicked(model.accountId, model.providerName)
        }
    }

    AccountSyncManager {
        id: accountSyncManager
    }

    AccountManager { id: accountManager }
    VerticalScrollDecorator {}
}
