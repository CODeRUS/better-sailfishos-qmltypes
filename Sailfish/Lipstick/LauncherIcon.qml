import QtQuick 2.0
import Sailfish.Silica 1.0

HighlightImage {
    property string icon
    property bool pressed
    property real size: Theme.iconSizeLauncher

    sourceSize.width: size
    sourceSize.height: size
    width: size
    height: size
    highlighted: pressed

    monochromeWeight: colorWeight
    highlightColor: Theme.highlightBackgroundColor

    source: {
        if (icon.indexOf(':/') !== -1 || icon.indexOf("data:image/png;base64") === 0) {
            return icon
        } else if (icon.indexOf('/') === 0) {
            return 'file://' + icon
        } else if (icon.length) {
            return 'image://theme/' + icon
        } else {
            return ""
        }
    }
}
