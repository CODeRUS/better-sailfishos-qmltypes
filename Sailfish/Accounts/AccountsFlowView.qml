import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

Flow {
    id: root

    //-------------- api

    property alias filterType: accountModel.filterType
    property alias filter: accountModel.filter
    property alias model: accountModel
    property bool entriesInteractive
    property real itemWidth: width

    signal accountClicked(int accountId, string providerName)
    signal accountRemoveRequested(int accountId)
    signal accountSyncRequested(int accountId)

    //-------------- impl

    property bool _hideJollaAccount

    // We don't want the height to change when the Page is hidden, so
    // latch the height when visible
    property real _visibleHeight
    onImplicitHeightChanged: if (visible) _visibleHeight = implicitHeight
    height: _visibleHeight

    Repeater {
        model: AccountModel { id: accountModel }

        delegate: AccountsListDelegate {
            id: delegateItem

            width: root.itemWidth

            enabled: root.entriesInteractive
            visible: !root._hideJollaAccount || model.providerName !== "jolla"
            entriesInteractive: root.entriesInteractive

            onAccountSyncRequested: root.accountSyncRequested(accountId)
            onAccountRemoveRequested: root.accountRemoveRequested(accountId)
            onAccountClicked: root.accountClicked(accountId, providerName)
        }
    }

    AccountSyncManager {
        id: accountSyncManager
    }

    AccountManager { id: accountManager }
    VerticalScrollDecorator {}
}
