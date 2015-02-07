import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.sync 1.0

SilicaListView {
    id: root

    signal endpointClicked(string identifier)
    signal syncClicked(string identifier)
    signal cancelClicked(string identifier)
    signal removeClicked(string identifier)

    // (This context menu entry is not required at the moment, but keep the text here to be translated)
    //: Triggers sync with the sync endpoint
    //% "Sync"
    property string _syncText: qsTrId("settings_sync-me-sync_endpoint")

    model: SyncEndpointModel { }
    delegate: delegateComponent

    VerticalScrollDecorator {}

    Component {
        id: delegateComponent

        ListItem {
            property bool syncInProgress: model.status == SyncEndpoint.Syncing || model.status == SyncEndpoint.Queued
            property bool _prevSyncInProgress

            width: parent.width
            contentHeight: syncEndpointDelegate.height
            menu: menuComponent
            showMenuOnPressAndHold: false

            Component.onCompleted: {
                _prevSyncInProgress = syncInProgress
            }

            SyncEndpointDelegate {
                id: syncEndpointDelegate
                interactive: true
                identifier: model.identifier
                icon: model.icon
                name: model.name
                lastSync: model.lastSync
                status: model.status
            }

            onSyncInProgressChanged: {
                if (_prevSyncInProgress != syncInProgress) {
                    hideMenu()
                }
                _prevSyncInProgress = syncInProgress
            }
            onClicked: {
                if (syncInProgress) {
                    showMenu()
                } else {
                    root.syncClicked(model.identifier)
                }
            }
            onPressAndHold: {
                if (!syncInProgress) {
                    showMenu()
                }
            }
            ListView.onRemove: animateRemoval()

            function removeEndpoint(index) {
                //: Removing this sync endpoint in 5 seconds
                //% "Removing"
                remorseAction(qsTrId("settings_sync-la-removing"),
                              function() { removeClicked(index) })
            }

            Component {
                id: menuComponent
                ContextMenu {
                    MenuItem {
                        //: Stops the data synchronization that is in progress
                        //% "Stop"
                        text: qsTrId("settings_sync-la-stop_sync")
                        visible: syncInProgress
                        onClicked: {
                            if (syncInProgress) {
                                root.cancelClicked(model.identifier)
                            }
                        }
                    }

                    MenuItem {
                        //: Removes the sync endpoint
                        //% "Remove"
                        text: qsTrId("settings_sync-me-remove_endpoint")
                        visible: !syncInProgress
                        onClicked: removeEndpoint(model.identifier)
                    }
                }
            }
        }
    }
}
