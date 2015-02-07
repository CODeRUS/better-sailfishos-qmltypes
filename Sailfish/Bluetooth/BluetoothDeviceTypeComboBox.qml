import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Bluetooth 1.0
import org.nemomobile.configuration 1.0

ComboBox {
    id: root

    property string deviceAddress
    property int deviceClass

    property int _saveTypeToConf

    visible: deviceTypesModel.count > 0
    value: ""

    function _loadIndex(index, saveToConf) {
        if (index >= 0 && index < deviceTypesModel.count) {
            var data = deviceTypesModel.get(index)
            deviceValueIcon.source = "image://theme/" + data.icon
            deviceValueLabel.text = data.displayName
            if (saveToConf) {
                deviceTypeConf.value = data.type
            }
        }
    }

    // ConfigurationValue won't load until after the defaultIndex, so make sure setting
    // the defaultIndex doesn't overwrite the config value
    Timer {
        id: waitForConfLoadTimer
        interval: 500
        onTriggered: {
            var data = deviceTypesModel.get(deviceTypesModel.defaultIndex)
            if (data.type !== undefined) {
                deviceTypeConf.value = data.type
            }
        }
    }

    ConfigurationValue {
        id: deviceTypeConf
        key: deviceTypesModel.deviceTypeConfigurationKey(root.deviceAddress)

        onValueChanged: {
            waitForConfLoadTimer.stop()
            var type = parseInt(deviceTypeConf.value)
            root._loadIndex(deviceTypesModel.indexOfType(type), false)
        }
    }

    BluetoothDeviceTypesModel {
        id: deviceTypesModel
        classFilter: root.deviceClass

        onDefaultIndexChanged: {
            root._loadIndex(defaultIndex, false)
            waitForConfLoadTimer.start()
        }
    }

    // Use our own labels for 'type' and 'value' instead of using ComboBox's so that we can position
    // an icon between the type and value and ensure the value doesn't wrap to the next line
    Label {
        id: deviceTypeLabel
        anchors {
            left: parent.left
            leftMargin: Theme.paddingLarge
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
                    root._loadIndex(model.index, true)
                }

                Image {
                    id: deviceIcon
                    anchors {
                       right: parent.left
                       rightMargin: Theme.paddingMedium
                       verticalCenter: parent.verticalCenter
                    }
                    source: "image://theme/" + model.icon
                }
            }
        }
    }
}
