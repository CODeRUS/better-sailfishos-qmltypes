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

        color: Theme.secondaryHighlightColor
    }

    Image {
        id: image
        anchors.centerIn: parent
    }
}
