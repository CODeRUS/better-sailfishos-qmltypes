import QtQuick 2.0
import Sailfish.Silica 1.0

Label {
    property bool highlight

    width: parent.width
    wrapMode: Text.Wrap
    textFormat: Text.AutoText
    horizontalAlignment: Qt.AlignHCenter
    font.pixelSize: Theme.fontSizeSmall
    color: highlight ? Theme.highlightColor : Theme.primaryColor
}
