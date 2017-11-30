import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import MeeGo.Connman 0.2
import Nemo.DBus 2.0
import org.kde.bluezqt 1.0 as BluezQt

Column {
    id: root

    property string selectedDevice
    property bool selectedDevicePaired
    readonly property bool empty: pairedDevices.visibleItemCount == 0 && nearbyDevices.visibleItemCount == 0
    readonly property bool discovering: adapter && adapter.discovering
    property bool highlightSelectedDevice: true
    property bool requirePairing

    property bool showPairedDevicesHeader
    property var excludedDevices: []    // addresses expected to be in upper case
    property int preferredProfileHint: -1  // darken devices that don't match this filter

    property QtObject adapter: _bluetoothManager.usableAdapter
    property bool autoStartDiscovery    // automatically start discovery when powered

    property QtObject _bluetoothManager : BluezQt.Manager
    readonly property bool _showDiscoveryProgress: adapter && adapter.discovering
    readonly property bool _showPairedDevicesHeader: showPairedDevicesHeader && !_showDiscoveryProgress && pairedDevices.visibleItemCount > 0
    property QtObject _devicePendingPairing
    property var _connectingDevices: []
    property bool _autoStartDiscoveryTriggered

    signal deviceClicked(string address)    
    signal devicePaired(string address)

    function startDiscovery() {
        if (!adapter || adapter.discovering) {
            return
        }
        adapter.startDiscovery()
        root.selectedDevice = ""
    }

    function stopDiscovery() {
        if (adapter && adapter.discovering) {
            adapter.stopDiscovery()
        }
    }

    function addConnectingDevice(addr) {
        addr = addr.toUpperCase()
        for (var i=0; i<_connectingDevices.length; i++) {
            if (_connectingDevices[i].toUpperCase() == addr) {
                return
            }
        }
        var devices = _connectingDevices
        devices.push(addr)
        _connectingDevices = devices
    }

    function removeConnectingDevice(addr) {
        addr = addr.toUpperCase()
        var devices = _connectingDevices
        for (var i=0; i<devices.length; i++) {
            if (devices[i].toUpperCase() == addr) {
                devices.splice(i, 1)
                _connectingDevices = devices
                return
            }
        }
    }

    function _matchesProfileHint(profiles, classOfDevice) {
        return preferredProfileHint < 0
                || BluetoothProfiles.profileMatchesDeviceProperties(preferredProfileHint, profiles, classOfDevice)
    }

    function _deviceClicked(address, paired) {
        _devicePendingPairing = null
        selectedDevice = address
        selectedDevicePaired = paired
        deviceClicked(address)
        if (requirePairing && !paired) {
            if (adapter.discovering) {
                stopDiscovery()
            }
            _devicePendingPairing = _bluetoothManager.deviceForAddress(address)
            if (_devicePendingPairing) {
                pairingService.call("pairWithDevice", [address])
            }
        }
    }

    function _autoStartDiscovery() {
        if (adapter && adapter.powered && !adapter.discovering
                && autoStartDiscovery && !_autoStartDiscoveryTriggered) {
            _autoStartDiscoveryTriggered = true
            startDiscovery()
        }
    }

    function _matchingItemCount(repeater, propertyName, propertyValue) {
        var result = 0
        for (var i=0; i<repeater.count; i++) {
            var obj = repeater.itemAt(i)
            if (obj && obj[propertyName] === propertyValue) {
                result++
            }
        }
        return result
    }

    width: parent.width

    Item {
        width: parent.width
        height: (root._showPairedDevicesHeader || root._showDiscoveryProgress) ? discoveryProgressBar.height : 0

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        SectionHeader {
            id: pairedDevicesHeader
            height: discoveryProgressBar.height
            opacity: root._showPairedDevicesHeader ? 1.0 : 0

            //% "Paired devices"
            text: qsTrId("components_bluetooth-la-paired-devices")

            Behavior on opacity { FadeAnimation {} }
        }

        ProgressBar {
            id: discoveryProgressBar

            width: parent.width
            opacity: root._showDiscoveryProgress ? 1.0 : 0
            indeterminate: true

            //: Informs user that we are currently searching for nearby Bluetooth devices
            //% "Searching for devices"
            label: qsTrId("components_bluetooth-he-discovering")

            Behavior on opacity { FadeAnimation {} }
        }
    }

    Column {
        width: parent.width

        Repeater {
            id: pairedDevices

            property int visibleItemCount

            function _resetVisibleItemCount() {
                pairedDevices.visibleItemCount = root._matchingItemCount(pairedDevices, "display", true)
            }

            onCountChanged: {
                pairedDevices._resetVisibleItemCount()
            }

            model: BluezQt.DevicesModel { id: knownDevicesModel }

            delegate: ListItem {
                id: pairedDelegate

                property bool showConnectionStatus: model.Connected || isConnecting || minConnectionStatusTimeout.running
                property bool isConnecting: _connectingDevices.indexOf(model.Address.toUpperCase()) >= 0

                property bool matchesProfileHint: root._matchesProfileHint(model.Uuids, model.Class)
                property bool useHighlight: highlighted || (highlightSelectedDevice && model.Address === root.selectedDevice)
                property bool display: model.Paired && model.Address && root.excludedDevices.indexOf(model.Address.toUpperCase()) < 0

                function _removePairing() {
                    var device = _bluetoothManager.deviceForAddress(model.Address)
                    if (device && root.adapter) {
                        root.adapter.removeDevice(device)
                    }
                }

                visible: display

                onIsConnectingChanged: {
                    if (isConnecting) {
                        minConnectionStatusTimeout.start()
                    }
                }

                Timer {
                    id: minConnectionStatusTimeout
                    interval: 2000
                }

                menu: Component {
                    ContextMenu {
                        MenuItem {
                            //: Show settings for the selected bluetooth device
                            //% "Device settings"
                            text: qsTrId("components_bluetooth-me-device_settings")

                            onClicked: {
                                var device = _bluetoothManager.deviceForAddress(model.Address)
                                if (device) {
                                    pageStack.push(Qt.resolvedUrl("PairedDeviceSettings.qml"), {"bluetoothDevice": device})
                                }
                            }
                        }

                        MenuItem {
                            //: Remove the pairing with the selected bluetooth device
                            //% "Remove pairing"
                            text: qsTrId("components_bluetooth-me-pairing_remove")

                            onClicked: {
                                pairedDelegate._removePairing()
                            }
                        }
                    }
                }

                onDisplayChanged: {
                    pairedDevices._resetVisibleItemCount()
                }

                onClicked: {
                    root._deviceClicked(model.Address, model.Paired)
                }

                BluetoothDeviceInfo {
                    id: pairedDeviceInfo
                    address: model.Address
                    deviceClass: model.Class
                }

                Image {
                    id: icon
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/" + pairedDeviceInfo.icon + (pairedDelegate.useHighlight ? "?" + Theme.highlightColor : "")
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
                    text: model.FriendlyName
                    truncationMode: TruncationMode.Fade
                    color: pairedDelegate.useHighlight
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
                    color: pairedDelegate.useHighlight
                           ? Theme.secondaryHighlightColor
                           : Theme.secondaryColor

                    text: {
                        if (model.Connected) {
                            //% "Connected"
                            return qsTrId("components_bluetooth-la-connected")
                        } else if (pairedDelegate.isConnecting || minConnectionStatusTimeout.running) {
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
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: icon.verticalCenter
                    }
                    visible: model.Trusted
                    source: "image://theme/icon-s-certificates" + (pairedDelegate.useHighlight ? "?" + Theme.highlightColor : "")
                    opacity: icon.opacity
                }
            }
        }
    }

    // Need this column for the height animation; if the animation is placed in the SectionHeader,
    // its vertical text alignment is wrong
    Item {
        width: parent.width
        height: nearbyDevices.visibleItemCount ? Theme.itemSizeExtraSmall : 0

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        SectionHeader {
            //: List of bluetooth devices found nearby
            //% "Nearby devices"
            text: qsTrId("components_bluetooth-he-nearby_devices_header")

            opacity: nearbyDevices.visibleItemCount ? 1.0 : 0.0

            Behavior on opacity { FadeAnimation {} }
        }
    }

    Column {
        width: parent.width

        opacity: nearbyDevices.visibleItemCount ? 1.0 : 0.0

        Behavior on opacity { FadeAnimation {} }

        Repeater {
            id: nearbyDevices

            property int visibleItemCount

            function _resetVisibleItemCount() {
                nearbyDevices.visibleItemCount = root._matchingItemCount(nearbyDevices, "display", true)
            }

            onCountChanged: {
                nearbyDevices._resetVisibleItemCount()
            }

            model: BluezQt.DevicesModel { id: nearbyDevicesModel }

            delegate: BackgroundItem {
                id: nearbyDeviceDelegate

                property bool matchesProfileHint: root._matchesProfileHint(model.Uuids, model.Class)
                property bool useHighlight: highlighted || (highlightSelectedDevice && model.Address === root.selectedDevice)
                property bool display: !model.Paired && model.Address && root.excludedDevices.indexOf(model.Address.toUpperCase()) < 0

                width: root.width
                visible: display

                onDisplayChanged: {
                    nearbyDevices._resetVisibleItemCount()
                }

                BluetoothDeviceInfo {
                    id: nearbyDeviceInfo
                    address: model.Address
                    deviceClass: model.Class
                }

                Image {
                    id: nearbyDeviceIcon
                    x: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    source: "image://theme/" + nearbyDeviceInfo.icon + (nearbyDeviceDelegate.useHighlight ? "?" + Theme.highlightColor : "")
                    opacity: nearbyDeviceDelegate.matchesProfileHint || nearbyDeviceDelegate.useHighlight ? 1 : 0.5
                }

                Label {
                    anchors {
                        left: nearbyDeviceIcon.right
                        leftMargin: Theme.paddingMedium
                        right: parent.right
                        rightMargin: Theme.horizontalPageMargin
                        verticalCenter: parent.verticalCenter
                    }
                    text: model.FriendlyName
                    truncationMode: TruncationMode.Fade
                    color: nearbyDeviceDelegate.useHighlight
                           ? Theme.highlightColor
                           : Theme.rgba(Theme.primaryColor, nearbyDeviceDelegate.matchesProfileHint ? 1.0 : 0.5)
                }

                onClicked: {
                    root._deviceClicked(model.Address, model.Paired)
                }
            }
        }
    }

    Connections {
        target: root._devicePendingPairing
        onPairedChanged: {
            root.devicePaired(root._devicePendingPairing.address)
            root._devicePendingPairing = null
        }
    }

    DBusInterface {
        id: pairingService
        service: "com.jolla.lipstick"
        path: "/bluetooth"
        iface: "com.jolla.lipstick"
    }

    onAdapterChanged: {
        if (adapter) {
            root._autoStartDiscovery()
        }
    }

    onAutoStartDiscoveryChanged: {
        if (autoStartDiscovery) {
            root._autoStartDiscovery()
        }
    }

    Connections {
        target: root.adapter
        onPoweredChanged: {
            root._autoStartDiscovery()
        }
    }
}
