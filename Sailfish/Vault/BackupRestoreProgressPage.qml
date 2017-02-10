import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0

FullScreenOperationPage {
    id: root

    property bool backupMode
    property int cloudAccountId
    property string backupDir
    property string fileToRestore
    property UnitListModel unitListModel

    property bool canCancel: backupMode && !backupRestore.syncing
               && (state == "" || (backupRestore.running && !backupRestore.canceling))
    readonly property bool busy: backupRestore.running

    property BackupRestoreOperation backupRestore: defaultBackupRestore

    function _start() {
        if (backupMode) {
            if (root.cloudAccountId > 0) {
                backupRestore.backupToCloud(root.cloudAccountId)
            } else {
                backupRestore.backupToDir(root.backupDir)
            }
        } else {
            if (root.cloudAccountId > 0) {
                backupRestore.restoreFromCloud(root.cloudAccountId, root.fileToRestore)
            } else {
                backupRestore.restoreFromFile(root.fileToRestore)
            }
        }
    }

    progressValue: backupRestore.progress
    statusText: " " // reserve space so button position doesn't animate

    busyHeadingText: root.backupMode
                   //% "Please wait while your content is backed up"
                 ? qsTrId("vault-la-please_wait_backing_up")
                   //% "Please wait while your content is restored"
                 : qsTrId("vault-la-please_wait_restoring")

    busyBodyText: !root.backupMode
                    //: Do not turn off the device during the data backup or restore process
                    //% "Do not turn off your device!"
                  ? qsTrId("vault-la-do_not_turn_off")
                  : ""

    successHeadingText: {
        if (root.backupMode) {
            return root.cloudAccountId > 0
                       //% "Done. Your backup was uploaded successfully."
                     ? qsTrId("vault-la-done_backup_uploaded_successfully")
                       //% "Done. Your backup has been copied to the memory card."
                     : qsTrId("vault-la-done_backup_copied_to_memory_card")
        } else {
            //% "Done. Your data was restored successfully."
            return qsTrId("vault-la-done_backup_restored_successfully")
        }
    }

    progressImageSource: {
        if (backupRestore.running) {
            if (backupRestore.currentUnit.length > 0) {
                return unitListModel.getUnitValue(backupRestore.currentUnit, "iconSource", "")
            } else if (backupRestore.syncing) {
                return "image://theme/icon-l-transfer"
            }
            return "image://theme/icon-l-backup"
        }
        return ""
    }
    progressCaption: {
        if (backupRestore.running && backupRestore.currentUnit.length > 0) {
            return unitListModel.getUnitValue(backupRestore.currentUnit, "displayName", "")
        }
        return ""
    }

    onStatusChanged: {
        if (status == PageStatus.Active && state == "") {
            // starting immediately makes the UI seem jerky, so delay a bit
            delayedStart.start()
        }
    }

    Timer {
        id: delayedStart
        interval: 500
        onTriggered: {
            state = "running"
            _start()
        }
    }

    BackupRestoreOperation {
        id: defaultBackupRestore

        unitListModel: root.unitListModel

        onStatusUpdate: {
            root.statusText = statusText
        }
        onDone: {
            if (root.backupMode && root.cloudAccountId <= 0) {
                deleteOldBackups(root.backupDir)
            }
            root.state = "success"
            root.statusText = ""
        }
        onError: {
            root.state = "error"
            root.errorHeadingText = errorMainText
            root.errorDetailText = errorDetailText
        }
    }
}
