import QtQuick 2.1
import Sailfish.Silica 1.0

MouseArea {
    id: root

    property alias text: label.text

    property bool down: pressed && containsMouse
    property bool highlighted: down
    property bool active

    property real leftMargin: isPortrait ? Theme.horizontalPageMargin : Theme.paddingLarge
    property real rightMargin: Theme.horizontalPageMargin

    height: text != "" ? Theme.itemSizeMedium : 0
    width: parent.width

    Row {
        id: layoutHelper
        height: parent.height
        spacing: Theme.paddingSmall
        anchors {
            right: iconRight.left
            rightMargin: Theme.paddingSmall
            leftMargin: root.leftMargin
        }

        states: State {
            when: active

            AnchorChanges {
                target: layoutHelper
                anchors.right: undefined
                anchors.left: parent.left
            }
        }

        transitions: Transition {
            AnchorAnimation { duration: 200 }
        }

        Image {
            id: iconLeft
            anchors.verticalCenter: parent.verticalCenter
            source: "image://theme/icon-m-right" + (down ? ("?" + Theme.highlightColor) : "")
            opacity: active ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
        }

        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            color: highlighted ? Theme.secondaryHighlightColor
                               : active
                                 ? Theme.highlightColor
                                 : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeLarge
        }
    }

    Image {
        id: iconRight
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: root.rightMargin
        }
        source: "image://theme/icon-m-down" + (down ? ("?" + Theme.highlightColor) : "")
        opacity: active ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation {} }
    }
}
