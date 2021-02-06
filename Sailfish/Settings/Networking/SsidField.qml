import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2

TextField {
    property QtObject network

    //% "SSID"
    placeholderText: qsTrId("settings_network-la-ssid")

    //% "Network name"
    label: qsTrId("settings_network-la-wlan_network_name")
    hideLabelOnEmptyField: false

    maximumLength: 32
    width: parent.width
    text: network ? network.ssid : ""
    onTextChanged: {
        if (network) network.ssid = text
        if (text.length > 0) errorHighlight = false
    }
    onActiveFocusChanged: if (!activeFocus && text === "") errorHighlight = true

    //% "Network name is required"
    description: errorHighlight ? qsTrId("settings_network-la-wlan_network_name_required") : ""
}
