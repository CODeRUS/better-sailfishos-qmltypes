import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2 as Connman

ComboBox {
    property bool immediateUpdate: true
    property QtObject network

    //: Method used inside PEAP/TTLS tunnel to authenticate user, most commonly MSCHAPv2
    //% "Inner authentication"
    label: qsTrId("settings_network-la-eap_inner_authentication")
    visible: network && network.securityType === Connman.NetworkService.SecurityIEEE802 && menu.visibleChildren.length > 0
    currentIndex: network ? findIndex(repeater.model, function (item) { return item.value == network.phase2 }, findIndex(repeater.model, function (item) { return item.validFor.indexOf(network.eapMethod) !== -1 }, 0)) : 0

    function findIndex(arr, cb, notfound) {
        if (notfound === undefined)
            notfound = -1
        for (var i = 0; i < arr.length; i++) {
            if (cb(arr[i]))
                return i
        }
        return notfound
    }

    Connections {
        target: network

        onEapMethodChanged: {
           if (repeater.model[currentIndex].validFor.indexOf(network.eapMethod) === -1) {
               currentIndex = findIndex(repeater.model, function (mtod) { return mtod.validFor.indexOf(network.eapMethod) !== -1 })
           }
        }

        onPhase2Changed: currentIndex = findIndex(repeater.model, function (item) { return item.value == network.phase2 },
                                                  findIndex(repeater.model, function (item) { return item.validFor.indexOf(network.eapMethod) !== -1 }, 0))
    }

    menu: ContextMenu {
        id: menu
        Repeater {
            id: repeater
            visible: false
            model: [
                { label: 'PAP', value: 'PAP', validFor: [ Connman.NetworkService.EapTTLS ] },
                { label: 'MSCHAP', value: 'MSCHAP', validFor: [ Connman.NetworkService.EapTTLS ] },
                { label: 'MSCHAPv2', value: 'MSCHAPV2', validFor: [
                    Connman.NetworkService.EapPEAP,
                    Connman.NetworkService.EapTTLS ] },
                { label: 'GTC', value: 'GTC', validFor: [
                    Connman.NetworkService.EapPEAP,
                    Connman.NetworkService.EapTTLS ] },
            ]

            delegate: MenuItem {
                text: modelData.label
                visible: modelData.validFor.indexOf(network.eapMethod) !== -1
            }
        }
    }

    onCurrentIndexChanged: {
        if (immediateUpdate)
            network.phase2 = repeater.model[currentIndex].value
    }
}
