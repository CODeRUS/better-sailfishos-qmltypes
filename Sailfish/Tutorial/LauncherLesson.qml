import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    anchors.fill: parent

    property int originalIndex
    property int targetIndex: -1
    property int timelineCounter

    Component.onCompleted: {
        // Make sure the background is at correct position
        background.currentIndex = 0
        timeline.restart()
    }

    onTimelineCounterChanged: {
        if (timelineCounter === 3) {
            lessonCompleted()
        } else {
            timeline.restart()
        }
    }

    SequentialAnimation {
        id: timeline
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                hintLabel.atBottom = false
                hintLabel.text = timelineCounter === 0
                        //% "Here is Lock screen"
                        ? qsTrId("tutorial-la-lock_screen")
                        : timelineCounter === 1
                          //% "Here is Home, showing all running apps"
                          ? qsTrId("tutorial-la-home")
                          //% "Here is Launcher, showing all installed apps"
                          : qsTrId("tutorial-la-launcher")
                hintLabel.opacity = 1.0
            }
        }
        PauseAnimation { duration: 3000 }
        ScriptAction  {
            script: {
                hintLabel.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                hintLabel.atBottom = true
                hintLabel.text = timelineCounter === 0
                        ? androidLauncher
                          //% "Flick up to unlock your phone"
                          ? qsTrId("tutorial-la-unlock_phone_alternative")
                          //% "Flick up to unlock your Jolla"
                          : qsTrId("tutorial-la-unlock_phone")
                        : timelineCounter === 1
                          //% "Flick up to access all installed apps"
                          ? qsTrId("tutorial-la-flick_to_launcher")
                          //% "Flick down to go back Home"
                          : qsTrId("tutorial-la-flick_to_home")
                hintLabel.opacity = 1.0
                hint.direction = timelineCounter === 2
                        ? TouchInteraction.Down
                        : TouchInteraction.Up
                hint.running = true
                background.interactive = true
                originalIndex = background.currentIndex
                targetIndex = timelineCounter === 0
                        ? 1
                        : timelineCounter === 1
                          ? 2
                          : 1
            }
        }
    }

    Connections {
        target: background

        onMovingChanged: {
            if (targetIndex !== -1) {
                if (background.currentIndex === targetIndex) {
                    background.interactive = false
                    targetIndex = -1
                    timelineCounter++
                } else {
                    hintLabel.opacity = background.moving ? 0.0 : 1.0
                    hint.running = background.moving ? false : true
                    if (!background.moving) {
                        background.currentIndex = originalIndex
                    }
                }
            }
        }
    }

    HintLabel {
        id: hintLabel
        opacity: 0.0
    }

    TouchInteractionHint {
        id: hint
        direction: timelineCounter === 2
                   ? TouchInteraction.Down
                   : TouchInteraction.Up
        loops: Animation.Infinite
        anchors.horizontalCenter: parent.horizontalCenter
    }

    EdgeBlocker { edge: Qt.TopEdge }

    EdgeBlocker { edge: Qt.BottomEdge }

    EdgeBlocker { edge: Qt.LeftEdge }

    EdgeBlocker { edge: Qt.RightEdge }
}
