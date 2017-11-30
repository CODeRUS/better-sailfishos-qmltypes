import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: menuItem

    property url icon
    property var value

    property string property
    property QtObject settings

    property QtObject menu

    property bool persistentHighlight
    readonly property bool selected: settings[property] == value
    readonly property bool highlighted: (parent.open || parent.pressed) && ((persistentHighlight && selected) || menuItem.pressed)

    width: parent.width
    height: selected ? parent.width : parent.itemHeight

    onSelectedChanged: {
        if (selected && parent) {
            parent.currentIndex = index
            parent.currentItem = menuItem
        }
    }

    onParentChanged: {
        if (selected && parent) {
            parent.currentIndex = index
            parent.currentItem = menuItem
        }
    }

    onClicked: {
        settings[property] = value
    }

    Item {
        anchors.fill: parent

        opacity: menuItem.selected || !menuItem.parent ? 1.0 : menuItem.parent.itemOpacity
        visible: menuItem.selected || (menuItem.parent && menuItem.parent.itemsVisible)

        Rectangle {
            anchors.centerIn: parent

            width: Theme.itemSizeExtraSmall
            height: Theme.itemSizeExtraSmall

            radius: width / 2

            color: Theme.highlightColor
            opacity: menuItem.highlighted ? 0.4 : 0.0
            Behavior on opacity { FadeAnimation {} }
        }

        Image {
            anchors.centerIn: parent
            source: menuItem.pressed
                    ? menuItem.icon + "?" + Theme.highlightColor
                    : menuItem.icon
        }
    }
}
