import QtQuick 2.1
import Sailfish.Silica 1.0

Item {
    property bool active
    property variant _window

    function activate() {
        active = true
    }
    function reset() {
        active = false
    }
    function _update() {
        if (_window) {
            if (active) {
                if (_window.flags & Qt.WindowOverridesSystemGestures) {
                    console.log("Warning! WindowGestureOverride is trying to disable system gestures that have already been disabled, race conditions are likely.")
                }
                _window.flags |= Qt.WindowOverridesSystemGestures
            } else {
                _window.flags &= ~Qt.WindowOverridesSystemGestures
            }
        }
    }

    onActiveChanged: _update()
    onWindowChanged: {
        if (window) {
            _window = window
            _update()
        }
    }

    Component.onDestruction: reset()
}
