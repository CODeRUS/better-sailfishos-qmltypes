import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

SettingItem {
    id: root

    // the GConf key, e.g. '/jolla/examples/settings/integer/fakesys1key1'
    property alias saveKey: configValue.key
    property alias defaultSaveValue: configValue.defaultValue

    property alias minimumValue: slider.minimumValue
    property alias maximumValue: slider.maximumValue

    width: slider.width
    height: slider.height

    Slider {
        id: slider
        width: screen.width
        highlighted: down || root.highlighted

        onValueChanged: configValue.value = value

        onPressAndHold: {
            enabled = false // don't move slider on press+hold
            root.pressAndHold(mouse)
        }
        onReleased: enabled = true
        onCanceled: enabled = true
    }

    // todo investigate the cost and alternatives to using ConfigurationValue for every delegate
    ConfigurationValue {
        id: configValue

        // need this instead of binding Slider.value to this value as
        // Slider internally overrides that binding.
        onValueChanged: slider.value = value
    }
}
