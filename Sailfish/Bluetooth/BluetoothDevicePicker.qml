import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import Bluetooth 0.0

Column {
    id: root

    property string selectedDevice
    property bool selectedDevicePaired
    property bool empty: pairedDevices.visibleItemCount == 0 && nearbyDevices.visibleItemCount == 0
    property alias discovering: adapter.discovering
    property bool highlightSelectedDevice: true
    property bool showPairedDevicesHeader
    property var excludedDevices: []    // addresses expected to be in upper case
    property int preferredProfileHint: -1  // darken devices that don't match this filter

    property bool _prevDiscoveryValue
    property bool _showDiscoveryProgress
    property bool _showOtherDevicesHeader: nearbyDevices.visibleItemCount && pairedDevices.visibleItemCount

    signal deviceClicked(string address)

    function startDiscovery() {
        adapter.startDiscovery()
    }
    function stopDiscovery() {
        adapter.stopDiscovery()
    }
    function _matchesProfileHint(profiles, classOfDevice) {
        return preferredProfileHint < 0
                || BluetoothProfiles.profileMatchesDeviceProperties(preferredProfileHint, profiles, classOfDevice)
    }

    Column {
        width: parent.width
        height: root._showDiscoveryProgress
                ? discoveryProgressBar.height
                : (pairedDevicesHeader.visible ? pairedDevicesHeader.height : 0)
        clip: true

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        SectionHeader {
            id: pairedDevicesHeader
            visible: root.showPairedDevicesHeader && !root._showDiscoveryProgress && pairedDevices.visibleItemCount > 0

            //% "Paired devices"
            text: qsTrId("components_bluetooth-la-paired-devices")
        }

        ProgressBar {
            id: discoveryProgressBar

            width: parent.width
            maximumValue: 100
            enabled: false
            opacity: root._showDiscoveryProgress ? 1.0 : 0

            //: Informs user that we are currently searching for nearby Bluetooth devices
            //% "Searching for devices"
            label: qsTrId("components_bluetooth-he-discovering")

            Behavior on opacity { FadeAnimation {} }

            // JB#5123 the progress is hardcoded for now
            SequentialAnimation {
                id: discoveryDummyAnim
                running: false

                NumberAnimation {
                    target: discoveryProgressBar
                    property: "value"
                    from: 0
                    to: discoveryProgressBar.maximumValue
                    duration: 11000
                }
                ScriptAction {
                    script: {
                        discoveryProgressBar.indeterminate = true
                    }
                }
            }
        }
    }

    Column {
        width: parent.width

        Repeater {
            id: pairedDevices

            property int visibleItemCount: count - _hiddenItemsCount
            property int _hiddenItemsCount
            onCountChanged: if (count == 0) _hiddenItemsCount = 0

            model: KnownDevicesModel { id: knownDevicesModel }

            delegate: ListItem {
                id: pairedDelegate

                property bool showConnectionStatus: (model.audioConnectionState !== BluetoothDevice.AudioStateUnknown
                                                     && model.audioConnectionState !== BluetoothDevice.AudioDisconnected)
                                                    || model.inputConnectionState === KnownDevicesModel.InputConnected
                                                    || model.inputConnectionState === KnownDevicesModel.InputConnecting

                property bool matchesProfileHint: root._matchesProfileHint(model.profiles, model.classOfDevice)
                property bool useHighlight: highlightSelectedDevice && model.address === root.selectedDevice

                visible: model.paired && root.excludedDevices.indexOf(model.address.toUpperCase()) < 0

                function _removePairing() {
                    adapter.removePairing(model.address)
                }

                menu: Component {
                    ContextMenu {
                        MenuItem {
                            //: Show settings for the selected bluetooth device
                            //% "Device settings"
                            text: qsTrId("components_bluetooth-me-device_settings")

                            onClicked: {
                                pageStack.push(Qt.resolvedUrl("PairedDeviceSettings.qml"), {"bluetoothDevice": model.bluetoothDevice})
                            }
                        }

                        MenuItem {
                            //: Remove the pairing with the selected bluetooth device
                            //% "Remove pairing"
                            text: qsTrId("components_bluetooth-me-pairing_remove")

                            onClicked: {
                                //: Removing bluetooth device pairing
                                //% "Removing pairing"
                                pairedDelegate.remorseAction(qsTrId("components_bluetooth-la-removing_pairing"), pairedDelegate._removePairing)
                            }
                        }
                    }
                }

                onVisibleChanged: {
                    pairedDevices._hiddenItemsCount += (visible ? -1: 1)
                }

                onClicked: {
                    root.selectedDevice = model.address
                    root.selectedDevicePaired = model.paired
                    root.deviceClicked(model.address)
                }

                Image {
                    id: icon
                    x: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/" + model.jollaIcon
                    opacity: pairedDelegate.matchesProfileHint || pairedDelegate.useHighlight ? 1 : 0.5
                }

                Label {
                    id: deviceNameLabel
                    anchors {
                        left: icon.right
                        leftMargin: Theme.paddingMedium
                        right: trustedIcon.left
                        rightMargin: Theme.paddingMedium
                    }
                    y: pairedDelegate.contentHeight/2 - implicitHeight/2
                       - (showConnectionStatus ? connectedLabel.implicitHeight/2 : 0)
                    text: model.alias.length ? model.alias : model.address
                    truncationMode: TruncationMode.Fade
                    color: (pairedDelegate.highlighted || pairedDelegate.useHighlight)
                           ? Theme.highlightColor
                           : Theme.rgba(Theme.primaryColor, pairedDelegate.matchesProfileHint ? 1.0 : 0.5)

                    Behavior on y { NumberAnimation {} }
                }

                Label {
                    id: connectedLabel
                    anchors {
                        left: deviceNameLabel.left
                        top: deviceNameLabel.bottom
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                    }
                    font.pixelSize: Theme.fontSizeExtraSmall
                    opacity: showConnectionStatus ? 1.0 : 0.0
                    color: (pairedDelegate.highlighted || pairedDelegate.useHighlight)
                           ? Theme.secondaryHighlightColor
                           : Theme.secondaryColor

                    text: {
                        if (model.audioConnectionState === BluetoothDevice.AudioConnected) {
                            //: Indicates a bluetooth audio connection was succesfully established to the selected device
                            //% "Audio connected"
                            return qsTrId("components_bluetooth-la-connected_audio")
                        } else if (model.audioConnectionState === BluetoothDevice.AudioConnecting) {
                            //: Indicates a bluetooth audio connection is being established to the selected device
                            //% "Connecting audio"
                            return qsTrId("components_bluetooth-la-connecting_audio")
                        } else if (model.audioConnectionState === BluetoothDevice.AudioDisconnecting) {
                            //: Indicates a bluetooth audio connection is being disconnected from the selected device
                            //% "Disconnecting audio"
                            return qsTrId("components_bluetooth-la-disconnecting_audio")
                        } else if (model.inputConnectionState === KnownDevicesModel.InputConnected) {
                            //% "Connected"
                            return qsTrId("components_bluetooth-la-connected")
                        } else if (model.inputConnectionState === KnownDevicesModel.InputConnecting) {
                            //% "Connecting"
                            return qsTrId("components_bluetooth-la-connecting")
                        } else {
                            return ""
                        }
                    }

                    Behavior on opacity { FadeAnimation {} }
                }

                Image {
                    id: trustedIcon
                    anchors {
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                        verticalCenter: icon.verticalCenter
                    }
                    visible: model.trusted
                    source: "image://theme/icon-s-certificates"
                    opacity: icon.opacity
                }
            }
        }
    }

    // Need this column for the height animation; if the animation is placed in the SectionHeader,
    // its vertical text alignment is wrong
    Item {
        width: parent.width
        height: _showOtherDevicesHeader ? Theme.itemSizeExtraSmall : 0

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        SectionHeader {
            //: List of bluetooth devices found nearby
            //% "Other devices nearby"
            text: qsTrId("components_bluetooth-he-nearby_devices")

            opacity: _showOtherDevicesHeader ? 1.0 : 0.0

            Behavior on opacity { FadeAnimation {} }
        }
    }

    Column {
        width: parent.width

        opacity: nearbyDevices.visibleItemCount ? 1.0 : 0.0

        Behavior on opacity { FadeAnimation {} }

        Repeater {
            id: nearbyDevices

            property int visibleItemCount: count - _hiddenItemsCount
            property int _hiddenItemsCount
            onCountChanged: if (count == 0) _hiddenItemsCount = 0

            model: DiscoveredDevicesModel { id: nearbyDevicesModel }

            delegate: BackgroundItem {
                id: nearbyDeviceDelegate

                property bool matchesProfileHint: root._matchesProfileHint(model.profiles, model.classOfDevice)
                property bool useHighlight: highlightSelectedDevice && model.address === root.selectedDevice

                width: root.width
                visible: !model.paired && root.excludedDevices.indexOf(model.address.toUpperCase()) < 0

                onVisibleChanged: {
                    nearbyDevices._hiddenItemsCount += (visible ? -1: 1)
                }

                Image {
                    id: nearbyDeviceIcon
                    x: Theme.paddingLarge
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/" + model.jollaIcon
                    opacity: nearbyDeviceDelegate.matchesProfileHint || nearbyDeviceDelegate.useHighlight ? 1 : 0.5
                }

                Label {
                    anchors {
                        left: nearbyDeviceIcon.right
                        leftMargin: Theme.paddingMedium
                        right: parent.right
                        rightMargin: Theme.paddingLarge
                        verticalCenter: parent.verticalCenter
                    }
                    text: model.alias.length ? model.alias : model.address
                    truncationMode: TruncationMode.Fade
                    color: (nearbyDeviceDelegate.highlighted || nearbyDeviceDelegate.useHighlight)
                           ? Theme.highlightColor
                           : Theme.rgba(Theme.primaryColor, nearbyDeviceDelegate.matchesProfileHint ? 1.0 : 0.5)
                }

                onClicked: {
                    root.selectedDevice = model.address
                    root.selectedDevicePaired = model.paired
                    root.deviceClicked(model.address)
                }
            }
        }
    }

    Timer {
        id: updateNearbyDevicesTimer
        interval: 100
        onTriggered: {
            if (adapter.discovering === _prevDiscoveryValue) {
                return
            }
            if (adapter.discovering) {
                discoveryProgressBar.indeterminate = false
                root._showDiscoveryProgress = true
                nearbyDevicesModel.clear()
                discoveryDummyAnim.start()
            } else {
                discoveryDummyAnim.stop()
                root._showDiscoveryProgress = false
            }
            _prevDiscoveryValue = adapter.discovering
        }
    }

    BluetoothAdapter {
        id: adapter

        onDiscoveringChanged: {
            // delay ui update to avoid bluez 4.101 bug where discovery suddenly switches off and on
            updateNearbyDevicesTimer.start()

            // avoid bluez 4.101 bug where discovery restarts itself after stopping
            if (!discovering) {
                stopDiscovery()
            }
        }
    }
}
