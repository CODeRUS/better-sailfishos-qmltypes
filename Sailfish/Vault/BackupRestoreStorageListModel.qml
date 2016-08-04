import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import org.nemomobile.systemsettings 1.0

ListModel {
    id: root

    readonly property int storageTypeInvalid: 0
    readonly property int storageTypeMemoryCard: 1
    readonly property int storageTypeCloud: 2
    property bool ready

    property AccountModel cloudAccountModel: AccountModel {
        filterType: AccountModel.ServiceTypeFilter
        filter: "storage"
    }

    function refresh() {
        ready = false
        clear()
        _addCloudAccounts()
        _addDrives()
        ready = true
    }


    property AboutSettings _aboutSettings: AboutSettings {
        onExternalStorageUsageModelChanged: {
            refresh()
        }
    }

    function _addCloudAccounts() {
        for (var i=0; i<cloudAccountModel.count; i++) {
            var data = cloudAccountModel.get(i)

            //: The account type and account name, e.g.: "Dropbox (username)"
            //% "%1 (%2)"
            var name = data.accountUserName
                    ? qsTrId("vault-he-cloud_account_name").arg(data.providerDisplayName).arg(data.accountUserName)
                    : data.providerDisplayName
            var props = {
                "type": storageTypeCloud,
                "name": name,
                "accountId": data.accountId,
                "path": ""
            }
            append(props)
        }
    }

    function _addDrives() {
        var externalStorage = _aboutSettings.externalStorageUsageModel
        for (var devicePath in externalStorage) {
            var storageData = externalStorage[devicePath]
            if (storageData.path) {
                var props = {
                    "type": storageTypeMemoryCard,
                    //% "Memory card"
                    "name": qsTrId("vault-la-memory_card"),
                    "accountId": 0,
                    "path": storageData.path
                }
                append(props)
            }
        }
    }

    Component.onCompleted: {
        refresh()
    }
}
