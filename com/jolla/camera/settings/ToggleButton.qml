import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon
    property var model: []
    property string property
    property QtObject settings
    readonly property int nextIndex: (model.indexOf(settings[property]) + 1) % model.length

    width: Theme.itemSizeExtraSmall
    height: Theme.itemSizeExtraSmall

    onClicked: settings[property] = model[nextIndex]

    Rectangle {
        anchors.centerIn: parent

        width: Theme.itemSizeExtraSmall
        height: Theme.itemSizeExtraSmall

        radius: width / 2

        color: Theme.highlightColor
        opacity: menuItem.pressed ? 0.4 : 0.0
        Behavior on opacity { FadeAnimation {} }
    }

    Image {
        anchors.centerIn: parent
        source: menuItem.pressed
                ? menuItem.icon + "?" + Theme.highlightColor
                : menuItem.icon
    }
}
