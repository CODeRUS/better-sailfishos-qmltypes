import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0

NewBackupRestoreDialog {
    id: root

    property BackupRestoreStoragePicker storagePicker

    backupMode: true
    cloudAccountId: storagePicker.cloudAccountId
    backupDir: storagePicker.memoryCardPath

    canAccept: storagePicker.selectionValid
}

