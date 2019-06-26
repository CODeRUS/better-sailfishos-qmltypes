import QtQuick 2.0
import Sailfish.Silica 1.0

Loader {
    anchors.fill: parent
    active: counter.active
    sourceComponent: Component {
        Item {
            Connections {
                target: captureView
                onCaptured:  {
                    touchInteractionHint.restart()
                    counter.increase()
                }
            }

            anchors.fill: parent
            InteractionHintLabel {
                //: Swipe right to access the Camera Roll
                //% "Swipe right to access the Camera Roll"
                text: qsTrId("camera-la-camera_roll_hint")
                anchors.bottom: parent.bottom
                opacity: touchInteractionHint.running ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation { duration: 1000 } }
                textColor: Theme.highlightFromColor(Theme.highlightColor, Theme.LightOnDark)
                backgroundColor: Theme.rgba(Theme.highlightDimmerFromColor(Theme.highlightDimmerColor,  Theme.LightOnDark), 0.9)
            }
            TouchInteractionHint {
                id: touchInteractionHint

                color: Theme.lightPrimaryColor
                startX: parent.width/2 - width/2 + (page.isLandscape ? Screen.width/3 : 0)
                direction: TouchInteraction.Right
                anchors.verticalCenter: parent.verticalCenter
                anchors.verticalCenterOffset: page.isPortrait ? Screen.width/3 : 0
            }
        }
    }
    FirstTimeUseCounter {
        id: counter
        limit: 3
        defaultValue: 1 // display hint twice for existing users
        key: "/sailfish/camera/camera_roll_hint_count"
    }
}
