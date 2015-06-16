import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

Image {
    property string icon
    property bool pressed
    property real size: Theme.iconSizeLauncher

    sourceSize.width: size
    sourceSize.height: size
    width: size
    height: size
    layer.effect: PressEffect {}
    layer.enabled: pressed

    source: {
        if (icon.indexOf(':/') !== -1 || icon.indexOf("data:image/png;base64") === 0) {
            return icon
        } else if (icon.indexOf('/') === 0) {
            return 'file://' + icon
        } else {
            return 'image://theme/' + icon
        }
    }
}
