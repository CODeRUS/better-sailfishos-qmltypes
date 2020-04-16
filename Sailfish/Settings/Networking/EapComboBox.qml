import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2 as Connman

ComboBox {
    property bool immediateUpdate: true
    property QtObject network

    //% "EAP method"
    label: qsTrId("settings_network-la-eap_method")
    visible: network && network.securityType === Connman.NetworkService.SecurityIEEE802

    Binding on currentIndex {
        when: network
        value: _findIndex(repeater.model, function (item) { return item.value === network.eapMethod }, 0)
    }

    function _findIndex(arr, cb, notfound) {
        if (notfound === undefined)
            notfound = -1
        for (var i = 0; i < arr.length; i++) {
            if (cb(arr[i]))
                return i
        }
        return notfound
    }

    menu: ContextMenu {
        Repeater {
            id: repeater
            model: [
                { label: 'PEAP', value: Connman.NetworkService.EapPEAP },
                { label: 'TTLS', value: Connman.NetworkService.EapTTLS },
                { label: 'TLS', value: Connman.NetworkService.EapTLS }
            ]

            delegate: MenuItem {
                text: modelData.label
            }
        }
    }

    onCurrentIndexChanged: {
        if (immediateUpdate)
            network.eapMethod = repeater.model[currentIndex].value
    }
}
