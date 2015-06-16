import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0

Dialog {
    id: root

    property string selectedDevice: picker.selectedDevice
    property bool selectedDevicePaired: picker.selectedDevicePaired
    property alias excludedDevices: picker.excludedDevices
    property alias preferredProfileHint: picker.preferredProfileHint

    function _doDiscovery() {
        if (adapter.powered) {
            adapter.startDiscovery()
            picker.selectedDevice = ""
        } else {
            adapter.startDiscoveryWhenPowered = true
        }
    }

    canAccept: selectedDevice != ""
    forwardNavigation: canAccept

    onOpened: {
        adapter.startSession()
    }

    onDone: {
        adapter.stopDiscovery()
        adapter.endSession()
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
            enabled: !picker.visible
        }

        BluetoothDevicePicker {
            id: picker
            anchors.top: header.bottom
            visible: adapter.discovering || !empty
            width: parent.width
            onDeviceClicked: root.accept()
        }

        PullDownMenu {
            MenuItem {
                //% "Search for devices"
                text: qsTrId("components_bluetooth-me-start_discovery")
                enabled: !adapter.discovering

                onClicked: {
                    root._doDiscovery()
                }
            }
        }
    }

    BluetoothAdapter {
        id: adapter

        property bool startDiscoveryWhenPowered

        onReadyChanged: {
            if (ready) {
                root._doDiscovery()
            }
        }

        onPoweredChanged: {
            if (startDiscoveryWhenPowered && powered) {
                startDiscovery()
                picker.selectedDevice = ""
                startDiscoveryWhenPowered = false
            }
        }
    }
}
