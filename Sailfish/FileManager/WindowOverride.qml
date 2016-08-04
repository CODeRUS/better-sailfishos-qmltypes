import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    property bool active
    property variant _window

    onActiveChanged: {
        if (_window) {
            if (active) {
                _window.flags |= Qt.WindowOverridesSystemGestures
            } else {
                _window.flags &= ~Qt.WindowOverridesSystemGestures
            }
        }
    }

    function activate() {
        active = true
    }

    function reset() {
        active = false
    }

    onWindowChanged: {
        if (window) {
            _window = window
        }
    }
}
