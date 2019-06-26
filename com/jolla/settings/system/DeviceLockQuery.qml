import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.devicelock 1.0

QtObject {
    id: query

    property QtObject _authorization
    property var _authenticated
    property var _canceled
    property var _delayedAction
    property alias _availableMethods: deviceLock.availableMethods

    // TODO: could be made opt-out if we get a chance to update sailfish-utilities usage
    property bool returnOnCancel
    property bool returnOnAccept

    function authenticate(authorization, onAuthenticated, onCanceled) {
        query._authorization = authorization
        query._authenticated = onAuthenticated
        query._canceled = onCanceled

        switch (authorization.status) {
        case Authorization.NoChallenge:
            authorization.requestChallenge()
            break
        case Authorization.ChallengeIssued:
            deviceLock.authenticate(authorization.challengeCode, authorization.allowedMethods)
            break
        default:
            break
        }
    }

    function cancel() {
        deviceLock.cancel()

        var canceled = query._canceled
        query._authenticated = undefined
        query._canceled = undefined
        query._authorization = null

        if (canceled)
            canceled()
    }

    function _aborted() {
        var canceled = query._canceled
        query._authenticated = undefined
        query._canceled = undefined
        query._authorization = null

        _runWhenPageStackNotBusy(function() {
            if (canceled) {
                canceled()
            }

            if (returnOnCancel) {
                pageStack.pop()
            }
        })
    }

    function _runWhenPageStackNotBusy(action) {
        if (pageStack.busy) {
            query._delayedAction = action
        } else {
            query._delayedAction = undefined
            action()
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

        AuthenticationInput {
            id: authentication

            registered: true

            onAuthenticationStarted: {
                query._runWhenPageStackNotBusy(function() {
                    pageStack.animatorPush(Qt.resolvedUrl("DeviceLockQueryInputPage.qml"), {"authentication": authentication})
                    authentication.feedback(feedback, -1)
                })
            }
            onAuthenticationUnavailable: {
                query._runWhenPageStackNotBusy(function() {
                    pageStack.animatorPush(Qt.resolvedUrl("DeviceLockQueryInputPage.qml"), {"authentication": authentication})
                    authentication.error(error)
                })
            }
            onAuthenticationEnded: {
                if (confirmed) {
                    query._authorization = null

                    if (returnOnAccept) {
                        pageStack.pop()
                    }
                } else {
                    query._aborted()
                }
            }
        },

        Connections {
            target: query._authorization

            onChallengeIssued: {
                deviceLock.authenticate(
                            query._authorization.challengeCode,
                            query._authorization.allowedMethods)
            }
            onChallengeDeclined: {
                query._aborted()
            }
            onChallengeExpired: {
                query._aborted()
            }
        },

        Connections {
            target: pageStack
            onBusyChanged: {
                if (!pageStack.busy && query._delayedAction) {
                    var action = query._delayedAction
                    query._delayedAction = undefined
                    action()
                }
            }
        }
    ]
}
