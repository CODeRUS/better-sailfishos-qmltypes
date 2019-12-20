/*
 * Copyright (c) 2018 - 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

import QtQuick 2.0
import Sailfish.Silica 1.0
import MeeGo.Connman 0.2
import org.nemomobile.systemsettings 1.0
import Sailfish.Settings.Networking 1.0
import Sailfish.Settings.Networking.Vpn 1.0

VpnEditDialog {
    id: root

    property alias subtitle: subtitleText.text

    property string vpnType
    property var connectionProperties: ({})
    property var providerProperties: ({})

    default property alias children: additionalProperties.data
    property Item firstAdditionalItem

    property alias vpnName: connectionName.text
    property bool validSettings: connectionName.text.length > 0
                                 && serverAddress.text.length > 0

    canAccept: validSettings

    function setValue(combo, value) {
        for (var i = 0; i < combo.values.length; ++i) {
            if (combo.values[i] == value) {
                combo.currentIndex = i
                return
            }
        }
        combo.currentIndex = -1
    }

    function getConnectionProperty(name) {
        if (connectionProperties) {
            return connectionProperties[name] || ''
        }
        return ''
    }

    function getProviderProperty(name) {
        if (providerProperties) {
            return providerProperties[name] || ''
        }
        return ''
    }

    function mergeProviderProperties(newProperties) {
        if (!providerProperties) {
            providerProperties = newProperties
        } else {
            for (var key in newProperties) {
                providerProperties[key] = newProperties[key]
            }
        }
    }

    function init() {
        if (connection) {
            vpnType = connection.type

            connectionProperties = {
                name: connection.name,
                host: connection.host,
                domain: connection.domain,
                storeCredentials: connection.storeCredentials,
                networks: connection.networks,
                userRoutes: connection.userRoutes
            }

            providerProperties = connection.providerProperties
        }

        // Only mandatory properties are included on the main page
        connectionName.text = getConnectionProperty('name')
        serverAddress.text = getConnectionProperty('host')
    }

    function updateProvider(name, value) {
        // If the value is empty, do not include the property in the configuration
        if (value != '') {
            providerProperties[name] = value
        } else {
            delete providerProperties[name]
        }
    }

    function saveConnection() {
        var props = {
            name: connectionName.text,
            host: serverAddress.text,
            type: root.vpnType,
            providerProperties: providerProperties
        }

        props['storeCredentials'] = root.connectionProperties['storeCredentials'] || false

        var domain = root.connectionProperties['domain']
        if (domain) {
            props['domain'] = domain
        }
        var networks = root.connectionProperties['networks']
        if (networks && networks != '') {
            props['networks'] = networks
        }
        var userRoutes = root.connectionProperties['userRoutes']
        if (userRoutes instanceof Array) {
            props['userRoutes'] = userRoutes
        }

        if (newConnection) {
            SettingsVpnModel.createConnection(props)
        } else {
            SettingsVpnModel.modifyConnection(connection.path, props)
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: Math.max(content.height + advancedSettings.height, height)

        VerticalScrollDecorator { }

        Column {
            id: content
            width: parent.width

            DialogHeader {
                title: root.title
            }

            Label {
                id: subtitleText

                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                height: implicitHeight + Theme.paddingLarge
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.Wrap
                textFormat: Text.StyledText
                visible: text != ""

                text: {
                    if (connection != undefined && connection.state == VpnConnection.Ready) {
                        //: Warning for editing active connection
                        //% "This connection is currently active. Saving the settings will cause the connection to be disconnected."
                        return qsTrId("settings_network-he-vpn_active_warning")
                    }
                    return ""
                }
            }

            ConfigTextField {
                id: connectionName

                //% "VPN name"
                label: qsTrId("settings_network-la-vpn_connection_name")
                inputMethodHints: Qt.ImhNoPredictiveText
                nextFocusItem: serverAddress
            }

            ConfigTextField {
                id: serverAddress

                //% "Server address"
                label: qsTrId("settings_network-la-vpn_server_address")
                nextFocusItem: root.firstAdditionalItem
            }

            Column {
                id: additionalProperties

                width: parent.width
            }
        }

        Item {
            id: advancedSettings

            width: parent.width
            height: visible ? button.height*3 : 0
            anchors.bottom: parent.bottom

            // Hide the advanced button when the keyboard is active
            opacity: pageStack.panelSize == 0 ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
                FadeAnimation {
                    duration : advancedSettings.visible ? 0 : 400
                }
            }

            Button {
                id: button
                anchors.centerIn: parent
                //% "Advanced"
                text: qsTrId("settings_network-bt-advanced_settings")
                onClicked: {
                    var obj = pageStack.animatorPush(Qt.resolvedUrl("VpnAdvancedSettingsPage.qml"), {
                        title: qsTrId("settings_network-bt-advanced_settings"),
                        vpnType: vpnType,
                        connectionProperties: connectionProperties,
                        providerProperties: providerProperties
                    })
                    obj.pageCompleted.connect(function(advancedPage) {
                        advancedPage.propertiesUpdated.connect(function(connectionProperties, providerProperties) {
                            root.connectionProperties = connectionProperties

                            mergeProviderProperties(providerProperties)
                        })
                    })
                }
            }
        }
    }
}

