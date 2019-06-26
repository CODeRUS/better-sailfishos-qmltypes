import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: header

    property Item pressedMenu
    readonly property Item highlightItem: pressedMenu
                ? pressedMenu.highlightItem
                : null

    height: Theme.itemSizeSmall

    Label {
        id: label

        anchors.centerIn: parent

        font.pixelSize: Screen.sizeCategory >= Screen.Large ? Theme.fontSizeSmall : Theme.fontSizeExtraSmall
        font.bold: Screen.sizeCategory < Screen.Large
        color: Theme.colorScheme == Theme.LightOnDark
               ? Theme.highlightColor : Theme.highlightFromColor(Theme.highlightColor, Theme.LightOnDark)

        textFormat: Text.AutoText
        text: header.highlightItem
              ? header.pressedMenu.title(header.highlightItem.value)
              : ""
        opacity: header.pressedMenu && header.pressedMenu.pressed || timer.running
                ? 1.0
                : 0.0

        Behavior on opacity { FadeAnimation {} }
    }

    Timer {
        id: timer

        interval: 3000
        running: header.pressedMenu && !header.pressedMenu.pressed
    }
}
