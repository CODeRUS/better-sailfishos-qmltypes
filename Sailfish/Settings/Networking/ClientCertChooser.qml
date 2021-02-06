import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2
import com.jolla.settings.system 1.0

Column {
    id: root

    signal certFromFileSelected()
    signal keyFromFileSelected()
    property QtObject network
    property bool immediateUpdate
    property alias labelColor: keyComboBox.labelColor
    property alias valueColor: keyComboBox.valueColor
    readonly property bool isPkcs12: network && network.privateKeyFile && network.privateKeyFile.match(/\.p(?:fx|12)$/)
    readonly property bool canAccept: !network || network.eapMethod !== NetworkService.EapTLS || isPkcs12 || !network.privateKeyFile === !network.clientCertFile
    readonly property Item passphraseField: privateKeyPassphraseField

    readonly property bool required: network && network.eapMethod === NetworkService.EapTLS

    visible: required
    width: parent.width

    onIsPkcs12Changed: if (isPkcs12) network.clientCertFile = ''

    function cancel() {
        keyComboBox.currentIndex = network.privateKeyFile ? 1 : 0
        certComboBox.currentIndex = network.clientCertFile ? 1 : 0
    }

    ComboBox {
        id: keyComboBox
        //% "Client key"
        label: qsTrId("settings_network-la-client_key")

        currentIndex: network && network.privateKeyFile ? 1 : 0

        Binding on currentIndex {
            when: network
            value: network.privateKeyFile ? 1 : 0
        }

        menu: ContextMenu {
            MenuItem {
                //% "Not provided"
                text: qsTrId("settings_network-la-client_key_none")
            }
            MenuItem {
                //: Same as components_pickers-li-file_system_category
                //% "File system"
                text: qsTrId("settings_network-la-file_system")
                onClicked: {
                    root.keyFromFileSelected()
                }
            }
        }
        onCurrentIndexChanged: {
            if (currentIndex === 0)
                network.privateKeyFile = ''
        }
    }
    ComboBox {
        id: certComboBox
        //% "Client certificate"
        label: qsTrId("settings_network-la-client_cert")
        visible: !isPkcs12

        labelColor: keyComboBox.labelColor
        valueColor: keyComboBox.valueColor

        currentIndex: network && network.clientCertFile ? 1 : 0

        Binding on currentIndex {
            when: network
            value: network.clientCertFile ? 1 : 0
        }

        menu: ContextMenu {
            MenuItem {
                //% "Not provided"
                text: qsTrId("settings_network-la-client_cert_none")
            }
            MenuItem {
                //: Same as components_pickers-li-file_system_category
                //% "File system"
                text: qsTrId("settings_network-la-file_system")
                onClicked: {
                    root.certFromFileSelected()
                }
            }
        }
        onCurrentIndexChanged: if (currentIndex === 0) {
            network.clientCertFile = ''
        }
    }
    SystemPasswordField {
        id: privateKeyPassphraseField

        visible: root.visible && network.privateKeyFile !== ''
        text: network && network.privateKeyPassphrase
        onTextChanged: {
            if (immediateUpdate) network.privateKeyPassphrase = text
        }
        onActiveFocusChanged: if (!immediateUpdate && !activeFocus) network.privateKeyPassphrase = text
        //% "Client key passphrase"
        label: qsTrId("settings_network-la-client_key_passphrase")
    }
}
