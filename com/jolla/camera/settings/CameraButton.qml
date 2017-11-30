import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    property alias icon: image
    property alias background: backgroundCircle
    property real size: Theme.itemSizeSmall

    width: Theme.itemSizeExtraLarge
    height: Theme.itemSizeExtraLarge

    anchors.centerIn: parent

    Rectangle {
        id: backgroundCircle

        radius: width / 2
        width: image.width
        height: width

        anchors.centerIn: parent

        opacity: 0.6
        color: Theme.highlightColor
    }

    Image {
        id: image
        anchors.centerIn: parent
    }
}
