import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.devicelock 1.0

Page {
    id: page

    backNavigation: false

    property alias titleText: devicelockinput.titleText
    property alias subTitleText: devicelockinput.subTitleText
    property alias warningText: devicelockinput.warningText
    property alias enterNewPinText: devicelockinput.enterNewPinText
    property alias confirmNewPinText: devicelockinput.confirmNewPinText
    property alias showCancelButton: devicelockinput.showCancelButton
    property alias okText: devicelockinput.okText
    property alias cancelText: devicelockinput.cancelText

    function displayError(error) {
        devicelockinput.displayError(error)
    }

    DeviceLockInput {
        id: devicelockinput

        authenticationInput: AuthenticationInput {
            id: authentication

            active: true
            registered: true

            onAuthenticationStarted: {
                devicelockinput._badPinWarning = ""
                devicelockinput.displayFeedback(feedback, data)
            }
            onAuthenticationUnavailable: devicelockinput.displayError(error)
        }

        //% "Confirm with security code"
        titleText: qsTrId("settings_devicelock-he-security_code_confirm_title")
        //% "Confirm"
        okText: qsTrId("settings_devicelock-bt-devicelock_confirm")

        showOkButton: authentication.status == AuthenticationInput.Authenticating
        showEmergencyButton: false
    }
}
