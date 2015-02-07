import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import com.jolla.settings.sync 1.0

Page {
    id: root

    property QtObject _bluetoothPicker
    property int _baseStackDepth: -1
    property var _objectsToDestroy: []

    function _removeEndpoint(identifier) {
        //: Deleting this account in 5 seconds
        //% "Removing"
        remorsePopup.execute(qsTrId("settings_sync-la-removing"),
                             function() { endpointManager.removeEndpoint(identifier) } )
    }

    function _startSync(identifier) {
        syncingEndpointComponent.createObject(root, {"identifier": identifier})
    }

    function _finishSync(obj) {
        _objectsToDestroy.push(obj)
        delayedDestroyTimer.start()
    }

    Timer {
        id: delayedDestroyTimer
        interval: 1
        onTriggered: {
            var objects = root._objectsToDestroy
            root._objectsToDestroy = []
            for (var i=0; i<objects.length; i++) {
                objects[i].destroy()
            }
        }
    }

    onStatusChanged: {
        if (status == PageStatus.Active) {
            if (_baseStackDepth < 1) {
                _baseStackDepth = pageStack.depth
                btAdapter.holdSession()
            }
        } else if (status == PageStatus.Inactive) {
            if (_baseStackDepth >= 0 && pageStack.depth < _baseStackDepth) {
                btAdapter.releaseSession()
                _baseStackDepth = -1
            }
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (Qt.application.active) {
                btAdapter.holdSession()
            } else {
                btAdapter.releaseSession()
            }
        }
    }

    RemorsePopup {
        id: remorsePopup
    }

    SyncEndpointManager {
        id: endpointManager
    }

    BluetoothAdapter {
        id: btAdapter
    }

    Component {
        id: syncingEndpointComponent
        SyncEndpoint {
            id: syncEndpoint
            property bool _syncStarted
            property bool _calledFinish

            onStatusChanged: {
                if (_syncStarted && !_calledFinish
                        && (status == SyncEndpoint.Succeeded
                            || status == SyncEndpoint.Canceled
                            || status == SyncEndpoint.Failed)) {
                    root._finishSync(syncEndpoint)
                    _calledFinish = true
                }
            }

            Component.onCompleted: {
                btAdapter.startSession()
                endpointManager.triggerSync(identifier)
                _syncStarted = true
            }
            Component.onDestruction: {
                btAdapter.endSession()
            }
        }
    }

    SyncEndpointList {
        id: endpointsView
        anchors.fill: parent

        header: PageHeader {
            //: Heading of the Bluetooth Sync settings page
            //% "Bluetooth sync"
            title: qsTrId("settings_sync-he-bluetooth_sync")
        }

        PullDownMenu {
            MenuItem {
                //: Initiates adding a new sync endpoint
                //% "Add new device"
                text: qsTrId("settings_sync-me-add_device")
                onClicked: {
                    if (_bluetoothPicker == null) {
                        _bluetoothPicker = bluetoothPickerComponent.createObject(root)
                    }
                    _bluetoothPicker.start()
                }
            }
        }

        ViewPlaceholder {
            enabled: endpointsView.count == 0
            //: Description of what the Sync settings page is used for
            //% "Sync enables you to get contacts from another Bluetooth device"
            text: qsTrId("settings_sync-he-bluetooth_sync_contacts_download")
            //: Hint to the user that they can perform a sync by using the pulley menu
            //% "Pull down to add a device"
            hintText: qsTrId("settings_sync-he-pull_down_to_add_device")
        }

        onEndpointClicked: {
            pageStack.push(settingsComponent, {"identifier": identifier})
        }

        onSyncClicked: {
            root._startSync(identifier)
        }

        onCancelClicked: {
            endpointManager.abortSync(identifier)
        }

        onRemoveClicked: {
            endpointManager.removeEndpoint(identifier)
        }
    }

    Component {
        id: bluetoothPickerComponent
        SyncBluetoothPicker {
            syncEndpointManager: endpointManager
            onSucceeded: {
                var identifier = endpointManager.createBluetoothEndpoint(deviceAddress)
                endpointManager.updateSyncEndpoint(identifier,
                                                   SyncEndpoint.DownloadSync,
                                                   SyncEndpoint.SyncContacts,
                                                   SyncEndpointManager.TransferAllData)
                root._startSync(identifier)
            }
        }
    }
}
