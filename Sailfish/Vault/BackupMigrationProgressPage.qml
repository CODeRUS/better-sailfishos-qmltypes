import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import NemoMobile.Vault 1.0

BackupRestoreProgressPage {
    id: root

    property Vault vault
    property UnitListModel unitListModel

    property string snapshotName
    property var snapshotDateTime

    property int toCloudAccountId
    property string toBackupDir

    property bool _started
    property string _snapshotExportDir

    progressValue: backupRestore.progress

    //: Label which is displayed while a particular backup is migrated to the new format.
    //% "Updating backup"
    busyHeadingText: qsTrId("vault-la-backup_migration_updating_backup")

    //: Label which is displayed when a particular backup has been successfully migrated to the new format.
    //% "Done. Your backup has been updated."
    successHeadingText: qsTrId("vault-la-backup_migration_done")

    //: Label which is displayed when the migration operation for a particular backup fails.
    //% "The backup could not be updated."
    errorHeadingText: qsTrId("vault-la-backup_migration_error")

    progressImageSource: backupRestore.syncing ? "image://theme/icon-l-transfer" : "image://theme/icon-l-backup"

    onStatusChanged: {
        if (!_started && status == PageStatus.Active) {
            _started = true
            _snapshotExportDir = backupUtils.createTemporaryDirectory('vault_snapshot_' + snapshotName)
            vault.exportSnapshot(snapshotName, _snapshotExportDir)
        }
    }

    BackupRestoreOperation {
        id: backupRestore

        unitListModel: root.unitListModel

        onStatusUpdate: {
            root.statusText = statusText
        }
        onDone: {
            root._cleanUp()
            root.state = "success"
            root.statusText = ""
        }
        onError: {
            root._cleanUp()
            root.state = "error"
            root.errorHeadingText = errorMainText
            root.errorDetailText = errorDetailText
        }
    }

    function _cleanUp() {
        backupUtils.removeTemporaryDirectory(_snapshotExportDir)
    }

    BackupUtils {
        id: backupUtils
    }

    Connections {
        target: root.vault

        onDone: {
            if (operation == Vault.ExportSnapshot) {
                console.log("snapshot exporting is done"
                            , data.rc, data.snapshot, data.dst
                            , data.stdout, data.stderr)
                if (root.toCloudAccountId > 0) {
                    backupRestore.compressToCloud(_snapshotExportDir, root.toCloudAccountId, snapshotDateTime)
                } else {
                    backupRestore.compressToDir(_snapshotExportDir, root.toBackupDir, snapshotDateTime)
                }
            }
        }

        onError: {
            console.log("Vault error", operation, "error", error.rc, error.snapshot, error.dst,
                        error.stdout, error.stderr)
            root._cleanUp()
            root.state = "error"
        }
    }
}
