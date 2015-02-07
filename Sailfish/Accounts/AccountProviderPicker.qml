import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0

Column {
    id: root

    property alias serviceFilter: providerModel.serviceFilter

    signal providerSelected(int index, string providerName)
    signal providerDeselected(int index, string providerName)   // deprecated

    //--- end of public api

    property AccountManager _accountManager: AccountManager {}
    property bool _hasExistingJollaAccount

    function _isOtherProvider(providerName) {
        return providerName.indexOf("email") == 0
            || providerName.indexOf("onlinesync") == 0
    }

    Component.onCompleted: {
        root._hasExistingJollaAccount = (_accountManager.providerAccountIdentifiers("jolla").length > 0)
    }

    Connections {
        target: root._accountManager
        onAccountCreated: {
            if (!root._hasExistingJollaAccount) {
                var account = _accountManager.account(accountId)
                if (account && account.providerName === "jolla") {
                    root._hasExistingJollaAccount = true
                }
            }
        }
    }

    ProviderModel {
        id: providerModel
    }

    Column {
        width: root.width

        Repeater {
            model: providerModel
            delegate: AccountProviderPickerDelegate {
                width: root.width
                // don't offer the chance to create multiple jolla accounts through the UI
                visible: !root._isOtherProvider(model.providerName)
                         && (model.providerName !== "jolla" || !root._hasExistingJollaAccount)
            }
        }
    }

    SectionHeader {
        //: List of other types of account providers
        //% "Other"
        text: qsTrId("components_accounts-la-other")
    }

    Column {
        width: root.width

        Repeater {
            model: providerModel
            delegate: AccountProviderPickerDelegate {
                width: root.width
                visible: root._isOtherProvider(model.providerName)
            }
        }
    }
}
