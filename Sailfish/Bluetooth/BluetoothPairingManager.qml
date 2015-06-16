import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import org.nemomobile.notifications 1.0

BluetoothAgent {
    id: root

    property string agentName
    property string deviceAddress

    property var endDestination
    property int endDestinationAction: PageStackAction.Push
    property var endDestinationProperties: ({})

    property bool _pairingInProgress
    property QtObject _pairingDialog
    property string _pendingAuthPasskey
    property bool _usingDefaultPin
    property bool _canRetry
    property bool _hasPrecedingDialog

    signal pairingSucceeded()
    signal pairingFailed(int errorCode)

    function pairWithDevice(addr) {
        if (_pairingInProgress) {
            console.log("BluetoothPairingManager: cannot start pairing, another pairing in progress")
            return
        }
        _pairingInProgress = true
        deviceAddress = addr
        _adapter.startSession()

        if (!_hasPrecedingDialog) {
            _createPairingDialog()
            pageStack.push(_pairingDialog)
        }

        if (!_adapter.ready) {
            _adapter.readyChanged.connect(_adapterReadyChanged)
        } else {
            _adapter.createPairing(deviceAddress, agentName)
        }
    }

    function setPrecedingDialog(dialog) {
        if (_pairingInProgress) {
            console.log("BluetoothPairingManager: cannot start pairing, another pairing in progress")
            return
        }
        if (_hasPrecedingDialog) {
            console.log("BluetoothPairingManager: setPrecedingDialog() failed, already called")
            return
        }
        _createPairingDialog()
        dialog.acceptDestination = _pairingDialog
        _hasPrecedingDialog = true
    }

    function _adapterReadyChanged() {
        if (_adapter.ready) {
            _adapter.readyChanged.disconnect(_adapterReadyChanged)
            _adapter.createPairing(deviceAddress, agentName)
        }
    }

    function _createPairingDialog() {
        if (_pairingDialog != null) {
            _pairingDialog.accepted.disconnect(_pairingDialogAccepted)
            _pairingDialog.rejected.disconnect(_pinPasskeyDialogRejected)
            _pairingDialog.destroy()
            _pairingDialog = null
        }
        _pairingDialog = _pairingDialogComponent.createObject(root)
        _pairingDialog.accepted.connect(_pairingDialogAccepted)
        _pairingDialog.rejected.connect(_pinPasskeyDialogRejected)
    }

    function _retryPairing() {
        if (_pendingAuthPasskey !== "" && _canRetry) {
            _adapter.createPairing(deviceAddress, agentName)
        }
    }

    function _finishedPairing(error) {
        if (!_pairingInProgress) {
            return
        }
        // Prompt user to enter a new PIN if the other device says there was a pin/passkey mismatch
        if (error == BluetoothAdapter.PairingAuthenticationFailed
                && _pairingDialog != null
                && (_pairingDialog.mode == BluetoothAgent.EnterPasskey || _pairingDialog.mode == BluetoothAgent.EnterPin)
                && _pairingDialog.result == DialogResult.None) {
            _pairingDialog.forceUserChangePasskey(!_usingDefaultPin)
            return
        }

        var errorMsg = ""
        switch (error) {
        case BluetoothAdapter.NoPairingError:
            var device = _knownDevicesModel.bluetoothDeviceForAddress(deviceAddress)
            if (device != null) {
                if (_pairingDialog != null && _pairingDialog.mode < 0) {
                    // a just-works pairing has succeeded without any user intervention
                    _pairingDialog.justWorksPairingSucceeded(device)
                    _pairingDialog.accepted.connect(function() {
                        device.trusted = _pairingDialog.allowAutoConnect
                    })
                }
            }
            // Note we don't auto-accept the pairing dialog; we want to ensure the user has made
            // a selection in the device type combo box if necessary before accepting.
            break
        case BluetoothAdapter.PairingCanceled: {
            // leave some time before trying to pair again with the new passkey, else both
            // devices may not be prepared
            _retryPairingTimer.start()
            break
        }
        case BluetoothAdapter.PairingAuthenticationFailed:
            //: Shown when a bluetooth pairing was attempted but the passkeys did not match
            //% "Pairing authentication failed. The passkeys did not match."
            errorMsg = qsTrId("components_bluetooth-la-pairing_error_passkey_mismatch")
            break
        case BluetoothAdapter.PairingAuthenticationRejected:
            //: Shown when a bluetooth pairing was attempted but the other device canceled (rejected) the request
            //% "The selected device canceled the pairing request."
            errorMsg = qsTrId("components_bluetooth-la-pairing_error_rejected")
            break
        case BluetoothAdapter.PairingConnectionFailed:
            //: Shown when a bluetooth pairing was attempted but we were unable to connect to the other device
            //% "Could not connect to the selected device. Make sure it has Bluetooth enabled and try again."
            errorMsg = qsTrId("components_bluetooth-la-pairing_error_connection_failed")
            break
        case BluetoothAdapter.PairingTimeout:
            //: Shown when a bluetooth pairing was attempted but there was no response from the other device
            //% "The selected device did not respond to the pairing request."
            errorMsg = qsTrId("components_bluetooth-la-pairing_error_timeout")
            break
        case BluetoothAdapter.UnknownPairingError:
            break
        default:
            console.log("BluetoothSettings: unexpected pairing mode value:", error)
        }
        if (_pairingDialog != null
                && error !== BluetoothAdapter.NoPairingError
                && error !== BluetoothAdapter.PairingCanceled) {
            if (_pairingDialog.result === DialogResult.Accepted) {
                // We got an error even though the dialog was accepted. This means the other side
                // rejected the pairing, then we accepted it, so bluez sends us AuthenticationFailed.

                //: Short error message shown when a bluetooth pairing attempt failed
                //% "Pairing failed"
                _notification.previewBody = qsTrId("components_bluetooth-la-pairing_failed_short")
                _notification.publish()
            } else if (_pairingDialog.result !== DialogResult.Rejected) {
                if (errorMsg == "") {
                    //: Generic error description shown when a bluetooth pairing attempt failed
                    //% "Unable to pair with the selected device."
                    errorMsg = qsTrId("components_bluetooth-la-pairing_error_unknown")
                }
                _pairingDialog.errorMessage = errorMsg
            }
        }
        _pairingInProgress = false
        _hasPrecedingDialog = false
        _adapter.endSession()
        if (error == BluetoothAdapter.NoPairingError) {
            pairingSucceeded()
        } else {
            pairingFailed(error)
        }
    }

    function _setPairingParameters(params) {
        if (_pairingDialog != null) {
            for (var prop in params) {
                _pairingDialog[prop] = params[prop]
            }
        }
    }

    function _loadPasskeyOrPinPairing(mode, deviceAddress, deviceClass, deviceName) {
        if (_pairingDialog === null) {
            console.log("Bluetooth pairing dialog not created")
            return
        }
        if (_pendingAuthPasskey === "") {
            var passkey = ""
            if (mode === BluetoothAgent.EnterPasskey) {
                var passkeyAsInt = generatePasskey()
                passkey = "" + passkeyAsInt
                replyPasskey(passkeyAsInt)
            } else {
                // Older devices with no display (e.g. mouse) are likely to use PIN code
                // authentication with a 0000 PIN, so try authenticating with this, and
                // user can retry with a different PIN if it doesn't work.
                passkey = "0000"
                _usingDefaultPin = true
                replyRequestPidCode(passkey)
            }
            var params = {
                "mode": mode,
                "deviceAddress": deviceAddress,
                "deviceClass": deviceClass,
                "deviceName": deviceName,
                "passkey": passkey,
                "allowPasskeyChange": _pendingAuthPasskey == ""
            }
            _setPairingParameters(params)
            _pendingAuthPasskey = ""
            _pairingDialog.passkeyChangePending.connect(_passkeyChangePending)
            _pairingDialog.passkeyChangeRequested.connect(_passkeyChangeRequested)
        } else {
            // retry with the new passkey
            if (mode === BluetoothAgent.EnterPasskey) {
                replyPasskey(parseInt(_pendingAuthPasskey))
            } else {
                replyRequestPidCode(_pendingAuthPasskey)
            }
            _pendingAuthPasskey = ""
        }
    }

    function _loadConfirmationPairing(mode, deviceAddress, deviceClass, deviceName, passkey) {
        if (_pairingDialog === null) {
            return
        }
        var params = {
            "mode": mode,
            "deviceAddress": deviceAddress,
            "deviceClass": deviceClass,
            "deviceName": deviceName,
            "passkey": passkey
        }
        _setPairingParameters(params)
    }

    function _passkeyChangePending() {
        _canRetry = false
        _pendingAuthPasskey = ""
        _adapter.cancelCreatePairing(deviceAddress)
    }

    function _passkeyChangeRequested(newPasskey) {
        // try to pair again with the new passkey
        _usingDefaultPin = false
        _pendingAuthPasskey = newPasskey
        _retryPairing()
    }

    function _pairingDialogAccepted() {
        if (!_pairingDialog) {
            return
        }
        // Only need to send a reply here for Compare mode; in pin/passkey entry modes, we
        // will have already replied with the passkey when the dialog was opened.
        if (_pairingDialog.mode === BluetoothAgent.Compare) {
            replyRequestConfirmation(true)
        }
        var device = _knownDevicesModel.bluetoothDeviceForAddress(deviceAddress)
        if (device) {
            device.trusted = _pairingDialog.allowAutoConnect
        }
    }

    function _pinPasskeyDialogRejected() {
        if (_pairingInProgress) {
            _adapter.cancelCreatePairing(deviceAddress)
            _pendingAuthPasskey = ""
        }
        // User may cancel the dialog even after the pairing has been established. In that
        // case, we won't remove the pairing, as other side will think the pairing has been
        // successfully, so it wouldn't make sense to remove the newly created pairing due
        // to the dialog being rejected.
    }

    name: agentName

    onDisplayPasskey: {
        _loadConfirmationPairing(BluetoothAgent.DisplayPasskey, deviceAddress, deviceClass, deviceName, normalizePasskey(key))
    }
    onRequestConfirmation: {
        _loadConfirmationPairing(BluetoothAgent.Compare, deviceAddress, deviceClass, deviceName, normalizePasskey(key))
    }
    onRequestPasskey: {
        _loadPasskeyOrPinPairing(BluetoothAgent.EnterPasskey, deviceAddress, deviceClass, deviceName)
    }
    onRequestPidCode: {
        _loadPasskeyOrPinPairing(BluetoothAgent.EnterPin, deviceAddress, deviceClass, deviceName)
    }
    onCanceledRequest: {
        // DisplayPasskey request was canceled, so show an error message.
        _finishedPairing(BluetoothAdapter.PairingAuthenticationRejected)
    }

    property QtObject _adapter: BluetoothAdapter {
        onCreatePairingFinished: {
            root._finishedPairing(error)
        }
    }

    property QtObject _knownDevicesModel: KnownDevicesModel { }

    property QtObject _retryPairingTimer: Timer {
        interval: 1000
        onTriggered: {
            if (root._pairingInProgress) {
                root._canRetry = true
                root._retryPairing()
            }
        }
    }

    property QtObject _notification: Notification {
        category: "x-jolla.settings.bluetooth"
    }

    property QtObject _pairingDialogComponent: Component {
        BluetoothPairingDialog {
            requestDirection: BluetoothAgent.OutgoingPairingRequest

            acceptDestination: root.endDestination
            acceptDestinationAction: root.endDestinationAction
            acceptDestinationProperties: root.endDestinationProperties
        }
    }
}
