import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import Sailfish.Settings.Networking 1.0
import Sailfish.Settings.Networking.Vpn 1.0

VpnDetailsPage {
    id: root

    property alias subtitle: pageHeader.description
    property var details: []
    property var stateDetails: []
    property var providerDetails: []

    function booleanStateName(b) {
                 //% "True"
        return b ? qsTrId("settings_network-la-vpn_details_true")
                 //% "False"
                 : qsTrId("settings_network-la-vpn_details_false")
    }

    Component.onCompleted: {
        if (connection) {
            //: VPN connection name property
            //% "Name"
            details.push({ 'name': qsTrId("settings_network-la-vpn_details_name"), 'value': connection.name })

            //: VPN connection server address property
            //% "Server address"
            details.push({ 'name': qsTrId("settings_network-la-vpn_details_host"), 'value': connection.host })

            var value = connection.domain
            if (value) {
                //: VPN connection domain property
                //% "Domain"
                details.push({ 'name': qsTrId("settings_network-la-vpn_details_domain"), 'value': value })
            }

            value = connection.networks
            if (value) {
                //: VPN connection networks property
                //% "Networks"
                details.push({ 'name': qsTrId("settings_network-la-vpn_details_networks"), 'value': value })
            }

            value = connection.nameservers
            if (value.length) {
                //: VPN connection nameservers property
                //% "Nameservers"
                stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_nameservers"), 'value': value.join(',') })
            }

            value = connection.iPv4
            if (value) {
                var prop = value['Address']
                if (prop) {
                    //: VPN connection IPv4 address property
                    //% "Address"
                    stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_ipv4_address"), 'value': prop })
                }

                prop = value['Netmask']
                if (prop) {
                    //: VPN connection IPv4 netmask property
                    //% "Netmask"
                    stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_ipv4_netmask"), 'value': prop })
                }

                prop = value['Gateway']
                if (prop) {
                    //: VPN connection IPv4 gateway property
                    //% "Gateway"
                    stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_ipv4_gateway"), 'value': prop })
                }

                prop = value['Peer']
                if (prop) {
                    //: VPN connection IPv4 peer property
                    //% "Peer"
                    stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_ipv4_peer"), 'value': prop })
                }
            }

            value = connection.iPv6
            if (value) {
                prop = value['Address']
                if (prop) {
                    //: VPN connection IPv6 address property
                    //% "Address (IPv6)"
                    stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_ipv6_address"), 'value': prop })
                }

                prop = value['PrefixLength']
                if (prop) {
                    //: VPN connection IPv6 prefix length property
                    //% "Prefix length"
                    stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_ipv6_prefix_length"), 'value': prop })
                }

                prop = value['Gateway']
                if (prop) {
                    //: VPN connection IPv6 gateway property
                    //% "Gateway (IPv6)"
                    stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_ipv6_gateway"), 'value': prop })
                }

                prop = value['Peer']
                if (prop) {
                    //: VPN connection IPv6 peer property
                    //% "Peer (IPv6)"
                    stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_ipv6_peer"), 'value': prop })
                }
            }

            value = connection.userRoutes
            var route
            var routeText
            if (value) {
                for (var i = 0; i < value.length; ++i) {
                    route = value[i]
                    prop = route['ProtocolFamily']
                    if (prop) {
                        routeText = (route['Network'] || '') + '/' + (route['Netmask'] || '') + (route['Gateway'] || '')

                        //: VPN connection user route property
                        //% "User route"
                        stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_user_route"), 'value': routeText })
                    }
                }
            }

            value = connection.serverRoutes
            if (value) {
                for (var i = 0; i < value.length; ++i) {
                    route = value[i]
                    prop = route['ProtocolFamily']
                    if (prop) {
                        routeText = (route['Network'] || '') + '/' + (route['Netmask'] || '') + (route['Gateway'] || '')

                        //: VPN connection server route property
                        //% "Server route"
                        stateDetails.push({ 'name': qsTrId("settings_network-la-vpn_details_server_route"), 'value': routeText })
                    }
                }
            }

            value = connection.providerProperties
            if (value) {
                for (var key in value) {
                    // Don't show secret content
                    if (key == 'VPNC.IPSec.Secret' || key == 'VPNC.Xauth.Password')
                        continue

                    providerDetails.push({ 'name': key, 'value': value[key] })
                }
            }

            detailRepeater.model = root.details
            stateDetailRepeater.model = root.stateDetails
            providerDetailRepeater.model = root.providerDetails
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        Column {
            id: content
            width: parent.width

            PageHeader {
                id: pageHeader
                //% "Connection details"
                title: qsTrId("settings_network-he-vpn_connection_details")
            }

            Repeater {
                id: detailRepeater

                delegate: VpnDetailItem {
                    name: modelData.name
                    value: modelData.value
                }
            }

            SectionHeader {
                //% "Connection state"
                text: qsTrId("settings_network-he-vpn_connection_state")
            }

            VpnDetailItem {
                //: VPN connection state property
                //% "State"
                name: qsTrId("settings_network-la-vpn_details_state")
                value: VpnTypes.stateName(connection.state)
            }

            VpnDetailItem {
                //: Whether this VPN will automatically reconnect
                //% "Automatically reconnect"
                name: qsTrId("settings_network-la-vpn_details_automatic_reconnect")
                value: booleanStateName(connection.autoConnect)
            }

            VpnDetailItem {
                //: Whether this VPN will remember credentials
                //% "Remember credentials"
                name: qsTrId("settings_network-la-vpn_details_store_credentials")
                value: booleanStateName(connection.storeCredentials)
            }

            Repeater {
                id: stateDetailRepeater

                delegate: VpnDetailItem {
                    name: modelData.name
                    value: modelData.value
                }
            }

            SectionHeader {
                //% "Provider state"
                text: qsTrId("settings_network-he-vpn_provider_state")
            }

            Repeater {
                id: providerDetailRepeater

                delegate: VpnDetailItem {
                    name: modelData.name
                    value: modelData.value
                }
            }
        }

        VerticalScrollDecorator { }
    }
}

