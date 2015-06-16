import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: backgroundItem

    width: parent ? parent.width : 0
    implicitHeight: Math.max(Theme.itemSizeSmall, title.height + subtitle.height)
    opacity: enabled ? 1.0 : 0.5

    property bool down: pressed && containsMouse
    property bool selected
    property alias title: title.text
    property alias subtitle: subtitle.text
    property alias icon: image.source
    property alias iconOpacity: image.opacity

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightBackgroundColor
        opacity: selected || down ? Theme.highlightBackgroundOpacity : 0
        Behavior on opacity { FadeAnimation { duration: 100 } }
    }

    Label {
        id: title
        x: Theme.horizontalPageMargin
        width: parent.width - playIcon.width - 2*Theme.horizontalPageMargin
        anchors {
            verticalCenter: subtitle.height == 0 ? playIcon.verticalCenter : undefined
            top: subtitle.height > 0 ? parent.top : undefined
            topMargin: subtitle.height > 0 ? Theme.paddingSmall : 0
        }
        color: selected || down ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        id: subtitle
        width: title.width
        height: text.length ? (implicitHeight + Theme.paddingMedium) : 0
        anchors.top: title.bottom
        anchors.left: title.left
        font.pixelSize: Theme.fontSizeExtraSmall
        color: selected || down ? Theme.secondaryHighlightColor : Theme.secondaryColor
    }

    Item {
        id: playIcon

        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        width: Theme.itemSizeSmall; height: Theme.itemSizeSmall

        Image {
            id: image
            anchors.centerIn: parent
            opacity: backgroundItem.enabled ? (backgroundItem.down ? 1.0 : 0.8) : 0.4

            Behavior on opacity { FadeAnimation {} }
        }
    }
}
