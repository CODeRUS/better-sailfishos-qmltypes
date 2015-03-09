import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import com.jolla.settings.sync 1.0

/*
  This component allows for the selection of a BluetoothDevice and to pair it if necessary.
  We won't need the majority of this code once the Bluetooth pairing dialog is turned into
  a system dialog, as that will avoid the need for dialog destination redirection.
  */

QtObject {
    id: root

    property QtObject syncEndpointManager: SyncEndpointManager {}
    property var endDestination
    property string pairingAgentName: "/com/jolla/bluetooth_sync_agent"

    signal succeeded(string deviceAddress)
    signal failed()

    function start() {
        if (_pairingManager == null) {
            _pairingManager = _pairingManagerComponent.createObject(root)
        }
        pageStack.push(_pickerDialogComponent)
    }

    property QtObject _pairingManager

    property QtObject _pairingManagerComponent: Component {
        BluetoothPairingManager {
            agentName: root.pairingAgentName

            endDestination: root.endDestination
            endDestinationAction: PageStackAction.Replace

            onPairingSucceeded: {
                root.succeeded(deviceAddress)
            }
            onPairingFailed: {
                console.log("SyncBluetoothPicker: pairing failed")
                root.failed()
            }
        }
    }

    property QtObject _pickerDialogComponent: Component {
        BluetoothDevicePickerDialog {
            id: pickerDialog

            property bool _prepared

            function _prepareDest() {
                if (_prepared) {
                    return
                }
                _prepared = true
                if (selectedDevicePaired) {
                    acceptDestination = root.endDestination
                } else {
                    root._pairingManager.setPrecedingDialog(pickerDialog)
                }
            }

            acceptDestinationAction: PageStackAction.Replace
            excludedDevices: root.syncEndpointManager.bluetoothEndpointAddresses()
            preferredProfileHint: BluetoothProfiles.SyncMLServer

            onAcceptPendingChanged: {
                if (acceptPending) {
                    _prepareDest()
                }
            }

            onAccepted: {
                _prepareDest()
                if (selectedDevicePaired) {
                    root.succeeded(selectedDevice)
                } else {
                    root._pairingManager.pairWithDevice(selectedDevice)
                }
            }
        }
    }
}
