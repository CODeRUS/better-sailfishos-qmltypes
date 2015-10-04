import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property alias interactionItem: photosItem

    signal itemClicked

    anchors.fill: parent

    Image {
        anchors.fill: parent

        source: Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-gallery-app-main.png")
    }

    BackgroundItem {
        id: photosItem

        anchors {
            top: parent.top
            topMargin: 2*Theme.paddingLarge
            left: parent.left
            right: parent.right
        }
        height: 825 * yScale

        highlightedColor: Theme.rgba(tutorialTheme.highlightColor, 0.3)
        enabled: appInfoLabel.opacity > 0

        onClicked: root.itemClicked()
    }
}
