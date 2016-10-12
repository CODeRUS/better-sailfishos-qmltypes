import QtQuick 2.2
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

Page {
    id: page

    property FingerprintSettings settings
    property variant authenticationToken
    property Component destination

    property string _enteredPin

    function goTo(target) {
        pageStack.replace(target, {
            "settings": settings,
            "authenticationToken": authenticationToken,
            "destination": destination
        })
    }

    backNavigation: false

    onStatusChanged: {
        if (status == PageStatus.Active && !pinInput.enteringNewPin) {
            switch (page.settings.authorization.status) {
            case Authorization.ChallengeIssued:
                deviceLock.authenticate(
                            page.settings.authorization.challengeCode,
                            page.settings.authorization.allowedMethods)
                break
            case Authorization.NoChallenge:
                page.settings.authorization.requestChallenge()
                break
            default:
                break
            }
        } else if (deviceLock.authenticating) {
            deviceLock.cancel()
        }
    }

    LockCodeSettings {
        id: lockCode
    }

    DeviceLockInput {
        id: pinInput

        showOkButton: pinInput.enteringNewPin
                    || page.settings.authorization.status == Authorization.ChallengeIssued
        showEmergencyButton: false

        authenticator: Authenticator {
            id: deviceLock

            onAuthenticated: {
                // OK, open change code UI query
                pinInput._badPinWarning = ""

                page.authenticationToken = authenticationToken
                page.goTo(Qt.resolvedUrl("FingerEnrollmentProgressPage.qml"))
            }
        }

        Component.onCompleted: {
            if (!lockCode.set) {
                //: Inital setup of lock code
                //% "Set your lock code"
                _overridingWarningText = qsTrId("settings_devicelock-la-devicelock_set_lock_code.")
                requestAndConfirmNewPin()
            }
        }

        onPinConfirmed: {
            if (enteringNewPin) {
                lockCode.change("", enteredPin)
                page._enteredPin = enteredPin
                page.settings.authorization.requestChallenge()
            } else {
                deviceLock.enterLockCode(enteredPin)
            }
        }

        onPinEntryCanceled: {
            clear()
            pageStack.pop()
        }
    }

    Connections {
        target: page.settings.authorization

        onChallengeIssued: {
            deviceLock.authenticate(page.settings.authorization.challengeCode, Authenticator.LockCode)

            if (pinInput.enteringNewPin) {
                deviceLock.enterLockCode(page._enteredPin)
            }
        }

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
