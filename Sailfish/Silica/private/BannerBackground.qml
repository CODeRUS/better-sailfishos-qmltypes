import QtQuick 2.6
import Sailfish.Silica 1.0

Rectangle {
    property bool highlighted
    radius: Theme.paddingSmall
    color: Qt.tint(Theme.highlightBackgroundColor, Theme.colorScheme == Theme.LightOnDark ? Qt.rgba(0, 0, 0, Theme.opacityFaint)
                                                                                          : Qt.rgba(1, 1, 1, Theme.opacityFaint))

    Rectangle {
        visible: highlighted
        anchors.fill: parent
        radius: parent.radius
        color: Theme.highlightDimmerColor
        opacity: Theme.opacityLow
    }
}
