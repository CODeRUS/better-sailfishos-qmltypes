import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import NemoMobile.Vault 1.0

Dialog {
    id: root

    property bool backupMode
    property int cloudAccountId
    property string backupDir
    property string fileToRestore

    property UnitListModel unitListModel: UnitListModel {
        // if unitListModel hasn't been set to a pre-filled list model, set it up here
        property Vault _vault: Vault {
            Component.onCompleted: {
                root.canAccept = false
                connectVault(false)
            }
            onDone: {
                if (operation == Vault.Connect) {
                    unitListModel.loadVaultUnits(units())
                    root.canAccept = true
                }
            }
            onError: {
                console.log("Vault error", operation, "error", error.rc, error.snapshot, error.dst,
                            error.stdout, error.stderr)
            }
        }
    }

    signal operationFinished(var successful)

    default property alias _content: contentColumn.data

    acceptDestination: backupRestoreProgressComponent

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: contentColumn.height

        VerticalScrollDecorator {}

        BusyIndicator {
            id: unitListModelBusy
            anchors.centerIn: parent
            size: BusyIndicatorSize.Large
        }

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
                visible: !unitListModelBusy.running

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

            backupMode: root.backupMode
            cloudAccountId: root.cloudAccountId
            backupDir: root.backupDir
            fileToRestore: root.fileToRestore
            unitListModel: root.unitListModel

            button1Text: {
                if (!backupMode) {
                    // Restore operations cannot be canceled, so set an empty string so that
                    // the button will be hidden.
                    return state == "" || busy ? "" : defaultOKText
                }
                return canCancel ? defaultCancelText : defaultOKText
            }

            onButton1Clicked: {
                if (canCancel) {
                    progressPage.backupRestore.cancel()
                    pageStack.pop(pageStack.previousPage(root))
                } else {
                    pageStack.pop(pageStack.previousPage(root))
                }
            }

            Connections {
                target: progressPage.backupRestore
                onDone: {
                    root.operationFinished(true)
                }
                onError: {
                    root.operationFinished(false)
                }
            }
        }
    }
}
