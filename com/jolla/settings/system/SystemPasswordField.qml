import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.devicelock 1.0

PasswordField {
    property bool requireAuthentication
    property string authenticationPrompt

    _automaticEchoModeToggle: false

    on_EchoModeToggleClicked: {
        if (_usePasswordEchoMode) {
            if (requireAuthentication && deviceLockQuery._availableMethods !== Authenticator.NoAuthentication) {
                deviceLockQuery.requestPermission(authenticationPrompt, {}, function () {
                    _usePasswordEchoMode = false
                    requireAuthentication = false
                })
            } else {
                _usePasswordEchoMode = false
            }
        } else {
            _usePasswordEchoMode = true
        }
    }

    onTextChanged: if (!activeFocus && text.length > 0) requireAuthentication = true

    Connections {
        target: Qt.application
        onActiveChanged: if (!Qt.application.active && text.length > 0) requireAuthentication = true
    }

    DeviceLockQuery {
        id: deviceLockQuery
        returnOnAccept: true
        returnOnCancel: true
    }
}
