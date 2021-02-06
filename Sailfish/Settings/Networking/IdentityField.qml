import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2

NetworkField {
    property QtObject network
    property bool immediateUpdate
    readonly property bool required: network && network.securityType === NetworkService.SecurityIEEE802

    inputMethodHints: Qt.ImhNoAutoUppercase
    enabled: network && network.identityAvailable
    text: enabled ? network.identity : ""
    visible: required
    //% "Identity"
    label: qsTrId("settings_network-la-identity")
    onTextChanged: if (immediateUpdate && network) network.identity = text
    onActiveFocusChanged: if (!activeFocus && network) network.identity = text
    acceptableInput: text.length > 0

    //% "Identity is required"
    description: errorHighlight ? qsTrId("settings_network-la-identity_required") : ""
}
