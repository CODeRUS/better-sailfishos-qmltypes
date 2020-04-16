import QtQuick 2.0
import MeeGo.Connman 0.2

// Matches networkservice.h
QtObject {
    property bool passphraseRequired: passphraseField.required
    property bool identityRequired: identityField.required
    property bool identityAvailable: true
    property bool passphraseAvailable: true
    property string ssid
    property int securityType: NetworkService.SecurityPSK
    property int eapMethod: NetworkService.EapPEAP
    property int peapVersion: -1
    property string identity
    property string passphrase
    property string phase2: 'MSCHAPV2'
    property string caCert
    property string caCertFile
    property string clientCert
    property string clientCertFile
    property string privateKey
    property string privateKeyFile
    property string privateKeyPassphrase
    property bool privateKeyPassphraseAvailable: true
    property string domainSuffixMatch
    property bool eapMethodAvailable: true
    property bool autoConnect: true
    property bool hidden: true
    property var nameservers: []
    property var domains: []
    property var nameserversConfig: []
    property var domainsConfig: []
    property var ipv4Config: {
                "Method": "dhcp",
                "Address": "",
                "Netmask": "",
                "Gateway": ""
    }
    property var proxyConfig: {
                "Method": "direct",
                "URL": "",
                "Servers": "",
                "Excludes": []
    }

    function securityTypeToString(type) {
        switch (type) {
        case NetworkService.SecurityNone:
            return "none"
        case NetworkService.SecurityWEP:
            return "wep"
        case NetworkService.SecurityPSK:
            return "psk"
        case NetworkService.SecurityIEEE802:
            return "ieee8021x"
        default: // SecurityUnknown, ..
            console.warn("Error! WLAN UI cannot handle given security type", type)
            return ""
        }
    }

    function eapTypeToString(type, peapVersion) {
        switch (type) {
        case NetworkService.EapNone:
            return "none"
        case NetworkService.EapPEAP:
            if (peapVersion === 0)
                return "peapv0"
            if (peapVersion === 1)
                return "peapv1"
            return "peap"
        case NetworkService.EapTTLS:
            return "ttls"
        case NetworkService.EapTLS:
            return "tls"
        default: // SecurityUnknown, ..
            console.warn("Error! WLAN UI cannot handle given eap type", type)
            return ""
        }
    }

    function netmask_prefixlen(netmask) {
        var binaryArray = netmask.split(".").map(function (value) { return Number(value).toString(2)}) // turn to binary
        var binaryString = binaryArray.map(
            function (value) { return new Array(8 - value.length + 1).join('0') + value }).join('') // pad with zeroes
        return (binaryString.split('1').length - 1).toString() // count ones
    }

    function json() {
        var settings = {
            "Name": ssid.trim(),
            "Security": securityTypeToString(securityType),
            "AutoConnect": "true"
        }

        if (passphraseRequired) {
            if (passphrase.length > 0) {
                settings.Passphrase = passphrase
            } else {
                console.log("Error! Passphrase required, not defined!")
                return
            }
        }
        if (identityRequired) {
            if (identity.length >= 3 && identity.length <= 63) {
                settings.Identity = identity
            } else {
                console.log("Error! Identity required, not defined!")
                return
            }
        }

        if (hidden) {
            settings.Hidden = "true"
        }

        if (securityType === NetworkService.SecurityIEEE802) {
            settings.EAP = eapTypeToString(eapMethod, peapVersion)
            if (phase2)
                settings.Phase2 = phase2
            if (caCert)
                settings.CACert = caCert
            if (caCertFile)
                settings.CACertFile = caCertFile
            if (clientCertFile)
                settings.ClientCertFile = clientCertFile
            if (privateKeyFile)
                settings.PrivateKeyFile = privateKeyFile
            if (privateKeyPassphrase)
                settings.PrivateKeyPassphrase = privateKeyPassphrase
            if (domainSuffixMatch)
                settings.DomainSuffixMatch = domainSuffixMatch
        }
        if (nameserversConfig.length > 0) {
            settings.Nameservers = nameserversConfig.join(";")
        }
        if (domainsConfig.length > 0) {
            settings.Domains = domainsConfig.join(";")
        }
        if (ipv4Config.Method === "manual") {
            var netmask = ipv4Config.Netmask

            settings["IPv4.method"] = "manual"
            settings["IPv4.local_address"] = ipv4Config.Address
            settings["IPv4.netmask_prefixlen"] = netmask_prefixlen(netmask)
            settings["IPv4.gateway"] = ipv4Config.Gateway
        }
        if (proxyConfig.Method !== "direct") {
            settings["Proxy.Method"] = proxyConfig.Method
            if (proxyConfig.Method === "auto") {
                settings["Proxy.URL"] = proxyConfig.URL
            } else {
                settings["Proxy.Servers"] = proxyConfig.Servers.join(";")
                settings["Proxy.Excludes"] = proxyConfig.Excludes.join(";")
            }
        }

        var debug = false
        if (debug) console.log(JSON.stringify(settings, null, 2))
        return settings
    }
}
