import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import org.kde.bluezqt 1.0 as BluezQt

Page {
    id: root

    property QtObject bluetoothDevice

    function qsTrIdStrings() {
        //: Shown in place of the Bluetooth profile name for non-standard profiles
        //% "other unrecognized profiles"
        QT_TRID_NOOP("components_bluetooth-la-other_unrecognized_profiles")
    }

    function updateProfilesAndServicesLabels() {
        var profiles = []
        var services = []
        for (var i=0; i<bluetoothDevice.uuids.length; i++) {
            var profile = BluetoothProfiles.profileNameFromUuid(bluetoothDevice.uuids[i].toUpperCase())
            if (profile.length > 0) {
                if (profiles.indexOf(profile) < 0) {
                    profiles.push(profile)
                }
            } else {
                var service = BluetoothProfiles.serviceNameFromUuid(bluetoothDevice.uuids[i].toUpperCase())
                if (service.length > 0 && services.indexOf(service) < 0) {
                    services.push(service)
                }
            }
        }

        //: List of bluetooth profiles that are supported by this bluetooth device
        //% "Supported profiles: %1"
        profilesLabel.text = qsTrId("components_bluetooth-la-profiles").arg(profiles.join(', '))

        if (services.length > 0) {
            //: List of bluetooth low energy services that this bluetooth device has
            //% "Low Energy services: %1"
            servicesLabel.text = qsTrId("components_bluetooth-la-low_energy_services").arg(services.join(', '))
        }
    }

    Component.onCompleted: updateProfilesAndServicesLabels()

    Connections {
        target: bluetoothDevice
        onUuidsChanged: updateProfilesAndServicesLabels()
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content

            width: root.width

            PageHeader {
                title: {
                    if (bluetoothDevice.paired) {
                        //% "Paired device"
                        return qsTrId("components_bluetooth-he-paired_device")
                    } else {
                        //% "Nearby device"
                        return qsTrId("components_bluetooth-he-nearby_device")
                    }
                }
            }

            TextField {
                width: root.width

                //: Name or nickname of bluetooth device
                //% "Device name"
                label: qsTrId("components_bluetooth-la-device_name")

                //: Placeholder test for bluetooth device nickname
                //% "Nickname"
                placeholderText: qsTrId("components_bluetooth-la-device_nickname")

                text: root.bluetoothDevice.name

                onActiveFocusChanged: {
                    if (!activeFocus) {
                        root.bluetoothDevice.name = text
                    }
                }

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: root.focus = true
            }


            BluetoothDeviceTypeComboBox {
                width: root.width
                deviceAddress: root.bluetoothDevice.address
                deviceClass: root.bluetoothDevice.deviceClass
            }

            TrustBluetoothDeviceSwitch {
                visible: root.bluetoothDevice.paired
                checked: root.bluetoothDevice.trusted

                onCheckedChanged: {
                    root.bluetoothDevice.trusted = checked
                }
            }

            Label {
                id: profilesLabel
                x: Theme.horizontalPageMargin
                width: root.width - x*2
                height: implicitHeight + Theme.paddingMedium
                verticalAlignment: Text.AlignBottom
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                color: Theme.rgba(Theme.highlightColor, 0.9)
            }

            Label {
                id: servicesLabel
                x: Theme.horizontalPageMargin
                width: root.width - x*2
                height: implicitHeight + Theme.paddingMedium
                verticalAlignment: Text.AlignBottom
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                color: Theme.rgba(Theme.highlightColor, 0.9)
            }
        }
    }
}
