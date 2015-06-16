import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import "btutil.js" as BtUtil

Page {
    id: root

    property QtObject bluetoothDevice

    function qsTrIdStrings() {
        //: Shown in place of the Bluetooth profile name for non-standard profiles
        //% "other unrecognized profiles"
        QT_TRID_NOOP("components_bluetooth-la-other_unrecognized_profiles")
    }

    function profilesList() {
        if (bluetoothDevice === null) {
            return
        }
        var ret = []
        var hasUnrecognizedProfiles = false
        for (var i=0; i<bluetoothDevice.profiles.length; i++) {
            var s = BtUtil.knownServiceUuids[bluetoothDevice.profiles[i].toUpperCase()]
            if (s === undefined) {
                hasUnrecognizedProfiles = true
            } else if (ret.indexOf(s) < 0) {
                ret.push(s)
            }
        }
        if (hasUnrecognizedProfiles) {
            ret.push(qsTrId("components_bluetooth-la-other_unrecognized_profiles"))
        }
        return ret.join(', ')
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: content.height

        Column {
            id: content

            width: root.width

            PageHeader {
                //% "Paired device"
                title: qsTrId("components_bluetooth-he-paired_device")
            }

            TextField {
                width: root.width

                //: Name or nickname of bluetooth device
                //% "Device name"
                label: qsTrId("components_bluetooth-la-device_name")

                //: Placeholder test for bluetooth device nickname
                //% "Nickname"
                placeholderText: qsTrId("components_bluetooth-la-device_nickname")

                text: root.bluetoothDevice !== null ? root.bluetoothDevice.alias : ""

                onTextChanged: {
                    if (root.bluetoothDevice !== null) {
                        root.bluetoothDevice.alias = text
                    }
                }

                EnterKey.enabled: text || inputMethodComposing
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: root.focus = true
            }


            BluetoothDeviceTypeComboBox {
                width: root.width
                deviceAddress: root.bluetoothDevice.address
                deviceClass: root.bluetoothDevice.classOfDevice
            }

            TrustBluetoothDeviceSwitch {
                checked: root.bluetoothDevice !== null && root.bluetoothDevice.trusted

                onCheckedChanged: {
                    if (root.bluetoothDevice !== null) {
                        root.bluetoothDevice.trusted = checked
                    }
                }
            }

            Label {
                x: Theme.horizontalPageMargin
                width: root.width - x*2
                height: implicitHeight + Theme.paddingMedium
                verticalAlignment: Text.AlignBottom
                font.pixelSize: Theme.fontSizeExtraSmall
                wrapMode: Text.Wrap
                color: Theme.rgba(Theme.highlightColor, 0.9)

                //: List of bluetooth profiles that are supported by this bluetooth device
                //% "Supported profiles: %1"
                text: qsTrId("components_bluetooth-la-profiles").arg(profilesList())
            }
        }
    }
}
