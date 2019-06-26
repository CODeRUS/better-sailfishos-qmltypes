import QtQuick 2.0
import Sailfish.Silica 1.0
import com.jolla.camera 1.0

Loader {
    anchors.fill: parent
    active: counter.active
    asynchronous: true
    sourceComponent: Component {
        Item {
            property string mode: Settings.global.captureMode
            onModeChanged: {
                touchInteractionHint.direction = mode == "image"
                                                    ? TouchInteraction.Up
                                                    : TouchInteraction.Down
                touchInteractionHint.restart()
                counter.increase()
            }

            anchors.fill: parent
            InteractionHintLabel {
                //: Push up or down to change between photo and video mode
                //% "Push up or down to change between photo and video mode"
                text: qsTrId("camera-la-camera_mode_hint")
                anchors.bottom: parent.bottom
                opacity: touchInteractionHint.running ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation { duration: 800 } }
                textColor: Theme.highlightFromColor(Theme.highlightColor, Theme.LightOnDark)
                backgroundColor: Theme.rgba(Theme.highlightDimmerFromColor(Theme.highlightDimmerColor,  Theme.LightOnDark), 0.9)
            }
            TouchInteractionHint {
                id: touchInteractionHint
                loops: 1
                alwaysRunToEnd: true
                distance: Theme.itemSizeMedium
                color: Theme.lightPrimaryColor
            }
        }
    }
    FirstTimeUseCounter {
        id: counter
        limit: 3
        defaultValue: 1 // display hint twice for existing users
        key: "/sailfish/camera/camera_mode_hint_count"
    }
}
