import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

QtObject {
    id: query

    property QtObject _authorization
    property var _authenticated
    property var _canceled

    readonly property bool lockCodeSet: deviceLock.availableMethods & Authenticator.LockCode

    function authenticate(authorization, onAuthenticated, onCanceled) {
        query._authorization = authorization
        query._authenticated = onAuthenticated
        query._canceled = onCanceled

        switch (authorization.status) {
        case Authorization.NoChallenge:
            authorization.requestChallenge()
            break
        case Authorization.ChallengeIssued:
            _handleChallenge()
            break
        default:
            break
        }
    }

    function _handleChallenge() {
        if (deviceLock.availableMethods !== 0) {
            pageStack.push(inputPage)
        } else {
            // No lock code is set so don't display the UI, but authenticate anyway to acquire
            // an authentication token for the challenge code.
            deviceLock.authenticate(query._authorization.challengeCode)
        }
    }

    property list<QtObject> _data: [
        Authenticator {
            id: deviceLock

            onAuthenticated: {
                var authenticated = query._authenticated
                query._authenticated = undefined
                query._canceled = undefined
                query._authorization = null

                authenticated(authenticationToken)
            }
        },

        Connections {
            target: query._authorization

            onChallengeIssued: query._handleChallenge()
            onChallengeDeclined: {
                var canceled = query._canceled
                query._authenticated = undefined
                query._canceled = undefined
                query._authorization = null

                if (_canceled) {
                    _canceled()
                }
            }
        },

        Component {
            id: inputPage

            Page {
                id: page

                property QtObject authorization

                backNavigation: false
                opacity: status === PageStatus.Active ? 1.0 : 0.0

                onStatusChanged: {
                    if (status == PageStatus.Active) {
                        deviceLock.authenticate(
                                    query._authorization.challengeCode,
                                    query._authorization.allowedMethods)
                    } else if (deviceLock.authenticating) {
                        deviceLock.cancel()
                    }
                }

                DeviceLockInput {
                    id: devicelockinput

                    authenticator: deviceLock

                    //% "Confirm with lock code"
                    titleText: qsTrId("settings_devicelock-he-lock_code_confirm_title")
                    //% "Confirm"
                    okText: qsTrId("settings_devicelock-bt-devicelock_confirm")

                    showEmergencyButton: false

                    onPinEntryCanceled: {
                        var canceled = query._canceled
                        var authorization = query._authorization
                        query._authenticated = undefined
                        query._canceled = undefined
                        query._authorization = null

                        clear()

                        authorization.relinquishChallenge()
                        if (canceled) {
                            canceled()
                        } else {
                            pageStack.pop()
                        }
                    }

                    onPinConfirmed: deviceLock.enterLockCode(enteredPin)
                }
            }
        }
    ]
}
