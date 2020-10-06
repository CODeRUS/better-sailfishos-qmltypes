import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2 as Connman

NetworkField {
    property QtObject network
    property bool immediateUpdate: true

    inputMethodHints: Qt.ImhNoAutoUppercase
    text: enabled ? network.anonymousIdentity : ""
    visible: network && network.securityType === Connman.NetworkService.SecurityIEEE802 && network.eapMethod !== Connman.NetworkService.EapTLS
    //: Anonymous identity is used for WLAN EAP options
    //% "Anonymous identity"
    placeholderText: qsTrId("settings_network-la-anonymous-identity")
    label: placeholderText
    onTextChanged: if (immediateUpdate && network) network.anonymousIdentity = text
    onActiveFocusChanged: if (!activeFocus && network) network.anonymousIdentity = text
    validInput: text.length <= 63
}
