import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property var value

    property string property
    property QtObject settings

    property bool selected: settings[property] == value

    width: parent.width
    height: width

    onSelectedChanged: {
        if (selected) {
            parent.currentItem = menuItem
        }
    }

    onPressed: {
        parent.pressedItem = menuItem
    }

    onClicked: {
        settings[property] = value
    }

    Rectangle {
        anchors.centerIn: parent
        width: Screen.sizeCategory >= Screen.Large
               ? Theme.iconSizeMedium + Theme.paddingMedium
               : Theme.iconSizeMedium + Theme.paddingSmall
        height: width
        radius: width / 2
        color: Theme.highlightBackgroundColor

        opacity: menuItem.selected || menuItem.pressed ? 0.2 : 0.0
        Behavior on opacity { FadeAnimation {} }
    }
}
