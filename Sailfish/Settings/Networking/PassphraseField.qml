import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2
import com.jolla.settings.system 1.0

SystemPasswordField {
    id: passphraseField

    property QtObject network
    property bool immediateUpdate
    readonly property bool required: network &&
                                     (network.securityType !== NetworkService.SecurityIEEE802 ||
                                      !network.eapMethodAvailable ||
                                      network.eapMethod !== NetworkService.EapTLS) &&
                                     network.securityType !== NetworkService.SecurityNone
    onActiveFocusChanged: {
        if (!activeFocus) {
            if (network) network.passphrase = text
            if (text === "") {
                errorHighlight = true
            }
        }
    }
    onTextChanged: {
        if (immediateUpdate) network.passphrase = text
        if (text.length > 0) errorHighlight = false
    }

    width: parent.width
    placeholderText: label
    enabled: network && network.passphraseAvailable
    text: enabled && network ? network.passphrase : ""
    visible: required
    //% "Passphrase"
    label: qsTrId("settings_network-la-passphrase")
}
