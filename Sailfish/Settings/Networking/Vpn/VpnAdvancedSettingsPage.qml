import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.systemsettings 1.0
import Sailfish.Settings.Networking 1.0
import Sailfish.Settings.Networking.Vpn 1.0

Page {
    id: root

    property alias title: pageHeader.title

    property string vpnType
    property var connectionProperties
    property var providerProperties

    signal propertiesUpdated(var connectionProperties, var providerProperties)

    function updateProperties() {
        storeCredentials.checked = connectionProperties['storeCredentials'] == true
        domainName.text = connectionProperties['domain'] || ''
        networkSpec.text = connectionProperties['networks'] || ''

        if (providerOptions.item) {
            providerOptions.item.setProperties(providerProperties)
        }
    }

    function setProperties() {
        connectionProperties = {}
        if (storeCredentials.checked) {
            connectionProperties['storeCredentials'] = true
        }
        if (domainName.text != '') {
            connectionProperties['domain'] = domainName.text
        }
        if (networkSpec.text != '') {
            connectionProperties['networks'] = networkSpec.text
        }

        providerProperties = {}
        if (providerOptions.item) {
            providerOptions.item.updateProperties(providerProperties)
        }

        root.propertiesUpdated(connectionProperties, providerProperties)
    }

    Component.onCompleted: {
        updateProperties()
    }

    onStatusChanged: {
        if (status === PageStatus.Deactivating) {
            setProperties()
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height + Theme.paddingLarge

        VerticalScrollDecorator { }

        Column {
            id: content
            width: parent.width

            PageHeader {
                id: pageHeader
            }

            TextSwitch {
                id: storeCredentials

                //% "Remember credential information"
                text: qsTrId("settings_network-la-vpn_store_credentials")

                // Not currently used, but we may need the string translated:
                Component.onCompleted: {
                    //% "Forget credential information"
                    QT_TRID_NOOP("settings_network-la-vpn_forget_credentials")
                }
            }

            ConfigTextField {
                id: domainName

                //% "Domain"
                label: qsTrId("settings_network-la-vpn_domain")
                nextFocusItem: networkSpec
            }

            ConfigTextField {
                id: networkSpec

                //: Connman networks specification, formatted: <network>[/<netmask>[/<gateway>]]
                //% "Network/netmask/gateway"
                label: qsTrId("settings_network-la-vpn_networks")
                inputMethodHints: Qt.ImhPreferNumbers
            }

            // TODO: UserRoutes goes here, if required...

            Loader {
                id: providerOptions

                width: parent.width
                asynchronous: false

                Component.onCompleted: {
                    var src = VpnTypes.advancedSettingsPath(vpnType)

                    if (src) {
                        setSource(src)
                    }
                }

                onLoaded: item.setProperties(providerProperties)
            }
        }
    }
}

