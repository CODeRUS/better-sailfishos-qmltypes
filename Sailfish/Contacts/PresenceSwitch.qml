import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.contacts 1.0

BackgroundItem {
    id: root
    property var presenceState
    property Person self: Person.selfPerson
    property bool _checked: self.globalPresenceState == presenceState
    property bool _busy
    property int _busyCount
    property var _globalPresenceState: self.globalPresenceState
    on_GlobalPresenceStateChanged: cancelBusy()

    function cancelBusy() {
        _busy = false
        _busyCount = 0
    }

    height: Theme.itemSizeSmall * 2
    enabled: !_busy

    onClicked: {
        if (!_checked) {
            _busy = true
            _busyCount = 1
        }

        // Always try to set the global presence, in case it's out of sync with the
        // self contact presence.
        presenceUpdate.setGlobalPresence(presenceState)
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: _checked ? Theme.rgba(Theme.highlightColor, 0.1) : Theme.rgba(Theme.highlightColor, 0.3) }
        }
    }
    Label {
        y: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        text: presenceDescription(presenceState)
        color: _checked || highlighted ? Theme.highlightColor : Theme.primaryColor
        font.pixelSize: Theme.fontSizeExtraSmall
    }

    ContactPresenceIndicator {
        anchors {
            bottom: parent.bottom
            left: parent.left
            right: parent.right
            margins: Theme.paddingLarge
        }
        height: Theme.paddingMedium
        presenceState: _checked || _busyCount%2 ? root.presenceState : Person.PresenceUnknown
        opacity: _checked || _busyCount%2 ? 1.0 : 0.2
    }

    Timer {
        interval: 500
        running: _busy
        repeat: true
        onTriggered: {
            _busyCount++
            if (_busyCount > 30) {
                // if it hasn't changed within 15s cancel busy animation
                cancelBusy()
            }
        }
    }
}
