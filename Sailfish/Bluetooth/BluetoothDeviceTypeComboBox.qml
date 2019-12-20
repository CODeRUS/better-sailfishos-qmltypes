import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import org.nemomobile.configuration 1.0

ComboBox {
    id: root

    property string deviceAddress
    property int deviceClass
    property url deviceValueIconSource

    visible: deviceTypesModel.count > 0
    value: ""

    function _loadIndex(index) {
        if (index >= 0 && index < deviceTypesModel.count) {
            var data = deviceTypesModel.get(index)
            deviceValueIconSource = "image://theme/" + data.icon
            deviceValueLabel.text = data.displayName
            deviceInfo.deviceType = data.type
        }
    }

    BluetoothDeviceInfo {
        id: deviceInfo
        address: deviceAddress
        deviceClass: root.deviceClass
        onDeviceTypeChanged: updateInfo()
        Component.onCompleted: updateInfo()

        function updateInfo() {
            if (deviceType >= 0) {
                root._loadIndex(deviceType == BluetoothDeviceTypesModel.UncategorizedIconType
                                ? deviceTypesModel.defaultIndex
                                : deviceTypesModel.indexOfType(deviceType))
            }
        }
    }

    BluetoothDeviceTypesModel {
        id: deviceTypesModel
        classFilter: root.deviceClass
    }

    // Use our own labels for 'type' and 'value' instead of using ComboBox's so that we can position
    // an icon between the type and value and ensure the value doesn't wrap to the next line
    Label {
        id: deviceTypeLabel
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        color: root.highlighted ? Theme.highlightColor : Theme.primaryColor

        //: Type of bluetooth device
        //% "Type"
        text: qsTrId("components_bluetooth-la-bluetooth_device_type")
    }

    Image {
        id: deviceValueIcon
        anchors {
            left: deviceTypeLabel.right
            leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        source: deviceValueIconSource + "?" + (highlighted ? Theme.highlightColor : Theme.primaryColor)
    }

    Label {
        id: deviceValueLabel
        anchors {
            left: deviceValueIcon.right
            leftMargin: Theme.paddingMedium
            verticalCenter: parent.verticalCenter
        }
        color: Theme.highlightColor
    }

    menu: ContextMenu {

        Repeater {
            model: deviceTypesModel

            MenuItem {
                text: model.displayName
                horizontalAlignment: Text.AlignLeft
                x: deviceValueLabel.x

                onClicked: {
                    root._loadIndex(model.index)
                }

                Image {
                    id: deviceIcon
                    anchors {
                       right: parent.left
                       rightMargin: Theme.paddingMedium
                       verticalCenter: parent.verticalCenter
                    }
                    source: "image://theme/" + model.icon + (root.highlighted ? "?" + Theme.highlightColor : "")
                }
            }
        }
    }
}
