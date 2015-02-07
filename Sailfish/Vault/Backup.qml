import QtQuick 2.0
import Sailfish.Silica 1.0
import NemoMobile.Vault 1.0

Column {
    id: backupItem

    property bool populated: false
    property bool busy: false

    // emited when component information loading is completed
    signal ready

    // emited when backup is done
    signal done

    // emited when process in progress, status can be ('begin', 'ok',
    // 'fail')
    signal progress(string unit, string status)

    signal error(variant err)

    anchors { left: parent.left; right: parent.right}
    spacing: Theme.paddingSmall

    UnitsGrid {
        anchors { left: parent.left; right: parent.right}
        id: unitsGrid
        onReady: {
            console.log("Units grid is ready");
            populated = true;
            busy = false;
            backupItem.ready();
        }
        onError: backupItem.error(err)
    }

    function load(reconnect) {
        console.log("Load");
        unitsGrid.load(reconnect);
    }

    function unitProgress(info) {
        /*
          TODO: Re-enable once localized JB#12128
        if (info.status === "begin")
            progressItem.label = info.unit;
        else
            progressItem.label = "...";
        */
        console.log(info.unit, info.status);
        unitsGrid.setStatus(info.unit, info.status);
    }

    // just allowing user to see for the interval a status of last
    // operation
    Timer {
        id: doneTimer
        interval: 1000
        repeat: false
        running: false
        onTriggered: {
            unitsGrid.done()
            backupItem.done()
        }
    }

    function taskDone() {
        console.log("Done");
        progressItem.label = "";
        doneTimer.restart();
    }

    Connections {
        target: vault
        onDone: {
            if (operation == Vault.Backup || operation == Vault.Restore) {
                taskDone();
            } else if (operation == Vault.RemoveSnapshot) {
                backupItem.ready();
            }
        }
        onProgress: {
            if (operation == Vault.Backup || operation == Vault.Restore) {
                console.log(data);
                unitProgress(data);
            }
        }
    }

    function startBackup() {
        var units = unitsGrid.listSelected();
        if (!units || units.length === 0) {
            console.log("Nothing to backup");
            return;
        }
        busy = true;
        vault.startBackup(startBackupItem.text, units);
        startBackupItem.text = ""
    }

    function startRestore(tag) {
        if (!tag) {
            console.log("Tag is empty");
            return;
        }
        console.log("Restore", tag);
        var units = unitsGrid.listSelected();
        if (!units || units.length === 0) {
            console.log("Nothing to restore");
            return;
        }
        busy = true;
        vault.startRestore(tag, units);
    }

    function rmSnapshot(tag) {
        if (!tag) {
            console.log("Tag is empty");
            backupItem.ready();
        }
        try {
            console.log("Remove", tag);
            vault.removeSnapshot(tag);
        } catch (e) {
            console.log("Error:", e);
            backupItem.ready();
        }
    }

    Item {
        width: parent.width
        height: Theme.paddingLarge
    }

    Item {
        height: startBackupItem.height
        width: parent.width

        StartBackup {
            id: startBackupItem
            enabled: !backupItem.busy && backupItem.populated
            onClicked: startBackup()
        }
        ProgressBar {
            id: progressItem

            indeterminate: true
            width: parent.width
            opacity: backupItem.busy ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
        }
    }
}
