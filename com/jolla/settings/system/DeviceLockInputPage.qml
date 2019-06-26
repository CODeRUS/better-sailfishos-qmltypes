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

    DeviceLockInput {
        id: devicelockinput

        authenticationInput: AuthenticationInput {
            id: authentication

            active: true
            registered: true

            signal reset()

            onAuthenticationStarted: {
                reset()
                authentication.feedback(feedback, data)
            }
            onAuthenticationUnavailable: {
                reset()
                authentication.error(error, data)
            }
        }

        showOkButton: authentication.status === AuthenticationInput.Authenticating
        showEmergencyButton: false
    }
}
