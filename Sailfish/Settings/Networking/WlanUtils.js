.import MeeGo.Connman 0.2 as Connman

function maybeJoin(strlist) {
    return strlist && strlist.length > 0 ? strlist.join(",") : ""
}

function getStrengthString(strength) {
    var str_idx = "0"

    if (strength >= 59) {
        str_idx = "4"
    } else if (strength >= 55) {
        str_idx = "3"
    } else if (strength >= 50) {
        str_idx = "2"
    } else if (strength >= 40) {
        str_idx = "1"
    } else if (strength == 0) {
        str_idx = "no-signal"
    }

    return str_idx
}

function getEncryptionString(securityType, eapType) {
    switch (securityType) {
    case Connman.NetworkService.SecurityNone:
        //: Open here refers to network without authentication
        //% "Open"
        return qsTrId("settings_network-la-encryption_open")
    case Connman.NetworkService.SecurityWEP:
        //% "WEP"
        return qsTrId("settings_network-la-encryption_wep")
    case Connman.NetworkService.SecurityPSK:
        //% "WPA/WPA2 PSK"
        return qsTrId("settings_network-la-encryption_wpa")
    case Connman.NetworkService.SecurityIEEE802:
        var method = network ? network.eapMethod : Connman.NetworkService.EapNone
        if (method === Connman.NetworkService.EapPEAP) {
            //% "WPA-EAP (PEAP)"
            return qsTrId("settings_network-la-encryption_eap-peap")
        } else if (method === Connman.NetworkService.EapTTLS) {
            //% "WPA-EAP (TTLS)"
            return qsTrId("settings_network-la-encryption_eap-ttls")
        } else if (method === Connman.NetworkService.EapTLS) {
            //% "WPA-EAP (TLS)"
            return qsTrId("settings_network-la-encryption_eap-tls")
        } else {
            //% "WPA-EAP"
            return qsTrId("settings_network-la-encryption_eap")
        }
    case Connman.NetworkService.SecurityUnknown:
    default:
        console.log("Error! Unknown WLAN security mode")
    }
    //% "Unknown"
    return qsTrId("settings_network-la-encryption_unknown")
}
