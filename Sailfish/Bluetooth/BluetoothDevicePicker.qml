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
    readonly property bool empty: pairedDevices.count == 0 && nearbyDevices.count == 0
    readonly property bool discovering: adapter && adapter.discovering
    property bool highlightSelectedDevice
    property bool requirePairing

    property bool showPairedDevicesHeader
    property bool showPairedDevices: true
    property var excludedDevices: []    // addresses expected to be in upper case
    property int preferredProfileHint: -1  // darken devices that don't match this filter

    property QtObject adapter: _bluetoothManager.usableAdapter
    property bool autoStartDiscovery    // automatically start discovery when powered

    property QtObject _bluetoothManager : BluezQt.Manager
    readonly property bool _showDiscoveryProgress: adapter && adapter.discovering
    readonly property bool _showPairedDevicesHeader: showPairedDevices && showPairedDevicesHeader && !_showDiscoveryProgress && pairedDevices.count > 0
    property QtObject _devicePendingPairing
    property bool _autoStartDiscoveryTriggered

    signal deviceClicked(string address)    
    signal devicePaired(string address)

    onSelectedDeviceChanged: {
        if (root.selectedDevice === "") {
            pairedDevices.clearSelectedDevice()
            nearbyDevices.clearSelectedDevice()
        }
    }

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
        pairedDevices.addConnectingDevice(addr)
        nearbyDevices.addConnectingDevice(addr)
    }

    function removeConnectingDevice(addr) {
        pairedDevices.removeConnectingDevice(addr)
        nearbyDevices.removeConnectingDevice(addr)
    }

    function removeDevice(addr) {
        var device = _bluetoothManager.deviceForAddress(addr)
        if (device && root.adapter) {
            root.adapter.removeDevice(device)
        }
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

    function _deviceSettings(address) {
        var device = root._bluetoothManager.deviceForAddress(address)
        if (device) {
            pageStack.animatorPush(Qt.resolvedUrl("PairedDeviceSettings.qml"), {"bluetoothDevice": device})
        }
    }

    BluetoothDeviceColumnView {
        id: pairedDevices
        filters: BluezQt.DevicesModelPrivate.PairedDevices
        excludedDevices: root.excludedDevices
        visible: root.showPairedDevices ? 1.0 : 0
        highlightSelectedDevice: root.highlightSelectedDevice
        onDeviceItemClicked: root._deviceClicked(address, paired)
        onDeviceSettingsClicked: root._deviceSettings(address)
        onRemoveDeviceClicked: root.removeDevice(address)
    }

    // Need this column for the height animation; if the animation is placed in the SectionHeader,
    // its vertical text alignment is wrong
    Item {
        width: parent.width
        height: nearbyDevices.count > 0 ? Theme.itemSizeExtraSmall : 0

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad } }

        SectionHeader {
            //: List of bluetooth devices found nearby
            //% "Nearby devices"
            text: qsTrId("components_bluetooth-he-nearby_devices_header")

            opacity: nearbyDevices.count > 0 ? 1.0 : 0.0

            Behavior on opacity { FadeAnimation {} }
        }
    }

    BluetoothDeviceColumnView {
        id: nearbyDevices
        filters: BluezQt.DevicesModelPrivate.UnpairedDevices
        excludedDevices: root.excludedDevices
        highlightSelectedDevice: root.highlightSelectedDevice
        onDeviceItemClicked: root._deviceClicked(address, paired)
        onDeviceSettingsClicked: root._deviceSettings(address)
        onRemoveDeviceClicked: root.removeDevice(address)
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
