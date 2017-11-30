import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.devicelock 1.0

DeviceLockInputPage {
    id: page

    property QtObject authorization
    property alias lockCodeSet: securityCode.set

    signal authenticated(variant authenticationToken)
    signal canceled()

    function authenticate() {
        if (securityCode.set) {
            authenticator.authenticate(authorization.challengeCode, authorization.allowedMethods)
        } else {
            securityCode.change(authorization.challengeCode)
        }
    }

    warningText: lockCodeSet
            ? ""
            //: Initial setup of security code
            //% "Set your security code"
            : qsTrId("settings_devicelock-la-devicelock_set_security_code")

    Authenticator {
        id: authenticator

        onAuthenticated: page.authenticated(authenticationToken)
        onAborted: page.canceled()
    }

    SecurityCodeSettings {
        id: securityCode

        onChanged: page.authenticated(authenticationToken)
        onChangeAborted: page.canceled()
    }
}
