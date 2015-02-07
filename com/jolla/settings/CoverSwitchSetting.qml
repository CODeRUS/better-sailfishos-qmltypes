import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.configuration 1.0

Image {
    id: root

    // the GConf key, e.g. '/jolla/examples/settings/integer/fakesys1key1'
    property alias saveKey: configValue.key
    property alias defaultSaveValue: configValue.defaultValue
    property string iconSource

    source: root.iconSource + "?" + Theme.highlightColor
    opacity: configValue.value === true ? 1.0 : 0.4
    fillMode: Image.PreserveAspectFit
    smooth: true

    // todo investigate the cost and alternatives to using ConfigurationValue for every delegate
    ConfigurationValue {
        id: configValue
    }
}
