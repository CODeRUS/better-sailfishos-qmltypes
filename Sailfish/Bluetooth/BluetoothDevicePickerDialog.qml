import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0

Dialog {
    id: root

    property string selectedDevice
    property alias requirePairing: picker.requirePairing
    property alias excludedDevices: picker.excludedDevices
    property alias preferredProfileHint: picker.preferredProfileHint

    canAccept: selectedDevice.length > 0

    BluetoothSession {
        id: session
    }

    onOpened: {
        session.startSession()
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
            enabled: !picker.visible
        }

        BluetoothDevicePicker {
            id: picker
            anchors.top: header.bottom
            visible: discovering || !empty
            width: parent.width
            autoStartDiscovery: true

            onDeviceClicked: {
                if (selectedDevicePaired || !requirePairing) {
                    root.selectedDevice = selectedDevice
                    root.accept()
                    selectedDevice = ""
                }
            }
            onDevicePaired: {
                if (requirePairing) {
                    root.selectedDevice = address
                    root.accept()
                    selectedDevice = ""
                }
            }
        }

        PullDownMenu {
            MenuItem {
                //% "Search for devices"
                text: qsTrId("components_bluetooth-me-start_discovery")
                enabled: !picker.discovering

                onClicked: picker.startDiscovery()
            }
        }
    }
}
