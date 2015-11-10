import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

Page {
    id: root

    AccountsViewLogic {
        id: logic
        accountsPage: root
        title: header.title
        model: accountsView.model
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: accountsView.y + accountsView.height

        VerticalScrollDecorator {}

        PageHeader {
            id: header
            //: Heading of the main Accounts page
            //% "Accounts"
            title: qsTrId("settings_accounts-he-page_accounts")
        }

        AccountsFlowView {
            id: accountsView

            y: header.height
            width: parent.width
            itemWidth: Screen.sizeCategory >= Screen.Large ? width/2 : width
            entriesInteractive: true

            onAccountClicked: logic.accountClicked(accountId, providerName)
            onAccountRemoveRequested: logic.accountRemoveRequested(accountId)
            onAccountSyncRequested: logic.accountSyncRequested(accountId)

            BackgroundItem {
                id: addItem
                width: accountsView.itemWidth
                height: Theme.itemSizeMedium
                onClicked: logic.accountCreationManager.startAccountCreation()
                Image {
                    id: icon
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-add" + (addItem.highlighted ? "?" + Theme.highlightColor : "")
                }
                Label {
                    id: label
                    //: Initiates adding a new account
                    //% "Add account"
                    text: qsTrId("components_accounts-me-add_account")
                    truncationMode: TruncationMode.Fade
                    color: addItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                    anchors {
                        left: icon.right
                        leftMargin: Theme.paddingLarge
                        verticalCenter: parent.verticalCenter
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                    }
                }
            }

            ViewPlaceholder {
                enabled: accountsView.count == 0

                //% "No accounts"
                text: qsTrId("components_accounts-he-no_accounts")
            }
        }
    }
}
