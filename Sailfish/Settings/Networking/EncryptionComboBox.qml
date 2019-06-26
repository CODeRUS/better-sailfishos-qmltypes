import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2
import "WlanUtils.js" as WlanUtils

ComboBox {
    id: root
    property QtObject network

    //% "Encryption"
    label: qsTrId("settings_network-la-encryption")

    onCurrentIndexChanged: {
        if (enabled && network) {
            var type = currentIndex + 1
            if (type >= NetworkService.SecurityNone && type <= NetworkService.SecurityIEEE802) {
                network.securityType = currentIndex + 1 // Avoid value 0 = NetworkService.SecurityUnknown
            } else {
                console.warn("Invalid network encryption value selected", type)
            }
        }
    }

    Binding {
        target: root
        property: "currentIndex"
        value: network ? network.securityType - 1 : 0 // Avoid value 0 = NetworkService.SecurityUnknown
    }

    menu: ContextMenu {
        MenuItem {
            text: WlanUtils.getEncryptionString(NetworkService.SecurityNone)
        }
        MenuItem {
            text: WlanUtils.getEncryptionString(NetworkService.SecurityWEP)
        }
        MenuItem {
            text: WlanUtils.getEncryptionString(NetworkService.SecurityPSK)
        }
        MenuItem {
            text: WlanUtils.getEncryptionString(NetworkService.SecurityIEEE802, network ? network.eapMethod : NetworkService.EapNone)
        }
    }
}
