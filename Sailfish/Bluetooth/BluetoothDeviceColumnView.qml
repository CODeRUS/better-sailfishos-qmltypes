import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import org.kde.bluezqt 1.0 as BluezQt

ColumnView {
    id: columnView

    property var filters
    property var excludedDevices: []
    property bool highlightSelectedDevice

    signal deviceItemClicked(string address, bool paired)
    signal deviceSettingsClicked(string address)
    signal removeDeviceClicked(string address)

    property var _connectingDevices: []
    property string _selectedDevice: ""

    //width: parent.width
    itemHeight: Theme.itemSizeSmall

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

    function clearSelectedDevice() {
        _selectedDevice = ""
    }

    function _matchesProfileHint(profiles, classOfDevice) {
        return preferredProfileHint < 0
                || BluetoothProfiles.profileMatchesDeviceProperties(preferredProfileHint, profiles, classOfDevice)
    }

    model: BluezQt.DevicesModel {
        id: devicesModel
        filters: columnView.filters
        hiddenAddresses: columnView.excludedDevices
    }

    delegate: ListItem {
        id: deviceDelegate

        property bool showConnectionStatus: model.Connected || isConnecting || minConnectionStatusTimeout.running
        property bool isConnecting: _connectingDevices.indexOf(model.Address.toUpperCase()) >= 0

        property bool matchesProfileHint: columnView._matchesProfileHint(model.Uuids, model.Class)
        property bool useHighlight: highlighted || (highlightSelectedDevice && model.Address === columnView._selectedDevice)

        onIsConnectingChanged: {
            if (isConnecting) {
                minConnectionStatusTimeout.start()
            }
        }

        onClicked: {
            columnView._selectedDevice = model.Address
            columnView.deviceItemClicked(model.Address, model.Paired)
        }

        Timer {
            id: minConnectionStatusTimeout
            interval: 2000
        }

        menu: Component {
            ContextMenu {
                MenuItem {
                    text: {
                        if (model.Paired) {
                            //: Show settings for the selected bluetooth device
                            //% "Device settings"
                            return qsTrId("components_bluetooth-me-device_settings")
                        } else {
                            //: Show info for the selected bluetooth device
                            //% "Details"
                            return qsTrId("components_bluetooth-me-details")
                        }

                    }

                    onClicked: columnView.deviceSettingsClicked(model.Address)
                }

                MenuItem {
                    text: {
                        if (model.Paired) {
                            //: Remove the pairing with the selected bluetooth device
                            //% "Remove pairing"
                            return qsTrId("components_bluetooth-me-pairing_remove")
                        } else {
                            //: Forget the selected bluetooth device
                            //% "Forget device"
                            return qsTrId("components_bluetooth-me-device_forget")
                        }
                    }

                    onClicked: {
                        if (model.Address === columnView._selectedDevice) {
                            columnView._selectedDevice = ""
                        }
                        columnView.removeDeviceClicked(model.Address)
                    }
                }
            }
        }

        BluetoothDeviceInfo {
            id: deviceInfo
            address: model.Address
            deviceClass: model.Class
        }

        Image {
            id: icon
            x: Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            source: "image://theme/" + deviceInfo.icon + (deviceDelegate.useHighlight ? "?" + Theme.highlightColor : "")
            opacity: deviceDelegate.matchesProfileHint || deviceDelegate.useHighlight ? 1 : Theme.opacityHigh
        }

        Label {
            id: deviceNameLabel
            anchors {
                left: icon.right
                leftMargin: Theme.paddingMedium
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            y: deviceDelegate.contentHeight/2 - implicitHeight/2
               - (showConnectionStatus ? connectedLabel.implicitHeight/2 : 0)
            text: model.FriendlyName
            truncationMode: TruncationMode.Fade
            color: deviceDelegate.useHighlight
                   ? Theme.highlightColor
                   : Theme.rgba(Theme.primaryColor, deviceDelegate.matchesProfileHint ? 1.0 : Theme.opacityHigh)

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
            color: deviceDelegate.useHighlight
                   ? Theme.secondaryHighlightColor
                   : Theme.secondaryColor

            text: {
                if (model.Connected) {
                    //% "Connected"
                    return qsTrId("components_bluetooth-la-connected")
                } else if (deviceDelegate.isConnecting || minConnectionStatusTimeout.running) {
                    //% "Connecting"
                    return qsTrId("components_bluetooth-la-connecting")
                } else {
                    return ""
                }
            }

            Behavior on opacity { FadeAnimation {} }
        }

        Image {
            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
                verticalCenter: parent.verticalCenter
            }
            visible: model.Paired && model.Trusted
            source: "image://theme/icon-s-certificates" + (deviceDelegate.useHighlight ? "?" + Theme.highlightColor : "")
            opacity: icon.opacity
        }
    }
}
