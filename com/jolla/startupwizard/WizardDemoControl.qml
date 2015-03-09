import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.dbus 1.0

DBusInterface {
    property bool allowPeekTop: true
    property bool allowPeekBottom: true
    property bool allowPeekLeft: true
    property bool allowPeekRight: true

    destination: "com.jolla.LipstickDemo"
    path: "/com/jolla/LipstickDemo"
    iface: "com.jolla.LipstickDemo"

    function setPeekGesturesAllowed(allowed) {
        allowPeekTop = allowed
        allowPeekBottom = allowed
        allowPeekLeft = allowed
        allowPeekRight = allowed
    }

    function _allowPeek(peekType, allow) {
        call('allow' + peekType + 'Peek', [allow])
    }

    onAllowPeekTopChanged: _allowPeek('Top', allowPeekTop)
    onAllowPeekBottomChanged: _allowPeek('Bottom', allowPeekBottom)
    onAllowPeekLeftChanged: _allowPeek('Left', allowPeekLeft)
    onAllowPeekRightChanged: _allowPeek('Right', allowPeekRight)
}
