import QtQuick 2.0
import Sailfish.Silica 1.0
import NemoMobile.Vault 1.0
import "./Assoc.js" as SnapshotIndex

SilicaListView {

    id: snapshotsList

    property bool enabled: true
    property Item restoreItem: null
    property bool empty: !model || model.count == 0
    property real contentWidth: width
    property real contentMargin: Theme.horizontalPageMargin

    signal error(variant err)

    ListModel {
        id: snapshots
    }

    model: snapshots

    Component {
        id: menuComponent

        ContextMenu {
            id: snapshotMenu
            property string tag

            MenuItem {
                //% "Restore"
                text: qsTrId("vault-me-restore")
                onClicked: restoreItem.startRestore(tag)
            }
            MenuItem {
                //% "Delete"
                text: qsTrId("vault-me-delete")
                onClicked: snapshotMenu.parent.maybeDeleteSnapshot()
            }
        }
    }

    function clear() {
        snapshots.clear();
        SnapshotIndex.clear();
    }

    property bool loading:false
    Connections {
        target: vault
        onDone: {
            if (loading && operation == Vault.Connect) {
                snapshotsList.state = "enabled";
                loadData();
            }
        }
        onError: {
            if (loading && operation == Vault.Connect) {
                loading = false;
                snapshotlist.error(error);
            }
        }
    }

    function loadData() {
        var add_snapshot = function(s, n) {
            console.log("add",s, n);
            if (SnapshotIndex.get(s) !== undefined)
                return;

            snapshots.append({name: s, note: n});
            SnapshotIndex.set(s, snapshots.count - 1);
        };

        var res = vault.snapshots();
        var i;
        res.reverse();
        console.log(res);
        for (i = 0; i < res.length; ++i) {
            add_snapshot(res[i], vault.notes(res[i]));
        }
    }


    function load() {
        var api, latest_idx;

        loading = true;
        vault.connectVault(false);
    }

    delegate: SnapshotItem {
        menu: menuComponent
        width: snapshotsList.contentWidth
        anchors.horizontalCenter: parent.horizontalCenter
        contentMargin: snapshotsList.contentMargin
    }

    VerticalScrollDecorator {}
}
