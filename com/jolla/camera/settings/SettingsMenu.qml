import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    id: menu

    property var title
    property alias model: repeater.model
    property alias delegate: repeater.delegate
    property Item currentItem
    property MouseArea pressedItem
    readonly property Item highlightItem: pressedItem && pressedItem.pressed
            ? pressedItem
            : currentItem
    property Item header

    property bool pressed: pressedItem && pressedItem.pressed

    onPressedChanged: {
        if (pressed && header) {
            header.pressedMenu = menu
        }
    }

    width: Screen.width / 4

    Repeater {
        id: repeater
    }
}
