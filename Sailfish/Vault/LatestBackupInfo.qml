import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property string latestBackupFilePath
    property alias backupSource: fileListModel.backupSource
    property alias active: fileListModel.active
    property bool loading: fileListModel.loading
    property bool error: fileListModel.error

    width: parent.width
    height: active && (fileListModel.loading || fileListModel.count > 0)
            ? Math.max(latestBackupLabel.height, backupFileSearchLabel.height)
            : 0

    BusyIndicator {
        id: backupFileSearchBusy
        y: Theme.paddingSmall
        size: BusyIndicatorSize.ExtraSmall
        running: root.active && fileListModel.loading
    }

    Label {
        id: backupFileSearchLabel
        anchors {
            left: backupFileSearchBusy.right
            leftMargin: Theme.paddingMedium
            right: parent.right
        }
        //: Shown while determining whether backups have previously been uploaded to cloud storage
        //% "Looking for previous backups"
        text: qsTrId("vault-la-looking_for_previous_backups")
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.highlightColor
        opacity: backupFileSearchBusy.opacity
    }

    Label {
        id: latestBackupLabel
        width: parent.width
        wrapMode: Text.Wrap
        font.pixelSize: Theme.fontSizeSmall
        height: text.length > 0 ? implicitHeight + Theme.paddingMedium + Theme.paddingSmall : 0
        color: Theme.secondaryColor
        textFormat: Text.StyledText // for <br>

        opacity: root.active && text.length > 0 ? 1 : 0
        Behavior on opacity { FadeAnimation {} }
    }

    BackupFileListModel {
        id: fileListModel

        onLoadingChanged: {
            root.latestBackupFilePath = ""
            latestBackupLabel.text = ""
            if (loading || error) {
                return
            }
            if (count > 0) {
                var modelIndex = 0
                var backupDeviceName = _backupUtils.backupDeviceName()
                for (var i=0; i<count; i++) {
                    // prefer to show the latest backup from the current device if available, otherwise
                    // show the latest backup from any device
                    if (get(i).deviceName == backupDeviceName) {
                        modelIndex = i
                        break
                    }
                }
                var data = get(modelIndex)
                if (data.fileDir) {
                    root.latestBackupFilePath = data.fileDir + '/' + data.fileName
                } else {
                    root.latestBackupFilePath = data.fileName
                }
                var created = data.created

                if (data.deviceName) {
                    //: Indicates the last date and time that a backup was created. %1 = the device on which the backup was created, %2 = locale-specific date text, %3 = locale-specific time text
                    //% "Backup created %1<br>%2 %3"
                    latestBackupLabel.text = qsTrId("vault-la-backup_created_with_device")
                            .arg(data.deviceName)
                            .arg(Format.formatDate(created, Format.DateMedium))
                            .arg(Format.formatDate(created, Format.TimeValue))
                } else {
                    //: Indicates the last date and time that a backup was created; the source device information is not known. %1 = locale-specific date text, %2 = locale-specific time text
                    //% "Backup created (Unknown device)<br>%1 %2"
                    latestBackupLabel.text = qsTrId("vault-la-backup_created_unknown_device")
                            .arg(Format.formatDate(created, Format.DateMedium))
                            .arg(Format.formatDate(created, Format.TimeValue))
                }
            }
        }
    }
}
