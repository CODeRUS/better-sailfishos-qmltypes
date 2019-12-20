import QtQuick 2.5
import Sailfish.Silica 1.0

Rectangle {
    property var listItem

    parent: listItem.contentItem
    width: listItem.height
    height: listItem.width
    rotation: -90
    transformOrigin: Item.TopLeft
    y: listItem.height
    visible: listItem._showPress && !listItem.menuOpen

    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity) }
        GradientStop { position: 1.0; color: "transparent" }
    }
}
