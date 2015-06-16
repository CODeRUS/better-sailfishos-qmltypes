import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0
import Sailfish.Bluetooth 1.0
import com.jolla.settings.sync 1.0

QtObject {
    id: root

    property Item _importPage
    property QtObject _picker
    property string _endpointToCleanUp

    function start() {
        if (_importPage == null) {
            _importPage = _importComponent.createObject(root)
        }
        if (_picker == null) {
            _picker = _pickerComponent.createObject(root)
        }
        _cleanUp()
        _importPage.autoDismiss = false
        _picker.start()
    }

    function _cleanUp() {
        if (_endpointToCleanUp != "") {
            _endpointManager.removeEndpoint(_endpointToCleanUp)
            _endpointToCleanUp = ""
        }
    }

    property QtObject _pickerComponent: Component {
        SyncBluetoothPicker {
            endDestination: _importPage
            pairingAgentName: "/com/jolla/bluetooth_contact_import"

            onSucceeded: {
                if (!_importPage) {
                    return
                }
                var identifier = _endpointManager.findBluetoothEndpoint(deviceAddress)
                if (identifier === "") {
                    identifier = _endpointManager.createBluetoothEndpoint(deviceAddress)
                    if (identifier === "") {
                        console.log("Contacts import error: unable to create Bluetooth sync endpoint!")
                        _importPage.autoDismiss = true
                        return
                    } else {
                        root._endpointToCleanUp = identifier
                    }
                }
                _btAdapter.startSession()
                _importPage.endpointId = identifier
                _endpointManager.updateSyncEndpoint(identifier,
                                                   SyncEndpoint.DownloadSync,
                                                   SyncEndpoint.SyncContacts,
                                                   SyncEndpointManager.TransferAllData)
                _endpointManager.triggerSync(identifier)
            }

            onFailed: {
                if (_importPage) {
                    _importPage.autoDismiss = true
                }

            }
        }
    }

    property QtObject _importComponent: Component {
        Page {
            property bool autoDismiss
            property alias endpointId: endpoint.identifier

            onStatusChanged: {
                if (status == PageStatus.Active && autoDismiss) {
                    pageStack.pop()
                } else if (status == PageStatus.Deactivating) {
                    _btAdapter.endSession()
                }
            }

            onAutoDismissChanged: {
                if (status == PageStatus.Active && autoDismiss) {
                    pageStack.pop()
                }
            }

            Component.onDestruction: {
                root._cleanUp()
            }

            SyncEndpoint {
                id: endpoint
            }

            Column {
                x: Theme.paddingLarge
                y: Theme.itemSizeLarge
                width: parent.width - x*2

                Label {
                    width: parent.width
                    height: implicitHeight + Theme.paddingLarge
                    color: Theme.highlightColor
                    font.pixelSize: Theme.fontSizeExtraLarge
                    wrapMode: Text.Wrap

                    //% "Import contacts"
                    text: qsTrId("components_contacts-la-import_contacts")
                }

                Label {
                    width: parent.width
                    height: implicitHeight + Theme.paddingLarge
                    color: Theme.rgba(Theme.highlightColor, 0.6)
                    wrapMode: Text.Wrap
                    textFormat: Text.AutoText
                    font.pixelSize: Theme.fontSizeSmall
                    text: {
                        switch (endpoint.status) {
                        case SyncEndpoint.UnknownStatus:
                        case SyncEndpoint.Queued:
                            //: Shown while preparing to import contacts
                            //% "Waiting to import..."
                            return qsTrId("components_contacts-la-waiting_to_import")
                        case SyncEndpoint.Syncing:
                            //: Shown while receiving contacts from another device
                            //% "Receiving contacts..."
                            return qsTrId("components_contacts-la-receiving_contacts")
                        case SyncEndpoint.Succeeded:
                            //% "Contacts successfully imported."
                            return qsTrId("components_contacts-la-contacts_import_ok")
                        case SyncEndpoint.Canceled:
                            //% "Unable to complete contacts import."
                            return qsTrId("components_contacts-la-import_canceled")
                        case SyncEndpoint.Failed:
                            //% "Unable to import contacts from the other device.<br><br>Make sure it has Bluetooth turned on and verify it provides SyncML services."
                            return qsTrId("components_contacts-la-import_error")
                        }
                    }
                }

                Item {
                    width: 1
                    height: Theme.itemSizeExtraSmall
                }

                Button {
                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: endpoint.status == SyncEndpoint.Failed

                    //: The last import attempt failed, so allow user to try again
                    //% "Try again"
                    text: qsTrId("components_contacts-bt-try_import_again")

                    onClicked: {
                        _endpointManager.triggerSync(endpoint.identifier)
                    }
                }
            }

            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                size: BusyIndicatorSize.Large
                running: endpoint.status == SyncEndpoint.UnknownStatus
                         || endpoint.status == SyncEndpoint.Queued
                         || endpoint.status == SyncEndpoint.Syncing
            }

            Button {
                anchors {
                    bottom: parent.bottom
                    bottomMargin: Theme.paddingLarge
                    horizontalCenter: parent.horizontalCenter
                }
                opacity: endpoint.status == SyncEndpoint.Succeeded ? 1 : 0
                Behavior on opacity { FadeAnimation {} }

                //% "View all contacts"
                text: qsTrId("components_contacts-la-view_all_contact")

                onClicked: {
                    pageStack.pop()
                }
            }
        }
    }

    property QtObject _endpointManager: SyncEndpointManager {}

    property QtObject _btAdapter: BluetoothAdapter {}
}
