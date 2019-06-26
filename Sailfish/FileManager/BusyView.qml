import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private

Loader {
    id: root

    property string text
    property alias busy: windowGestureOverride.active

    parent: __silica_applicationwindow_instance
    active: enabled
    onActiveChanged: active = true // remove binding
    anchors.fill: parent

    Private.WindowGestureOverride {
        id: windowGestureOverride
    }

    sourceComponent: Item {
        id: busyView

        enabled: root.active
        opacity: enabled ? 1.0 : 0.0
        anchors.fill: parent
        Behavior on opacity { FadeAnimator { duration: 400 } }

        onEnabledChanged: {
            if (enabled) {
                busyRectangle.visible = root.busy
            }
        }

        Rectangle {
            id: busyRectangle

            color: Theme.rgba("black",  0.9)
            anchors.fill: parent

            TouchBlocker {
                anchors.fill: parent
            }
        }

        Column {
            anchors.centerIn: parent
            spacing: Theme.paddingLarge

            InfoLabel {
                text: root.text
                anchors.horizontalCenter: parent.horizontalCenter
            }

            BusyIndicator {
                anchors.horizontalCenter: parent.horizontalCenter
                size: BusyIndicatorSize.Large
                running: busyView.enabled
            }
        }
    }
}
