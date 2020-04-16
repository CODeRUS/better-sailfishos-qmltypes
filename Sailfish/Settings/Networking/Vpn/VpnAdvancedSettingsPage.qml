/*
 * Copyright (c) 2018 - 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */

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
    property var userRoutes
    property ListModel routesModel: ListModel {}

    signal propertiesUpdated(var connectionProperties, var providerProperties)

    function updateProperties() {
        storeCredentials.checked = connectionProperties['storeCredentials'] == true
        var domain = connectionProperties['domain']
        if (!domain || SettingsVpnModel.isDefaultDomain(domain)) {
            domain = '';
        }
        domainName.text = domain

        if (providerOptions.item) {
            providerOptions.item.setProperties(providerProperties)
        }

        // Set up the user routes
        userRoutes = connectionProperties['userRoutes']
        for (var i = 0; userRoutes && i < userRoutes.length; i++) {
            var route = userRoutes[i]
            routesModel.append({"Network": route.Network, "Netmask": route.Netmask, "Gateway": route.Gateway})
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

        userRoutes = []
        for (var i = 0; i < routesModel.count; i++) {
            var route = routesModel.get(i)
            userRoutes.push({"Network": route.Network, "Netmask": route.Netmask, "Gateway": route.Gateway})
        }
        connectionProperties['userRoutes'] = userRoutes

        providerProperties = {}
        if (providerOptions.item) {
            providerOptions.item.updateProperties(providerProperties)
        }

        root.propertiesUpdated(connectionProperties, providerProperties)
    }

    function editUserRoute(index) {
        var obj = pageStack.animatorPush('VpnRoute.qml', {network: routesModel.get(index).Network,
                                             netmask: routesModel.get(index).Netmask,
                                             gateway: routesModel.get(index).Gateway,
                                             edit: true
                                         })
        obj.pageCompleted.connect(function(page) {
            page.accepted.connect(function() {
                routesModel.set(index, {"Network": page.network, "Netmask": page.netmask, "Gateway": page.gateway})
            })
        })
    }

    function addUserRoute() {
        var obj = pageStack.animatorPush('VpnRoute.qml')
        obj.pageCompleted.connect(function(page) {
            page.accepted.connect(function() {
                routesModel.append({"Network": page.network, "Netmask": page.netmask, "Gateway": page.gateway})
            })
        })
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
            }

            SectionHeader {
                //: Section header for the vpn network user routes
                //% "User routes"
                text: qsTrId("settings_network-he-vpn_user_routes")
            }

            Repeater {
                id: routes
                model: routesModel

                delegate: ListItem {
                    id: routeItem
                    contentHeight: Theme.itemSizeMedium
                    menu: ContextMenu {
                        MenuItem {
                            //: Menu option to edit a VPN route entry
                            //% "Edit"
                            text: qsTrId("settings_network-me-vpn-user_route_edit")
                            onClicked: root.editUserRoute(index)
                        }
                        MenuItem {
                            //: Menu option to delete a VPN route entry
                            //% "Delete"
                            text: qsTrId("settings_network-me-vpn-user_route_delete")
                            onDelayedClick: deleteRoute.start()
                        }
                    }

                    PropertyAnimation {
                        id: deleteRoute
                        target: routeItem
                        properties: "contentHeight, opacity"
                        to: 0
                        duration: 200
                        easing.type: Easing.InOutQuad
                        onRunningChanged: if (running === false) routesModel.remove(index)
                    }

                    Label {
                        id: routeTitle
                        x: Theme.horizontalPageMargin
                        y: Theme.paddingMedium
                        width: parent.width - 2 * x
                        font.pixelSize: Theme.fontSizeMedium
                        color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                        //: Title for the VPN's route "Route 1", "Route 2", etc.
                        //% "Route %1"
                        text: qsTrId("settings_network-la-vpn_user_routes_identifier").arg(index + 1)
                    }
                    Label {
                        anchors.top: routeTitle.bottom
                        x: Theme.horizontalPageMargin
                        width: parent.width - 2 * x
                        font.pixelSize: Theme.fontSizeExtraSmall
                        color: parent.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                        text: model.Network + " / " + model.Netmask + " / " + model.Gateway
                    }
                    onClicked: openMenu()
                }
            }

            BackgroundItem {
                id: addRoute
                onClicked: root.addUserRoute()
                highlighted: down
                Icon {
                    x: parent.width - (width + Theme.itemSizeSmall) / 2.0
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/icon-m-add" + (addRoute.highlighted ? "?" + Theme.highlightColor : "")
                }
                Label {
                                                     //% "Add a route"
                    text: routesModel.count === 0 ? qsTrId("settings_network-bu-vpn_add_a_route")
                                                     //% "Add another route"
                                                   : qsTrId("settings_network-bu-vpn_add_another_route")
                    width: parent.width - Theme.iconSizeSmall - Theme.horizontalPageMargin
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    color: parent.highlighted ? Theme.highlightColor : Theme.primaryColor
                }
            }

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

