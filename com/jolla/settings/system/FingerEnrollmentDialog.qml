import QtQuick 2.2
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

MandatoryDeviceLockInputPage {
    id: page

    property FingerprintSensor settings
    property variant authenticationToken
    property Component destination

    function goTo(target) {
        pageStack.replace(target, {
            "settings": settings,
            "authenticationToken": authenticationToken,
            "destination": destination
        })
    }

    backNavigation: false
    authorization: settings ? settings.authorization : null

    onAuthenticated: {
        // OK, open change code UI query
        page.authenticationToken = authenticationToken
        page.goTo(Qt.resolvedUrl("FingerEnrollmentProgressPage.qml"))
    }

    onCanceled: {
        pageStack.pop()
    }

    onStatusChanged: {
        if (status === PageStatus.Active) {
            switch (authorization.status) {
            case Authorization.ChallengeIssued:
                page.authenticate()
                break
            case Authorization.NoChallenge:
                authorization.requestChallenge()
                break
            default:
                break
            }
        }
    }

    Connections {
        target: page.settings.authorization

        onChallengeIssued: page.authenticate()
        onChallengeDeclined: {
            pageStack.replace(Qt.resolvedUrl("FingerEnrollmentProgressPage.qml"), {
                "settings": settings,
                "authenticationToken": authenticationToken,
                "_finished": true,
                "_failed": true,
                "forwardNavigation": true,
                "destination": destination,
                //% "The system is unable to acquire permissions to register a finger print."
                "explanation": qsTrId("settings_devicelock-la-fingerprint_error_no_challenge_explanation")
            })
        }
    }
}
