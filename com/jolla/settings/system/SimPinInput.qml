import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.QOfono 0.2

PinInput {
    id: root

    property OfonoSimManager simManager
    property int requestedPinType
    property bool retrying

    property string _currentPinType: enteringNewPin && simManager.isPukType(requestedPinType)
                                     ? simManager.pukToPin(requestedPinType)
                                     : requestedPinType

    minimumLength: simManager.minimumPinLength(_currentPinType)
    maximumLength: simManager.maximumPinLength(_currentPinType)
    modemPath: simManager.modemPath

    titleColor: Theme.rgba(keypadTextColor, 0.6)
    warningTextColor: emergency ? Theme.primaryColor : keypadTextColor
    pinDisplayColor: keypadTextColor
    keypadTextColor: Theme.highlightDimmerColor
    dimmerBackspace: true

    Rectangle {
        z: -1
        anchors.fill: parent
        color: Theme.highlightDimmerColor
        opacity: root.emergency ? 0.0 : 1.0

        Behavior on opacity { FadeAnimation {} }

        Rectangle {
            id: gradient
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.primaryColor }
                GradientStop { position: 1.0; color: Theme.rgba(Theme.primaryColor, 0.4) }
            }
        }
    }

    titleText: {
        switch (requestedPinType) {
        case OfonoSimManager.SimPin:
            return (retrying)
                    //: Displayed when the PIN code has been entered incorrectly
                    //% "Incorrect PIN code"
                    ? qsTrId("settings_pin-he-wrong_pin")
                      //: Request the user to enter a PIN code for SIM access
                      //% "Enter PIN code"
                    : qsTrId("settings_pin-he-enter_pin")
        case OfonoSimManager.SimPuk:
            return (retrying)
                    //: Displayed when the PUK code has been entered incorrectly
                    //% "Incorrect PUK code"
                    ? qsTrId("settings_pin-he-wrong_puk")
                    //: Request the user to enter a PUK code for SIM access
                    //% "Enter PUK code"
                    : qsTrId("settings_pin-he-enter_puk")
        default:
            console.log("SimPinInput: unrecognized PIN/PUK type:", requestedPinType)
            return ""
        }
    }

    warningText: {
        if (enteringNewPin) {
            return ""
        }
        switch (requestedPinType) {
        case OfonoSimManager.SimPin:
            var pinRetries = simManager.pinRetries[requestedPinType]
            if (isNaN(pinRetries) || pinRetries === 0) {
                return ""
            }
            return (pinRetries === 1)
                      //: Warns that the PUK code will be required if this last PIN attempt is incorrect.
                      //% "Only 1 attempt left. If this goes wrong, SIM will be blocked with PUK code."
                    ? qsTrId("settings_pin-la-last_pin_warning")
                      //: Warns about the number of retries available for PIN input
                      //% "%n attempts left"
                    : qsTrId("settings_pin-la-pin_warning", pinRetries)
        case OfonoSimManager.SimPuk:
            var pukRetries = simManager.pinRetries[requestedPinType]
            if (pukRetries === 0) {
                return ""
            }
            return (pukRetries === 1)
                      //: Warns that this is the last available PUK code attempt.
                      //% "Only 1 attempt left. If this goes wrong, SIM card will be permanently locked."
                    ? qsTrId("settings_pin-la-last_puk_warning")         
                    : (pukRetries === undefined)
                        //: Warns that the device has been locked with a PUK code.
                        //% "SIM locked with PUK code. Contact your network service provider for the PUK code."
                      ? qsTrId("settings_pin-la-puk_warning_attempts")
                        //: Warns that the device has been locked with a PUK code (%1 = number of attempts remaining before SIM is permanently locked)
                        //% "%n attempts left. Contact your network service provider for the PUK code."
                      : qsTrId("settings_pin-la-puk_warning_attempts_with_retries", pukRetries)
        default:
            console.log("SimPinInput: unrecognized PIN/PUK type:", requestedPinType)
            return ""
        }
    }

    highlightTitle: simManager.pinRetries[requestedPinType] == 1
}
