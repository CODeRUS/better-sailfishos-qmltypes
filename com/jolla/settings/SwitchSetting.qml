import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

SettingItem {
    id: root

    // the GConf key, e.g. '/jolla/examples/settings/integer/fakesys1key1'
    property alias saveKey: configValue.key
    property alias defaultSaveValue: configValue.defaultValue

    property alias iconSource: switchItem.iconSource

    width: switchItem.width
    height: switchItem.height

    Switch {
        id: switchItem
        anchors.horizontalCenter: parent.horizontalCenter
        highlighted: down || root.highlighted

        onCheckedChanged: configValue.value = checked
        onPressAndHold: root.pressAndHold(mouse)
    }

    // todo investigate the cost and alternatives to using ConfigurationValue for every delegate
    ConfigurationValue {
        id: configValue

        // need this instead of binding Switch.checked to this value as
        // Switch internally overrides that binding.
        onValueChanged: switchItem.checked = (value === true)
    }
}
