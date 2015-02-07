import QtQuick 2.0
import Sailfish.Silica 1.0
import NemoMobile.Vault 1.0

Page {
    id: backupPage

    // emited when backup is done
    signal done

    property Vault vault: Vault { }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            backupItem.load()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content
            width: parent.width
            PageHeader {
                //% "New Backup"
                title: qsTrId("vault-he-new_backup")
            }
            Backup {
                id: backupItem
                onDone: backupPage.done()
            }
        }
    }
    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: !backupItem.populated
    }
}

