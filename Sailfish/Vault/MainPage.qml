import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Accounts 1.0
import Sailfish.Vault 1.0
import NemoMobile.Vault 1.0
import Nemo.DBus 2.0
import org.nemomobile.configuration 1.0

Page {
    id: root

    function backupToCloudAccount(accountId) {
        console.log("Trigger cloud backup operation to account", accountId)
        showDialog({"backupMode": true, "cloudAccountId": accountId})
    }

    function restoreFromCloudAccount(accountId, filePath) {
        console.log("Trigger cloud restore operation from account", accountId, filePath)
        showDialog({"backupMode": false, "cloudAccountId": accountId, "fileToRestore": filePath})
    }

    function backupToDir(path) {
        console.log("Trigger backup to directory", path)
        showDialog({"backupMode": true, "backupDir": path})
    }

    function restoreFromFile(path) {
        console.log("Trigger restore from file", path)
        showDialog({"backupMode": false, "fileToRestore": path})
    }

    function showDialog(parameters) {
        parameters.unitListModel = root._unitListModel
        var dialog = pageStack.push(Qt.resolvedUrl("NewBackupRestoreDialog.qml"), parameters)
        dialog.operationFinished.connect(function(successful) {
            if (successful) {
                // if accounts were restored, the available storages will have changed

                // If a backup was done, need to update the last created backup info display;
                // if a restore was done, the accounts will have changed.
                contentLoader.item.refreshStoragePickers()
                if (!dialog.backupMode) {
                    _storageListModel.refresh()
                }
            }
        })
    }

    property UnitListModel _unitListModel: UnitListModel {}
    property BackupRestoreStorageListModel _storageListModel: BackupRestoreStorageListModel {}

    property bool _cloudStorageAccountServiceAvailable: backupUtils.checkCloudAccountServiceAvailable()
    property bool _needsMigration: _vault.hasSnapshots && _storageListModel.count > 0
    property bool _checkMigrationNeeded: _vault.connected && _storageListModel.ready && status == PageStatus.Active
    property string _memoryCardLegacyImportId

    on_CheckMigrationNeededChanged: {
        if (_checkMigrationNeeded) {
            if (_needsMigration) {
                _showMigrationDialog()
            } else {
                _checkMigrationNeeded = false
            }
        }
    }

    // Migrate Vault dumps on the local drive to simple single-archive backups
    function _showMigrationDialog() {
        var props = {
            "vault": _vault,
            "unitListModel": _unitListModel
        }
        var dlg = pageStack.push(Qt.resolvedUrl("BackupMigrationDialog.qml"), props)
        dlg.statusChanged.connect(function() {
            if (dlg.status == PageStatus.Active) {
                root._checkMigrationNeeded = false
            }
        })
        dlg.operationFinished.connect(function(successful) {
            if (successful) {
                contentLoader.item.refreshStoragePickers()
                _vault.removeAllSnapshots()
            }
        })
    }

    function _addImportedBackup(fileId) {
        var prevImportedBackups = importedBackups.value
        prevImportedBackups.push(fileId)
        importedBackups.value = prevImportedBackups
        importedBackups.sync()
    }

    function _backupAlreadyImported(fileId) {
        return importedBackups.value.indexOf(fileId) >= 0
    }

    BusyIndicator {
        id: pageBusy
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: contentLoader.status !== Loader.Ready || root._checkMigrationNeeded || _vault.removingSnapshots
    }

    ConfigurationValue {
        id: importedBackups
        key: "/sailfish/vault/imported_backups"
        defaultValue: []
    }

    Vault {
        id: _vault
        property bool connected
        property bool importing
        property bool removingSnapshots

        property bool hasSnapshots
        property string latestSnapshotName
        property string snapshotArchiveFile

        property var _allSnapshots: []
        property int _snapshotRemoveCount

        function removeAllSnapshots() {
            removingSnapshots = true
            _snapshotRemoveCount = _allSnapshots.length
            for (var i in _allSnapshots) {
                removeSnapshot(_allSnapshots[i])
            }
        }

        function startImport(path) {
            importing = true
            exportImportPrepare(Vault.Import, path)
            exportImportExecute()
        }

        function _resetSnapshots() {
            _allSnapshots = snapshots()
            hasSnapshots = _allSnapshots.length > 0
            latestSnapshotName = _allSnapshots.length > 0 ? _allSnapshots[0] : ""
        }

        Component.onCompleted: {
            connectVault(false)
        }
        onDone: {
            console.log("Vault done", operation)
            if (operation == Vault.Connect) {
                _resetSnapshots()
                connected = true
                _unitListModel.loadVaultUnits(units())
            } else if (operation == Vault.ExportImportExecute) {
                // the legacy backup dump on the memory card was successfully imported
                _resetSnapshots()
                importing = false
                root._addImportedBackup(root._memoryCardLegacyImportId)
                root._memoryCardLegacyImportId = ""
                root._showMigrationDialog()
            } else if (operation == Vault.RemoveSnapshot) {
                _snapshotRemoveCount--
                if (_snapshotRemoveCount == 0) {
                    _resetSnapshots()
                    removingSnapshots = false
                }
            }
        }
        onError: {
            console.log("Vault error", operation, "error", error.rc, error.snapshot, error.dst,
                        error.stdout, error.stderr)
            if (operation == Vault.Import) {
                importing = false
            } else if (operation == Vault.RemoveSnapshot) {
                removingSnapshots = false
            }
        }
    }

    BackupUtils {
        id: backupUtils
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: header.height + contentLoader.height + Theme.paddingLarge

        VerticalScrollDecorator {}

        PageHeader {
            id: header
            //% "Backup"
            title: qsTrId("vault-he-backup")
        }

        Loader {
            id: contentLoader
            opacity: 1 - pageBusy.opacity
            anchors.top: header.bottom
            width: parent.width
            sourceComponent: _vault.connected
                             ? (root._storageListModel.count > 0 ? mainContentComponent : placeholderContentComponent)
                             : null
        }
    }

    Component {
        id: placeholderContentComponent

        Column {
            width: parent ? parent.width : Screen.width
            spacing: Theme.paddingLarge

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                font.family: Theme.fontFamilyHeading
                font.pixelSize: Theme.fontSizeExtraLarge
                wrapMode: Text.Wrap
                color: Theme.highlightColor

                //: No memory card or cloud account available for doing system backup
                //% "There's no memory card or cloud storage account"
                text: qsTrId("vault-la-no_memory_card_or_cloud")
            }

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                textFormat: Text.PlainText

                //% "Please insert a micro SD card and try again. Always use a dedicated card for storing your backups and keep it in a safe place."
                text: qsTrId("vault-la-insert_micro_sd_and_try_again")
            }

            Label {
                visible: root._cloudStorageAccountServiceAvailable
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                textFormat: Text.PlainText

                //% "Alternatively, create a storage account with a third party service to safely store your backed up data."
                text: qsTrId("vault-la-add_cloud_storage_account")
            }

            Button {
                visible: root._cloudStorageAccountServiceAvailable
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: settingsUi.call("showAccounts", [])

                //% "Add account"
                text: qsTrId("vault-bt-add_account")
            }

            DBusInterface {
                id: settingsUi
                service: "com.jolla.settings"
                path: "/com/jolla/settings/ui"
                iface: "com.jolla.settings.ui"
            }
        }
    }

    Component {
        id: mainContentComponent

        Column {
            id: mainContent

            function refreshStoragePickers() {
                backupStoragePicker.refresh()
                restoreStoragePicker.refresh()
            }

            width: parent ? parent.width : Screen.width

            Label {
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                height: implicitHeight + Theme.paddingLarge

                //% "Create a backup to protect your personal data. Use it later to restore your device just the way it was."
                text: qsTrId("vault-la-create_backup_info")
            }

            BackupRestoreStoragePicker {
                id: backupStoragePicker
                backupMode: true
                storageListModel: root._storageListModel
                height: implicitHeight + Theme.paddingLarge
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: backupStoragePicker.selectionValid

                //: Start process of backing up data
                //% "Backup"
                text: qsTrId("vault-bt-backup")

                onClicked: {
                    if (backupStoragePicker.cloudAccountId > 0) {
                        root.backupToCloudAccount(backupStoragePicker.cloudAccountId)
                    } else if (backupStoragePicker.memoryCardPath.length > 0) {
                        root.backupToDir(backupStoragePicker.memoryCardPath)
                    } else {
                        console.log("Internal error, invalid storage type!")
                    }
                }
            }

            Item {
                width: 1
                height: Theme.paddingLarge * 2
            }

            SectionHeader {
                //: Header for data restore section
                //% "Restore device"
                text: qsTrId("vault-la-restore_device")
            }

            Loader {
                id: snapshotUpdatePromptLoader

                width: parent.width
                visible: root._needsMigration
                sourceComponent: root._needsMigration ? snapshotUpdateComponent : null

                Component {
                    id: snapshotUpdateComponent

                    SnapshotUpdatePrompt {
                        lastBackupDateTime: backupUtils.dateTimeFromIsoString(_vault.latestSnapshotName)
                        onTriggerUpdate: root._showMigrationDialog()
                    }
                }
            }

            BackupRestoreStoragePicker {
                id: restoreStoragePicker

                backupMode: false
                storageListModel: root._storageListModel
                height: implicitHeight + Theme.paddingLarge

                visible: !snapshotUpdatePromptLoader.sourceComponent && !_vault.importing
                showStorageInfo: !memoryCardVaultUpdateButton.visible

                onMemoryCardPathChanged: {
                    root._memoryCardLegacyImportId = ""
                    if (memoryCardPath.length > 0) {
                        root._memoryCardLegacyImportId = backupUtils.vaultDumpFileId(memoryCardPath)
                    }
                }
            }

            BusyIndicator {
                height: running ? implicitHeight : 0
                anchors.horizontalCenter: parent.horizontalCenter
                running: _vault.importing
            }

            Item {
                width: 1
                height: Theme.paddingLarge
                visible: _vault.importing
            }

            // If the memory card contains a Vault snapshot dump, it must be imported to the local
            // disk and then migrated to a single-archive backup.
            Button {
                id: memoryCardVaultUpdateButton

                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                visible: root._memoryCardLegacyImportId.length > 0
                         && !root._backupAlreadyImported(root._memoryCardLegacyImportId)
                         && !snapshotUpdatePromptLoader.sourceComponent

                // (reuse this translation to avoid adding a new one)
                //: Major heading on the page which lets the user select which backup they wish to migrate to the new format.
                //% "Update your backup"
                text: qsTrId("vault-he-update_your_backup")

                onClicked: {
                    _vault.startImport(restoreStoragePicker.memoryCardPath)
                    enabled = false
                }
            }

            Button {
                visible: !snapshotUpdatePromptLoader.sourceComponent && !memoryCardVaultUpdateButton.visible
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: restoreStoragePicker.selectionValid && restoreStoragePicker.fileToRestore.length > 0

                //: Start process of restoring data from backup
                //% "Restore"
                text: qsTrId("vault-bt-restore")

                onClicked: {
                    if (restoreStoragePicker.cloudAccountId > 0) {
                        root.restoreFromCloudAccount(restoreStoragePicker.cloudAccountId, restoreStoragePicker.fileToRestore)
                    } else if (restoreStoragePicker.fileToRestore.length > 0) {
                        root.restoreFromFile(restoreStoragePicker.fileToRestore)
                    } else {
                        console.log("Internal error, invalid storage type!")
                    }
                }
            }
        }
    }
}
