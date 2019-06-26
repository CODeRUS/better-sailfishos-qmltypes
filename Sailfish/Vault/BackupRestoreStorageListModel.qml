import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import org.nemomobile.systemsettings 1.0

ListModel {
    id: root

    readonly property int storageTypeInvalid: 0
    readonly property int storageTypeMemoryCard: 1
    readonly property int storageTypeCloud: 2
    readonly property bool ready: count > 0 || !_waitForStorage.running

    property AccountModel cloudAccountModel: AccountModel {
        filterType: AccountModel.ServiceTypeFilter
        filter: "storage"
    }

    function refresh() {
        clear()
        _addCloudAccounts()
        _addDrives()
    }

    property AboutSettings _aboutSettings: AboutSettings {
        onExternalStorageUsageModelChanged: {
            root.refresh()
        }
    }

    // PartitionManager in org.nemomobile.systemsettings does not see the memory card storage
    // immediately, and we can't tell if a storage is not yet seen or does not exist at all,
    // so wait up to a second to confirm.
    property Timer _waitForStorage: Timer {
        running: true
        interval: 1000
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
                var name = storageData.available > 0
                        //: the parameter is the capacity of the memory card, e.g. "4.2 GB"
                        //% "Memory card %1"
                        ? qsTrId("vault-la-memory_card_with_size").arg(Format.formatFileSize(storageData.available))
                          //% "Memory card"
                        : qsTrId("vault-la-memory_card")
                var props = {
                    "type": storageTypeMemoryCard,
                    "name": name,
                    "accountId": 0,
                    "path": storageData.path
                }
                append(props)
            }
        }
    }
}
