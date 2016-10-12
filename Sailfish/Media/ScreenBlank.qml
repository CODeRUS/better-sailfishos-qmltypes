import QtQuick 2.0
import org.nemomobile.dbus 2.0

Timer {
    id: timer

    property alias suspend: timer.running

    interval: 60000
    repeat: true
    triggeredOnStart: true
    onTriggered: dbus.call("req_display_blanking_pause", undefined)

    onRunningChanged: {
        if (!running) {
            dbus.call("req_display_cancel_blanking_pause", undefined)
        }
    }

    property DBusInterface _dbus: DBusInterface {
        id: dbus

        service: "com.nokia.mce"
        path: "/com/nokia/mce/request"
        iface: "com.nokia.mce.request"

        bus: DBus.SystemBus
    }
}
