import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2 as Connman

ComboBox {
    property bool immediateUpdate: true
    property QtObject network

    //: Method used inside PEAP/TTLS tunnel to authenticate user, most commonly MSCHAPv2
    //% "Inner authentication"
    label: qsTrId("settings_network-la-eap_inner_authentication")
    visible: network && network.securityType === Connman.NetworkService.SecurityIEEE802 && _findIndex(repeater.model, _isValidForFilter(network.eapMethod), -1) !== -1
    currentIndex: network ? _findKeyIndex(repeater.model, "value", network.phase2, _findIndex(repeater.model, _isValidForFilter(network.eapMethod), 0)) : 0

    function _findIndex(arr, cb, notfound) {
        if (notfound === undefined)
            notfound = -1
        for (var i = 0; i < arr.length; i++) {
            if (cb(arr[i]))
                return i
        }
        return notfound
    }

    function _findKeyIndex(arr, key, value, notfound) {
        return _findIndex(arr, function (i) { return i[key] === value }, notfound)
    }

    function _isValidFor(item, val) {
        return item.validFor.indexOf(val) !== -1
    }

    function _isValidForFilter(val) {
        return function (item) { return _isValidFor(item, val) }
    }

    Connections {
        target: network

        onEapMethodChanged: {
           if (currentIndex === -1 || !_isValidFor(repeater.model[currentIndex], network.eapMethod)) {
               currentIndex = _findIndex(repeater.model, _isValidForFilter(network.eapMethod), 0)
           }
        }

        onPhase2Changed: currentIndex = _findKeyIndex(repeater.model, "value", network.phase2, _findIndex(repeater.model, _isValidForFilter(network.eapMethod), 0))
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
                visible: _isValidFor(modelData, network.eapMethod)
            }
        }
    }

    onCurrentIndexChanged: {
        if (immediateUpdate) {
            if (currentIndex >= 0)
                network.phase2 = repeater.model[currentIndex].value
            else
                network.phase2 = ''
        }
    }
}
