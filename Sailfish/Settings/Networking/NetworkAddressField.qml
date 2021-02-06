import QtQuick 2.0
import Sailfish.Silica 1.0

NetworkField {
    property string protocol: {
        var parts = text.split("//")
        if (parts.length > 1) {
            parts = parts[0].split(":")
            if (parts.length > 1) {
                return parts[0]
            }
        }
        return ""
    }
    property var protocols: ["http", "https", "ftp", "rtsp", "socks4"]
    property bool validProtocol: protocols.indexOf(protocol) >= 0

    // IP address, hostname or url (protocol + hostname)
    property var weakRegExp: new RegExp(/^[0-9\.:\/\w]*$|^([a-z]+:\/\/\w+.*)?$|^[\w-\.]*$/)

    onTextChanged: errorHighlight = !(text == "" || weakRegExp.test(text))

    //% "Valid network address is required"
    description: errorHighlight ? qsTrId("settings_network_la-network_address_field_error") : ""

    regExp: new RegExp(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$|^([a-z]+:\/\/\w+.*)+$|^([\w-]+(-[\w-]+)*)+(\.([\w-]+(-[\w-\.]+)*))*$/)
    inputMethodHints: Qt.ImhUrlCharactersOnly
}
