import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.notifications 1.0
import MeeGo.QOfono 0.2

Item {
    id: root

    property alias enteredPin: pinInput.enteredPin
    property alias modemPath: ofonoSimManager.modemPath
    property alias showCancelButton: pinInput.showCancelButton
    property alias cancelText: pinInput.cancelText

    property int _confirmedPinType
    property string _enteredPuk

    signal done(bool success)
    signal pinEntryCanceled()
    signal simPermanentlyLocked()

    width: parent.width
    height: parent.height

    function clear() {
        pinInput.clear()
    }

    function _finishedPinAction(error, errorString) {
        switch (error) {
        case OfonoSimManager.NotImplementedError:
        case OfonoSimManager.UnknownError:
            pinInput.retrying = false
            done(false)
            break
        case OfonoSimManager.InProgressError:
            break
        case OfonoSimManager.InvalidArgumentsError:
        case OfonoSimManager.InvalidFormatError:
        case OfonoSimManager.FailedError:
            pinInput.retrying = true
            pinInput.clear()
            break
        case OfonoSimManager.NoError:
            notification.previewBody = ""
            if (_confirmedPinType === OfonoSimManager.ServiceProviderPersonalizationPin) {
                //: Indicates that the user entered the correct operator unlock code.
                //% "Unlock code correct"
                notification.previewBody = qsTrId("settings_pin-la-notify_correct_unlock_code")
            } else if (ofonoSimManager.isPukType(_confirmedPinType)) {
                //: Indicates that the user entered the correct PUK (Pin Unblocking Key).
                //% "PUK code correct"
                notification.previewBody = qsTrId("settings_pin-la-notify_correct_puk")
            } else {
                // no notification after the user entered the correct PIN
            }
            if (notification.previewBody.length > 0) {
                notification.publish()
            }

            pinInput.retrying = false
            done(true)
            break
        }
    }

    OfonoSimManager {
        id: ofonoSimManager

        onEnterPinComplete: _finishedPinAction(error, errorString)
        onResetPinComplete: _finishedPinAction(error, errorString)

        onPinRequiredChanged: {
            // reset the title text when changing from PIN -> PUK auth
            if (pinRequired === OfonoSimManager.SimPuk) {
                pinInput.retrying = false
            }
        }

        onPinRetriesChanged: {
            for (var pinType in pinRetries) {
                if (pinType === OfonoSimManager.SimPuk.toString() && pinRetries[pinType] === 0) {
                    root.simPermanentlyLocked()
                }
            }
        }
    }

    SimPinInput {
        id: pinInput

        simManager: ofonoSimManager
        requestedPinType: ofonoSimManager.pinRequired

        onPinConfirmed: {
            root._confirmedPinType = ofonoSimManager.pinRequired

            if (ofonoSimManager.isPukType(ofonoSimManager.pinRequired)) {
                if (root._enteredPuk === "") {
                    // PUK has been entered, now ask user for the new PIN so it can be reset
                    root._enteredPuk = enteredPin
                    requestAndConfirmNewPin()
                } else {
                    ofonoSimManager.resetPin(ofonoSimManager.pinRequired, root._enteredPuk, enteredPin)
                    root._enteredPuk = ""
                }
            } else {
                ofonoSimManager.enterPin(ofonoSimManager.pinRequired, enteredPin)
            }
        }

        onPinEntryCanceled: root.pinEntryCanceled()
    }

    Notification {
        id: notification
        category: "x-nemo.pin.authresult"
    }
}
