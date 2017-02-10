import QtQuick 2.0
import Sailfish.Silica 1.0
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
        pageStack.push(_picker)
    }

    function _cleanUp() {
        if (_endpointToCleanUp != "") {
            _endpointManager.removeEndpoint(_endpointToCleanUp)
            _endpointToCleanUp = ""
        }
    }

    property QtObject _pickerComponent: Component {
        BluetoothDevicePickerDialog {
            requirePairing: true
            preferredProfileHint: BluetoothProfiles.SyncMLServer
            acceptDestination: _importPage
            acceptDestinationAction: PageStackAction.Replace

            onAccepted: {
                var identifier = _endpointManager.findBluetoothEndpoint(selectedDevice)
                if (identifier === "") {
                    identifier = _endpointManager.createBluetoothEndpoint(selectedDevice)
                    if (identifier === "") {
                        console.log("Contacts import error: unable to create Bluetooth sync endpoint!")
                        _importPage.endpointIdError = true
                        return
                    } else {
                        root._endpointToCleanUp = identifier
                    }
                }
                _btSession.startSession()
                _importPage.endpointId = identifier
                _endpointManager.updateSyncEndpoint(identifier,
                                                   SyncEndpoint.DownloadSync,
                                                   SyncEndpoint.SyncContacts,
                                                   SyncEndpointManager.TransferAllData)
                _endpointManager.triggerSync(identifier)
            }

            onRejected: {
                _btSession.endSession()
            }
        }
    }

    property QtObject _importComponent: Component {
        Page {
            property alias endpointId: endpoint.identifier
            property int endpointStatus: endpoint.status
            property bool endpointIdError

            onStatusChanged: {
                if (status == PageStatus.Deactivating) {
                    _btSession.endSession()
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
                        if (endpointIdError) {
                            //: Shown when settings could not be loaded to begin importing contacts
                            //% "Unable to load import settings for the device."
                            return qsTrId("components_contacts-la-import_load_error")
                        }
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
                running: (endpoint.status == SyncEndpoint.UnknownStatus
                          || endpoint.status == SyncEndpoint.Queued
                          || endpoint.status == SyncEndpoint.Syncing)
                         && !endpointIdError
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

    property QtObject _btSession: BluetoothSession {}
}
