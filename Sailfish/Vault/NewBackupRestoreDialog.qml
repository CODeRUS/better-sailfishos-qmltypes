import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0

Dialog {
    id: root

    property bool backupMode
    property int cloudAccountId
    property string backupDir
    property string fileToRestore
    property UnitListModel unitListModel

    signal operationFinished(var successful)

    default property alias _content: contentColumn.data

    acceptDestination: backupRestoreProgressComponent

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        VerticalScrollDecorator {}

        Column {
            id: contentColumn
            width: parent.width

            DialogHeader {
                id: header
                title: backupMode
                         //% "Create a backup"
                       ? qsTrId("vault-he-create_a_backup")
                         //% "Restore device"
                       : qsTrId("vault-he-restore_device")
            }

            Label {
                y: header.height
                x: Theme.horizontalPageMargin
                width: parent.width - x*2
                height: implicitHeight + Theme.paddingLarge
                wrapMode: Text.Wrap
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.highlightColor
                textFormat: Text.StyledText

                text: {
                    if (cloudAccountId > 0) {
                        return backupMode
                              //: Describes the data backup process to a cloud service
                              //% "Your data will now be saved and uploaded to the cloud service. Depending on the amount of content you have, it might take some time. Please wait without turning off your device or disconnecting from your internet service.<br><br>Please note: Gallery images and videos will not be saved in this backup. To add images to the cloud, share them to your cloud account from Gallery."
                            ? qsTrId("vault-la-backup_cloud_description")
                              //: Describes the data restoration process from a cloud service
                              //% "Your data will now be downloaded and restored. Depending on the amount of content you have, it might take some time. Please wait without turning off your device or disconnecting from your internet service."
                            : qsTrId("vault-la-restore_cloud_description")
                    } else {
                        return backupMode
                              //: Describes the data backup process to a memory card
                              //% "Your data will now be saved to the memory card. Depending on the amount of content you have, it might take some time. Please wait without turning off your device or removing the memory card."
                            ? qsTrId("vault-la-backup_memory_card_description")
                              //: Describes the data restoration process from a memory card
                              //% "Your data will now be copied from the memory card and restored. Depending on the amount of content you have, it might take some time. Please wait without turning off your device or removing the memory card."
                            : qsTrId("vault-la-restore_memory_card_description")
                    }
                }
            }
        }
    }

    Component {
        id: backupRestoreProgressComponent

        BackupRestoreProgressPage {
            id: progressPage

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

            canCancel: backupMode && !backupRestore.syncing
                       && (state == "" || (backupRestore.running && !backupRestore.canceling))
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

            onDone: {
                pageStack.pop(pageStack.previousPage(root))
            }

            onCancelRequested: {
                backupRestore.cancel()
                pageStack.pop(pageStack.previousPage(root))
            }

            BackupRestoreOperation {
                id: backupRestore

                unitListModel: root.unitListModel

                onStatusUpdate: {
                    progressPage.statusText = statusText
                }
                onDone: {
                    if (root.cloudAccountId <= 0) {
                        deleteOldBackups(root.backupDir)
                    }
                    progressPage.state = "success"
                    progressPage.statusText = ""
                    root.operationFinished(true)
                }
                onError: {
                    progressPage.state = "error"
                    progressPage.errorHeadingText = errorMainText
                    progressPage.errorDetailText = errorDetailText
                    root.operationFinished(false)
                }
            }
        }
    }
}
