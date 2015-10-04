import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Vault 1.0
import org.nemomobile.notifications 1.0
import NemoMobile.Vault 1.0

Page {
    id: mainPage

    property Item backupItem: null
    property variant deferredNotification: null

    backNavigation: !backupItem || !backupItem.busy

    //TODO check maybe Loader should be used
    MountInfo {
        id: mounts
    }
    property variant deletingSnapshots: null

    property bool isSwitchingInsideBackup: false

    function pushPage(page, context) {
        isSwitchingInsideBackup = true;
        try {
            if (typeof page === "string")
                page = Qt.resolvedUrl(page);
            return pageStack.push(page, context);
        } finally {
            isSwitchingInsideBackup = false;
        }
    }

    property string currAction: ""
    property Vault vault: Vault {

        onDone: {
            if (operation == Vault.ExportImportPrepare && currAction !== "") {
                var page = pushPage("ExportImport.qml", {context: data, vault: vault});
                page.done.connect(afterExportImport);
                currAction = "";
            }
        }
        onError: {
            if (operation == Vault.ExportImportPrepare && currAction !== "") {
                showError(error);
                currAction = "";
            }
        }

    }

    function showError(err) {
        console.log(err,currAction);
        deferErrorNotification(err, currAction);
        showDeferredNotification();
    }

    function startGc() {
        // start garbage collection. Possible drawback: if user
        // activates Back UI back shortly after GC is started and
        // there is a lot of garbage to gather, backup UI will wait
        // until GC will be finished
        console.log("Exiting from backup, start gc");
        vault.startGc();
    }

    onStatusChanged: {
        switch (status) {
        case PageStatus.Deactivating:
            deleteSelectedSnapshots()
            if (!isSwitchingInsideBackup)
                startGc();
            break;
        case PageStatus.Active:
            if (backupItem && !backupItem.populated)
                backupItem.load(!backupItem.populated)

            if (deferredNotification)
                showDeferredNotification();
            break;
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (!Qt.application.active)
                startGc();
        }
    }

    function errorLoading(err) {
        deferErrorNotification(err, "load", {onlyPreview: true});
        showDeferredNotification();
        pageStack.pop();
   }

    function getActionName(action) {
        var actions = {
            //% "Restore from memory card"
            "import": qsTrId("vault-la-import-sd")
            //% "Dump to memory card"
            , "export": qsTrId("vault-la-export-sd")
            //% "Loading backup information"
            , "load": qsTrId("vault-la-loading-information")
            //% "Select snapshots"
            , "selectSnapshots": qsTrId("vault-me-snapshots-list")
        };
        var res = actions[action];
        if (!res) {
            console.log("Unknown action", action);
            //% "Backup/restore"
            res = qsTrId("vault-la-backup-restore");
        }
        return res;
    }

    function afterExportImport(info) {
        var action = info.context.action;
        if (info.error)
            deferErrorNotification(info.error, action);
        else
            deferNotification("info", info.message, getActionName(action));
        if (info.reload)
            backupItem.populated = false;
    }

    function deferErrorNotification(err, action, options) {
        var reason_msgs = {
            //% "No SD card found"
            NoSD: qsTrId("vault-la-notify-insert-sd"),
            //% "No space on the device"
            NoSpace: qsTrId("vault-la-notify-no-space-device"),
            //% "Backup storage is invalid"
            NoVault: qsTrId("vault-la-notify-vault-invalid"),
            //% "No backup archive on SD card"
            NoSource: qsTrId("vault-la-notify-no-backups-sd"),
            //% "SD card contains bad archive"
            BadSource: qsTrId("vault-la-notify-archive-error"),
            //% "Error while copying to SD card"
            Export: qsTrId("vault-la-notify-export-error"),
            //% "Unexpected error"
            Logic: qsTrId("vault-la-notify-unexpected-error"),
            //% "Backup is failed"
            Backup: qsTrId("vault-la-backup-failed")
        };
        var action_msgs = {
            //% "Can't import for some reason"
            "import": qsTrId("vault-la-notify-cant-import")
            //% "Can't export for some reason"
            , "export": qsTrId("vault-la-notify-cant-export")
            //% "Can't load for some reason"
            , "load": qsTrId("vault-la-notify-error-loading")
        };
        var msg = reason_msgs[err.reason]
            || action_msgs[action]
            //% "Unknown backup/restore error"
            || qsTrId("vault-la-notify-unknown-error");
        deferNotification("error", msg, getActionName(action), options);
    }

    function vaultExportImport(action) {
        var drives = mounts.removableDrives();

        if (!drives.length)
            return showError({reason: "NoSD"
                              , message: "There are no removable drives"});
        // temporary solution: if there are several drives/partitions,
        // use the biggest one (to use the same partition on the same
        // card). TODO it should be implemented correctly, e.g. ask
        // user to choose when exporting and check where is the vault
        // archive when importing
        drives.sort(function(a, b) { return (a.total - b.total); });
        var path = drives[0].path;
        console.log(action, " path:", path);
        currAction = action;
        var act = action == "import" ? Vault.Import : Vault.Export;
        vault.exportImportPrepare(act, path);
    }

    SnapshotsList {
        id: snapshotsList

        enabled: !backupItem.busy && backupItem.populated
        header: Column {
            width: backupItem.width
            anchors.horizontalCenter: parent.horizontalCenter

            PageHeader {
                //% "Backup"
                title: qsTrId("vault-he-backup")
                rightMargin: backupItem.contentMargin
            }
            Backup {
                id: backupItem

                onBusyChanged: if (busy) snapshotsList.scrollToTop()
                onReady: {
                    console.log("Ready, load snapshots");
                    snapshotsList.clear()
                    snapshotsList.load()
                }
                onError: {
                    if (!backupItem.populated) {
                        errorLoading(err)
                    } else {
                        showError(err)
                    }
                }

                Component.onCompleted: {
                    mainPage.backupItem = backupItem;
                    snapshotsList.restoreItem = backupItem;

                    if (mainPage.status == PageStatus.Active) {
                        backupItem.load(!backupItem.populated);
                    }
                }
            }
            SectionHeader {
                anchors {
                    left: parent.left
                    right: parent.right
                    margins: backupItem.contentMargin
                }
                //% "Restore"
                text: qsTrId("vault-la-restore")
                opacity: snapshotsList.count > 0 && snapshotsList.enabled ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation {} }
            }

        }

        contentWidth: backupItem.width
        contentMargin: backupItem.contentMargin
        anchors.fill: parent
        property real scrollMarginVertical: Theme.itemSizeLarge/2
            + Theme.paddingLarge + Theme.itemSizeSmall

        onError: errorLoading(err)

        PullDownMenu {
            MenuItem {
                text: getActionName("import")
                onClicked: vaultExportImport("import")
            }
            MenuItem {
                text: getActionName("export")
                onClicked: vaultExportImport("export")
            }
            MenuItem {
                text: getActionName("selectSnapshots")
                onClicked: openShapshotsPage()
                visible: !snapshotsList.empty
            }
        }
    }

    property RemorsePopup remorsePopup: null
    Component {
        id: remorsePopupComponent
        RemorsePopup {
            onTriggered: mainPage.deleteSelectedSnapshots()
            onCanceled: mainPage.deletingSnapshots = null
        }
    }

    function deleteSelectedSnapshots() {
        if (deletingSnapshots == null)
            return;

        for (var i = 0; i < deletingSnapshots.length; ++i) {
            console.log(deletingSnapshots[i])
            backupItem.rmSnapshot(deletingSnapshots[i])
        }
        deletingSnapshots = null
        snapshotsList.clear()
        snapshotsList.load()
    }

    function tryDeleteSelectedSnapshots(items) {
        pageStack.navigateBack()
        deletingSnapshots = items
        if (!remorsePopup)
            remorsePopup = remorsePopupComponent.createObject(mainPage)
        //% "Deleting %n snapshots"
        remorsePopup.execute(qsTrId("vault-me-deleting-snapshots", items.length))
    }

    function openShapshotsPage() {
        var page = pushPage("SnapshotsPage.qml", { "model": snapshotsList.model })
        page.itemsSelected.connect(mainPage.tryDeleteSelectedSnapshots)
    }

    function deferNotification(category, message, activity, options) {
        category = (category === "error")
            ? "x-jolla.vault.error" : "x-jolla.vault.info";
        var notification = Object.create(options || {});
        notification.category = category;
        notification.message = message;
        notification.activity = activity;
        deferredNotification = notification;
    }

    function showDeferredNotification() {
        if (!deferredNotification)
            return;
        var src = deferredNotification;
        if (!src.onlyPreview) {
            notification.body = src.activity;
            notification.summary = src.message;
            notification.category = "x-jolla.vault.error"
        } else {
            notification.category = "x-jolla.vault.transient-error"
        }
        notification.previewBody = src.activity;
        notification.previewSummary = src.message;
        notification.category = src.category;
        deferredNotification = null;
        notification.publish();
    }

    Notification {
        id: notification
    }

    BusyIndicator {
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        running: !backupItem.populated
    }
}
