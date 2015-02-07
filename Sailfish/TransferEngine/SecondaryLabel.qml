import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Label {
    property bool interactive
    font.pixelSize: Theme.fontSizeMedium
    color: interactive ? Theme.secondaryHighlightColor : Theme.secondaryColor
}
