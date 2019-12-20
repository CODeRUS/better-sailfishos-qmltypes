import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import MeeGo.Connman 0.2

Column {
    id: root
    width: parent ? parent.width : Screen.width

    readonly property bool selectionValid: (cloudAccountId > 0 || memoryCardPath.length > 0)
                                            && _errorText.length === 0

    property bool backupMode
    property int cloudAccountId
    property string memoryCardPath

    property string fileToRestore: {
        if (!selectionValid) {
            return ""
        }
        return (latestBackupInfoLoader.active && latestBackupInfoLoader.status == Loader.Ready)
                ? latestBackupInfoLoader.item.latestBackupFilePath
                : ""
    }

    property bool showStorageInfo: true
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Theme.horizontalPageMargin
    property bool menuOpen: storageMenu.height > 0

    property string actionText: backupMode
            //: Displayed before the list of items allowing the user to choose where data will be backed up to
            //% "Backup data to"
          ? qsTrId("vault-la-backup_data_to")
            //: Displayed before the list of items allowing the user to choose where data will be restored from
            //% "Restore data from"
          : qsTrId("vault-la-restore_data_from")

    property BackupRestoreStorageListModel storageListModel: BackupRestoreStorageListModel {}

    function refresh() {
        var prevIndex = storageCombo.currentIndex
        storageCombo.currentIndex = -1
        if (latestBackupInfoLoader.status == Loader.Ready) {
            latestBackupInfoLoader.item.backupSource = null
        }
        storageCombo.currentIndex = prevIndex
    }


    // ------

    property string _errorText

    //% "Cannot connect to the cloud service. Make sure there is an active internet connection and verify the account is enabled in Settings | Accounts."
    property string _connectionErrorText: qsTrId("vault-la-backup_lookup_error")

    function _update() {
        // No-op if already set.
        _setInitialSelection()

        if (storageCombo.currentIndex < 0 || storageCombo.currentIndex >= storageListModel.count) {
            return
        }

        root.cloudAccountId = 0
        root.memoryCardPath = ""
        var data = storageListModel.get(storageCombo.currentIndex)
        if (data.type === storageListModel.storageTypeMemoryCard) {
            if (root.backupMode && !backupUtils.verifyWritable(data.path)) {
                root.memoryCardPath = ""
                //% "The selected storage is not writable."
                _errorText = qsTrId("vault-la-cloud-la-storage_unwritable")
            } else {
                root.memoryCardPath = data.path
                _errorText = ""
            }
        } else if (data.type === storageListModel.storageTypeCloud) {
            root.cloudAccountId = data.accountId
            _errorText = _accountErrorText(root.cloudAccountId)
            if (_errorText.length == 0 && networkManager.state != "online") {
                _errorText = _connectionErrorText
            }
        }
        if (latestBackupInfoLoader.status == Loader.Ready) {
            latestBackupInfoLoader.item.active = _errorText.length === 0
            if (latestBackupInfoLoader.item.active) {
                latestBackupInfoLoader.item.backupSource = root.cloudAccountId > 0 ? root.cloudAccountId : root.memoryCardPath
            }
        }
    }

    function _accountErrorText(accountId) {
        var accountData = storageListModel.cloudAccountModel.getByAccount(accountId)
        if (accountData && !accountData.accountEnabled) {
            //: Label displayed if the cloud storage account is disabled.
            //% "This account is disabled. To use it, enable it from Settings | Accounts."
            return qsTrId("vault-la-cloud_account_disabled")
        }
        if (!storageListModel.cloudAccountModel.accountHasServiceOfTypeEnabled(accountId, "storage")) {
            //: Label displayed if the Storage service of the cloud storage account is disabled.
            //% "This account's Storage service is disabled. To use it, enable it from Settings | Accounts."
            return qsTrId("vault-la-cloud_account_storage_disabled")
        }
        return ""
    }

    function _setInitialSelection() {
        // Select the first option that is usable. This selects a cloud account even if there is no
        // internet connection as the user may want to connect and then use it.
        if (root.storageListModel.count == 0 || storageCombo.currentIndex >= 0 || storageCombo.hasInitialIndex) {
            return
        }


        for (var i = 0; i < storageListModel.count; i++) {
            var data = storageListModel.get(i)
            if (data.type === storageListModel.storageTypeCloud && root._accountErrorText(data.accountId).length > 0) {
                continue
            }
            storageCombo.currentIndex = i
            break
        }
        storageCombo.hasInitialIndex = true
    }

    BackupUtils {
        id: backupUtils
    }

    NetworkManager {
        id: networkManager
        onStateChanged: root._update()
    }

    Connections {
        target: root.storageListModel
        // This should be fixed separately. See JB#46110.
        onReadyChanged: {
            if (root.storageListModel.ready) {
                root._setInitialSelection()
            }
        }
    }

    ComboBox {
        id: storageCombo

        property bool hasInitialIndex

        width: parent.width
        leftMargin: root.leftMargin
        rightMargin: root.rightMargin
        label: root.actionText
        menu: ContextMenu {
            id: storageMenu
            Repeater {
                model: root.storageListModel
                MenuItem {
                    text: model.name
                }
            }
        }
        currentIndex: -1
        Component.onCompleted: root._update()
        onCurrentIndexChanged: root._update()

        descriptionColor: root._errorText.length > 0 || (latestBackupInfoLoader.status == Loader.Ready && latestBackupInfoLoader.item.error)
               ? "#ff4d4d" // as per TextBase errorHighlight
               : (highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor)

        description: {
            if (root._errorText.length > 0) {
                return root._errorText
            }
            if (root.backupMode) {
                if (root.memoryCardPath.length > 0) {
                    //: Explains how data will be backed up to the memory card
                    //% "Your data will be copied to the memory card. Please do not remove the memory card before the backup is completed."
                    return qsTrId("vault-la-memory_card_backup_explain")
                } else if (root.cloudAccountId > 0) {
                    //: Explains how data will be backed up to cloud storage
                    //% "Your data will be uploaded using your currently active internet connection. Note that Gallery images and videos are not included in the cloud backup."
                    return qsTrId("vault-la-cloud_backup_explain")
                } else {
                    return ""
                }
            } else {
                if (latestBackupInfoLoader.status != Loader.Ready
                        || latestBackupInfoLoader.item.loading) {
                    return ""
                }
                if (latestBackupInfoLoader.item.error) {
                    return root._connectionErrorText
                }
                if (root.fileToRestore.length === 0) {
                    //: No previous backups were found on the cloud or memory card storage
                    //% "No previous backups found"
                    return qsTrId("vault-la-no_previous_backups_found")
                }
                if (root.memoryCardPath.length > 0) {
                    //: Explains how data will be restored from the memory card
                    //% "Copying may take some time. Please wait without turning off your device and do not remove the memory card before the data is restored."
                    return qsTrId("vault-la-memory_card_restore_explain")
                } else if (root.cloudAccountId > 0) {
                    //: Explains how data will be restored from the cloud
                    //% "Downloading your backup might take some time. Use of Wi-Fi is recommended. Please wait without turning off your device."
                    return qsTrId("vault-la-cloud_restore_explain")
                } else {
                    return ""
                }
            }
        }
    }

    Item {
        x: root.leftMargin
        width: parent.width - root.leftMargin - root.rightMargin
        height: latestBackupInfoLoader.height
        visible: root.showStorageInfo

        Behavior on height {
            enabled: !root.backupMode
            NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
        }

        Loader {
            id: latestBackupInfoLoader
            width: parent.width
            sourceComponent: root.backupMode ? null : latestBackupComponent

            Component {
                id: latestBackupComponent

                LatestBackupInfo { }
            }
        }
    }
}
