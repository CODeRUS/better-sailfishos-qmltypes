import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2

Column {
    id: root

    signal fromFileSelected()
    property QtObject network
    property bool immediateUpdate
    property alias labelColor: certComboBox.labelColor
    property alias valueColor: certComboBox.valueColor
    property Item domainField: domainSuffixField

    readonly property bool required: network &&
             network.securityType === NetworkService.SecurityIEEE802 &&
                (network.eapMethod === NetworkService.EapPEAP ||
                 network.eapMethod === NetworkService.EapTTLS ||
                 network.eapMethod === NetworkService.EapTLS)
    visible: required
    width: parent.width

    function cancel() {
        certComboBox.currentIndex = network.caCertFile === '/etc/ssl/certs/ca-bundle.crt' ? 0 : (network.caCert || network.caCertFile ? 2 : 1)
    }

    ComboBox {
        id: certComboBox
        //% "CA Certificate"
        label: qsTrId("settings_network-la-ca_cert")

        currentIndex: network && network.CACertFile ? (
            network.caCertFile === '/etc/ssl/certs/ca-bundle.crt' ? 0 : 2) : network && network.caCert ? 2 : 1

        Binding on currentIndex {
            when: network
            value: network.caCertFile === '/etc/ssl/certs/ca-bundle.crt' ? 0 : (network.caCert || network.caCertFile ? 2 : 1)
        }

        menu: ContextMenu {
            MenuItem {
                //% "System CAs"
                text: qsTrId("settings_network-la-ca_cert_system")
            }
            MenuItem {
                //% "No verification"
                text: qsTrId("settings_network-la-ca_cert_none")
            }
            MenuItem {
                //: Same as components_pickers-li-file_system_category
                //% "File system"
                text: qsTrId("settings_network-la-file_system")
                onClicked: {
                    root.fromFileSelected()
                }
            }
        }
        onCurrentIndexChanged: {
            if (currentIndex === 0) {
                network.caCert = ''
                network.caCertFile = '/etc/ssl/certs/ca-bundle.crt'
            } else if (currentIndex === 1) {
                network.caCert = ''
                network.caCertFile = ''
                network.domainSuffixMatch = ''
            } else {
                network.caCertFile = ''
                network.domainSuffixMatch = ''
            }
        }
    }

    Label {
        //: Warning to user when they have opted not to verify authentication server's identity
        //% "Your connection may not be secure"
        text: qsTrId("settings_network-la-ca_cert_not_validated")
        visible: certComboBox.currentIndex === 1
        color: Theme.errorColor
        wrapMode: Text.Wrap
        x: Theme.horizontalPageMargin
        width: parent.width - 2 * Theme.horizontalPageMargin
    }

    TextField {
        id: domainSuffixField
        text: network ? network.domainSuffixMatch : ""
        visible: root.visible && certComboBox.currentIndex === 0
        width: parent.width

        //: Option to restrict accepted certificates to certain domain
        //% "Domain"
        placeholderText: qsTrId("settings_network-la-vpn_domain")
        label: placeholderText

        onTextChanged: if (immediateUpdate) {
            network.domainSuffixMatch = text
        }

        onActiveFocusChanged: {
            if (!immediateUpdate && !activeFocus) {
                network.domainSuffixMatch = text
            }
        }

        Binding on text {
            when: network
            value: network.domainSuffixMatch
        }
    }
}
