/****************************************************************************************
**
** Copyright (c) 2020 Open Mobile Platform LLC.
**
** License: Proprietary
**
****************************************************************************************/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import Nemo.DBus 2.0

Item {
    id: root

    property string operationType
    property string actionButtonText
    property var backupStoragePicker
    property BackupRestoreStorageListModel storageListModel

    // Progress is shown if busy, or if the operation has finished and the user has not not
    // reset the visual state.
    readonly property bool showProgressBar: progressBar.label.length > 0
                                       || (progressBar.value > 0.0 && progressBar.value < 1.0)
    readonly property bool busy: sailfishBackup.status.length > 0
                                 && sailfishBackup.status != "Idle"
                                 && sailfishBackup.status != "Finished"
                                 && sailfishBackup.status != "Error"
                                 && sailfishBackup.status != "Canceled"

    property bool _liveUpdates: true
    property string _lastLogFilePath
    readonly property string _contextMenuLog: busy ? sailfishBackup.logFilePath : _lastLogFilePath

    signal actionButtonClicked()
    signal okButtonClicked()
    signal cloudBackupFinished(var accountId)
    signal fileBackupFinished(var filePath)

    function backupToCloud(accountId) {
        _start("backupToCloud", [accountId])
    }

    function backupToFile(filePath) {
        _start("backupToFile", [filePath])
    }

    function restoreFromCloud(accountId, filePath) {
        _start("restoreFromCloud", [accountId, filePath])
    }

    function restoreFromFile(filePath) {
        _start("restoreFromFile", [filePath])
    }

    function setLiveUpdatesEnabled(liveUpdates) {
        if (liveUpdates !== _liveUpdates) {
            if (liveUpdates) {
                progressBar.label = ""
                progressBar.value = 0
            }
            _liveUpdates = liveUpdates
        }
    }

    function _start(funcName, args) {
        sailfishBackup.call(funcName, args)
        sailfishBackup.status = "Preparing"

        //: Currently preparing the backup
        //% "Preparing"
        progressBar.label = qsTrId("vault-la-preparing")
    }

    width: parent.width
    height: progressBarArea.height

    ListItem {
        id: progressBarArea

        contentHeight: Theme.itemSizeMedium
        visible: root.showProgressBar

        menu: _contextMenuLog.length > 0 ? logMenuComponent : null

        Component {
            id: logMenuComponent

            ContextMenu {
                MenuItem {
                    //: View the logged details for this backup
                    //% "View log"
                    text: qsTrId("vault-me-backup_log")

                    onClicked:{
                        pageStack.animatorPush(Qt.resolvedUrl("LogPage.qml"),
                                               {"filePath": root._contextMenuLog})
                    }
                }
            }
        }

        ProgressBar {
            id: progressBar

            anchors.verticalCenter: parent.verticalCenter
            leftMargin: Theme.horizontalPageMargin + Theme.paddingMedium
            rightMargin: 0
            width: progressBarArea.width - Theme.paddingMedium*3 - cancelButton.width
            indeterminate: sailfishBackup.status == "Preparing"
                    || sailfishBackup.status == "UploadingBackup"
                    || sailfishBackup.status == "DownloadingBackup"

            Behavior on value {
                id: progressBarBehavior

                enabled: false
                NumberAnimation {
                    duration: 100
                    easing.type: Easing.InOutQuad
                }
            }
        }

        IconButton {
            id: cancelButton

            anchors {
                left: progressBar.right
                leftMargin: Theme.paddingMedium
                top: progressBar.top
                topMargin: progressBar.barCenterY - height/2
            }

            enabled: sailfishBackup.canCancel || !root._liveUpdates
            icon.source: !root._liveUpdates
                         ? "image://theme/icon-m-acknowledge"
                         : "image://theme/icon-m-clear"

            onClicked: {
                if (!root._liveUpdates) {
                    root.okButtonClicked()
                } else if (sailfishBackup.canCancel) {
                    sailfishBackup.call("cancel")
                }
            }
        }
    }

    BusyIndicator {
        id: storageBusyIndicator
        anchors.centerIn: parent
        running: root.storageListModel.busy
        visible: !progressBarArea.visible
    }

    Button {
        id: actionButton

        anchors.centerIn: parent
        enabled: !backupStoragePicker || ((backupStoragePicker.selectionValid
                                           || !backupStoragePicker.selectedStorageMounted
                                           || backupStoragePicker.selectedStorageLocked)
                                           && !storageBusyIndicator.running)
        opacity: 1 - storageBusyIndicator.opacity
        visible: !progressBarArea.visible

        text: {
            if (backupStoragePicker) {
                if (!backupStoragePicker.selectedStorageMounted) {
                    //: SD-card but it is not mounted.
                    //% "Mount"
                    return qsTrId("vault-bt-mount")
                }
                if (backupStoragePicker.selectedStorageLocked) {
                    //: SD-card but it is locked (encryption is not yet opened)
                    //% "Unlock"
                    return qsTrId("vault-bt-unlock")
                }
            }
            return root.actionButtonText
        }

        onClicked: {
            var data
            if (backupStoragePicker) {
                if (backupStoragePicker.selectedStorageLocked) {
                    data = backupStoragePicker.activeItem()
                    root.storageListModel.unlock(data.devPath)
                    return
                } else if (!backupStoragePicker.selectedStorageMounted) {
                    data = backupStoragePicker.activeItem()
                    root.storageListModel.mount(data.devPath)
                    return
                }
            }

            root.actionButtonClicked()
        }
    }

    DBusInterface {
        id: sailfishBackup

        property string mode
        property string status
        property string statusText
        property real progress
        property bool canCancel
        property string error
        property string logFilePath

        function cloudBackupStatusChanged(accountId, status) {
            if (status == "Finished") {
                root.cloudBackupFinished(accountId)
            }
        }

        function fileBackupStatusChanged(filePath, status) {
            if (status == "Finished") {
                root.fileBackupFinished(filePath)
            }
        }

        function _shouldUpdateUI() {
            return mode.substr(0, root.operationType.length) === root.operationType
        }

        function _isDoneStatus(s) {
            return s == "Finished" || s == "Error" || s == "Canceled"
        }

        service: "org.sailfishos.backup"
        path: "/sailfishbackup"
        iface: "org.sailfishos.backup"

        propertiesEnabled: true
        signalsEnabled: true

        onStatusTextChanged: {
            if (!_shouldUpdateUI()) {
                return
            }

            if (root._liveUpdates) {
                progressBar.label = statusText

                progressBarBehavior.enabled = status !== "Canceled" && status !== "Error"
                progressBar.value = (status == "Finished")
                        ? 1
                        : (status == "Canceled" || status == "Error" ? 0 : progress)
                progressBarBehavior.enabled = false
            }

            if (_isDoneStatus(status)) {
                root._lastLogFilePath = logFilePath
                root._liveUpdates = false

            } else if (!root._liveUpdates && status != "Idle") {
                // If the state is frozen but another backup/restore begins, unfreeze it.
                root.setLiveUpdatesEnabled(true)
            }
        }
    }

    DBusInterface {
        service: "org.sailfishos.backup"
        path: "/sailfishbackup"
        iface: "org.sailfishos.backup"

        watchServiceStatus: true

        onStatusChanged: {
            if (root.busy && status !== DBusInterface.Available) {
                var msg = "org.sailfishos.backup service crashed during backup/restore!"
                console.warn(msg)

                root.setLiveUpdatesEnabled(false)
                sailfishBackup.status = "Error"

                //% "Error: Backup service unavailable"
                progressBar.label = qsTrId("vault-la-backup_service_unavailable")
                progressBar.value = 1

                if (sailfishBackup.logFilePath.length > 0) {
                    root._lastLogFilePath = sailfishBackup.logFilePath
                    BackupUtils.writeToFile(sailfishBackup.logFilePath, msg)
                }
            }
        }
    }
}
