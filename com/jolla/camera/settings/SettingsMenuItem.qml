import QtQuick 2.0
import Sailfish.Silica 1.0

SettingsMenuItemBase {
    id: menuItem

    property url icon
    property alias iconVisible: image.visible

    Image {
        id: image

        anchors.centerIn: parent
        source: menuItem.pressed
                ? menuItem.icon + "?" + (Theme.colorScheme == Theme.LightOnDark
                                         ? Theme.highlightColor
                                         : Theme.highlightFromColor(Theme.highlightColor, Theme.LightOnDark))
                : menuItem.icon + "?" + Theme.lightPrimaryColor
        smooth: true
    }
}
