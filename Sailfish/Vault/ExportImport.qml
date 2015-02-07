import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.keepalive 1.0
import NemoMobile.Vault 1.0

Page {
    id: exportImportPage

    property bool inProgress: false
    property double estimatedSizeKb: 0
    property double currentSizeKb: 0
    property double fraction: estimatedSizeKb > 0
        ? Math.min(currentSizeKb / estimatedSizeKb, 1.0) : 0

    property string estimatedTime: ""
    property string stage: ""
    property Vault vault: null

    onInProgressChanged: {
        KeepAlive.enabled = inProgress
    }

    backNavigation: !inProgress

    property variant context: null
    property bool isImport: (context && context.action === "import")

    signal done(variant info)

    PageHeader {
        title: isImport
        //% "Import Backups"
            ? qsTrId("value-he-import-storage")
        //% "Export Backups"
            : qsTrId("value-he-export-storage")
    }

    Column {
        opacity: inProgress ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation {} }
        anchors.centerIn: parent
        width: parent.width - Theme.paddingLarge
        Label {
            width: parent.width
            color: Theme.primaryColor
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            
            text: isImport
            //% "Import your backup storage from the snapshot stored on the memory card"
                ? qsTrId("vault-me-import-info")
            //% "Export your backup storage snapshot to the memory card"
                : qsTrId("vault-me-export-info")
        }
        Label {
            width: parent.width
            color: Theme.highlightColor
            wrapMode: Text.Wrap
            horizontalAlignment: Text.AlignHCenter
            
            text: isImport
            //% "All backups stored in internal memory will be replaced!"
                ? qsTrId("vault-me-import-warning")
            //% "Snapshot will be saved to the file %1"
                : qsTrId("vault-me-export-info-file-name").arg("Backup.tar")
        }
    }

    ExportImportProgress {
        visible: inProgress
        anchors.centerIn: parent
        width: Math.min(parent.width, parent.height) / 2
        height: width
        progress: canEstimate ? fraction : 0
        //% "%1/%2"
        info: qsTrId("vault-me-export-progress-bytes")
            .arg(Format.formatFileSize(currentSizeKb * 1024))
            .arg(Format.formatFileSize(estimatedSizeKb * 1024))
        timeText: estimatedTime
        stage: exportImportPage.stage
    }

    function onImported() {
        KeepAlive.enabled = false;
        //% "Backup storage is imported"
        var msg = qsTrId("vault-la-notify-imported");
        exportImportPage.done({message: msg, reload: true
                                , context: context});
        pageStack.pop();
    }

    function onExported() {
        KeepAlive.enabled = false;
        //% "Backup storage is exported"
        var msg = qsTrId("vault-la-notify-exported");
        exportImportPage.done({message: msg, context: context});
        pageStack.pop();
    }

    property variant timeStart

    function updateProgress(info) {
        console.log(info);


        console.log("Progress", info.type);
        switch (info.type) {
        case "estimated_size":
            estimatedSizeKb = info.size;
            console.log("Estimated size", estimatedSizeKb);
            break;
        case "dst_size":
            currentSizeKb = parseFloat(info.size);
            console.log("Current size", currentSizeKb);
            var timeNow = new Date();
            var dt = timeNow - timeStart;
            if (fraction) {
                var timeLeft = (dt/fraction - dt) / 1000;
                estimatedTime = Format.formatDuration(timeLeft, Formatter.DurationShort);
            }
            break;
        case "stage":
            stage = info.stage;
            break;
        default:
            console.log("Unknown stage", info.stage);
            break;
        }
    }

    function start() {
        console.log((isImport ? "Import" : "Export"), "from", context.src);
        timeStart = new Date();
        exportImportPage.inProgress = true;
        vault.exportImportExecute();
    }

    Connections {
        target: vault

        onDone: {
            if (operation == Vault.ExportImportExecute) {
                KeepAlive.enabled = false
                isImport ? onImported() : onExported()
            }
        }
        onError: {
            if (operation == Vault.ExportImportExecute) {
                KeepAlive.enabled = false;
                exportImportPage.done({error: error, reload: true, context: context});
                pageStack.pop();
            }
        }
        onProgress: {
            console.log(data);
            if (operation == Vault.ExportImportExecute) {
                updateProgress(data);
            }
        }
    }

    Button {
        id: actionButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        opacity: inProgress ? 0 : 1
        Behavior on opacity { FadeAnimation {} }
        
        text: isImport
        //% "Import"
            ? qsTrId("vault-bu-import")
        //% "Export"
            : qsTrId("vault-bu-export")

        onClicked: start()
    }
}
