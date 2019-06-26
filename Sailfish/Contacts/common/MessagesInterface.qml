import org.nemomobile.dbus 2.0

DBusInterface {
    service: "org.nemomobile.qmlmessages"
    path: "/"
    iface: "org.nemomobile.qmlmessages"

    function startConversation(localUid, remoteUid) {
        typedCall('startConversation', [
            { 'type':'s', 'value':localUid },
            { 'type':'s', 'value':remoteUid }
        ])
    }

    function startSMS(phoneNumber) {
        typedCall('startSMS', [
            { 'type':'s', 'value':phoneNumber }
        ])
    }
}

