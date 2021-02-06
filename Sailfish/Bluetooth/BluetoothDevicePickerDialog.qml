/****************************************************************************
**
** Copyright (C) 2013 - 2020 Jolla Ltd.
** Copyright (C) 2020 Open Mobile Platform LLC.
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import Sailfish.Policy 1.0
import com.jolla.settings.system 1.0
import org.nemomobile.notifications 1.0
import org.kde.bluezqt 1.0 as BluezQt

Dialog {
    id: root

    property string selectedDevice
    property alias requirePairing: picker.requirePairing
    property alias excludedDevices: picker.excludedDevices
    property alias preferredProfileHint: picker.preferredProfileHint
    property alias showPairedDevices: picker.showPairedDevices

    readonly property bool _adapterPoweredOn: BluezQt.Manager.usableAdapter
                                              && BluezQt.Manager.usableAdapter.powered
    readonly property bool _bluetoothToggleActive: AccessPolicy.bluetoothToggleEnabled
                                                  || _adapterPoweredOn

    function _tryAccept(address) {
        if (!_adapterPoweredOn) {
            adapterOffNotification.publish()
            return
        }

        selectedDevice = address
        accept()
        selectedDevice = ""
    }

    canAccept: selectedDevice.length > 0
               && _adapterPoweredOn

    on_AdapterPoweredOnChanged: {
        if (_adapterPoweredOn) {
            adapterOffNotification.close()
        }
    }

    BluetoothSession {
        id: session
    }

    onOpened: {
        if (AccessPolicy.bluetoothToggleEnabled) {
            session.startSession()
        }
        picker.selectedDevice = ""
    }

    onDone: {
        picker.stopDiscovery()
        session.endSession()
    }

    BluetoothViewPlaceholder {
        id: bluetoothViewPlaceholder
    }

    SilicaFlickable {
        anchors.fill: parent
        visible: !bluetoothViewPlaceholder.enabled
        contentWidth: width
        contentHeight: Math.max(placeholder.height, picker.height + header.height)

        VerticalScrollDecorator {}

        PageHeader {
            id: header
            //% "Select device"
            title: qsTrId("components_bluetooth-la-select_device")
        }

        ViewPlaceholder {
            id: placeholder
            //% "Search for devices"
            text: qsTrId("components_bluetooth-me-pull_down_to_discover")
            enabled: !picker.visible && root._bluetoothToggleActive
        }

        DisabledByMdmBanner {
            anchors.top: header.bottom
            active: !root._bluetoothToggleActive
        }

        BluetoothDevicePicker {
            id: picker
            anchors.top: header.bottom
            visible: (discovering || !empty) && root._bluetoothToggleActive
            width: parent.width
            height: visible ? implicitHeight : 0
            autoStartDiscovery: true

            onDeviceClicked: {
                if (selectedDevicePaired || !requirePairing) {
                    root._tryAccept(selectedDevice)
                }
            }
            onDevicePaired: {
                if (requirePairing) {
                    root._tryAccept(address)
                }
            }
        }

        PullDownMenu {
            MenuItem {
                //% "Search for devices"
                text: qsTrId("components_bluetooth-me-start_discovery")
                enabled: !picker.discovering && root._bluetoothToggleActive

                onClicked: picker.startDiscovery()
            }
        }
    }

    Notification {
        id: adapterOffNotification

        //: Waiting for Bluetooth to turn on
        //% "Waiting for Bluetooth"
        summary: qsTrId("components_bluetooth-la-waiting_for_bluetooth")
        appIcon: "icon-s-bluetooth"
        isTransient: true
    }
}
