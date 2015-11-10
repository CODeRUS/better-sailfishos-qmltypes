import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import Sailfish.Tutorial 1.0

Item {
    id: lesson

    anchors.fill: parent

    property int timelineCounter

    Component.onCompleted: {
        // Make sure the background is at correct position
        background.currentIndex = 1
        applicationGridIndicator.visible = false
        timeline2.restart()
    }

    onTimelineCounterChanged: {
        if (timelineCounter === 2) {
            if (!applicationGridEndAnimation.running)
                jumpToLesson("SwipeLesson.qml")
        } else {
            timeline1.restart()
        }
    }

    SequentialAnimation {
        id: timeline1
        PauseAnimation { duration: 1000 }
        ScriptAction {
            script: {
                hintLabel.atBottom = false
                //% "These are your installed apps"
                hintLabel.text = qsTrId("tutorial-la-installed_apps")
                hintLabel.opacity = 1.0
            }
        }
        PauseAnimation { duration: 3000 }
        ScriptAction {
            script: {
                hintLabel.opacity = 0.0
                timeline2.restart()
            }
        }
    }

    SequentialAnimation {
        id: timeline2
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                hintLabel.atBottom = true
                hintLabel.text = timelineCounter === 0
                        //% "Swipe from the bottom edge to open the app grid"
                        ? qsTrId("tutorial-la-swipe_to_launcher")
                        //% "Swipe from the top edge to close it"
                        : qsTrId("tutorial-la-swipe_to_close_grid")
                hintLabel.opacity = 1.0
                hint.direction = timelineCounter === 0
                        ? TouchInteraction.Up
                        : TouchInteraction.Down
                hint.start()
                appGridPeek.bottomEnabled = timelineCounter === 0
                appGridPeek.topEnabled = timelineCounter === 1
                appGridPeek.enabled = appGridPeek.bottomEnabled || appGridPeek.topEnabled
            }
        }
    }

    PeekFilter {
        id: appGridPeek

        enabled: false
        boundaryHeight: parent.height

        onBottomActiveChanged: {
            if (enabled) {
                hintLabel.opacity = active ? 0.0 : 1.0
                if (active)
                    hint.stop()
                else
                    hint.start()
            }
        }

        onTopActiveChanged: {
            if (enabled) {
                hintLabel.opacity = active ? 0.0 : 1.0
                if (active)
                    hint.stop()
                else
                    hint.start()
            }
        }

        onGestureStarted: {
            if (timelineCounter === 0 || timelineCounter === 1) {
                applicationGridEndAnimation.complete()
                dragEdgeBinding.when = true
            }
        }
        onGestureTriggered: {
            enabled = false
            if (timelineCounter === 0 || timelineCounter === 1) {
                applicationGridEndAnimation.from = applicationGrid.y
                applicationGridEndAnimation.to = timelineCounter === 0 ? 0 : parent.height
                applicationGridEndAnimation.duration = 400*(parent.height - absoluteProgress)/Screen.height
                dragEdgeBinding.when = false
                applicationGridEndAnimation.start()
            }
            timelineCounter++
        }
        onGestureCanceled: {
            if (timelineCounter === 0 || timelineCounter === 1) {
                applicationGridEndAnimation.from = applicationGrid.y
                applicationGridEndAnimation.to = timelineCounter === 0 ? parent.height : 0
                applicationGridEndAnimation.duration = 200
                dragEdgeBinding.when = false
                applicationGridEndAnimation.start()
            }
        }
    }

    Image {
        source: "image://theme/graphic-edge-swipe-handle-top"

        anchors {
            bottom: applicationGrid.top
            horizontalCenter: applicationGrid.horizontalCenter
        }
    }

    Image {
        id: applicationGrid

        width: parent.width
        height: parent.height
        y: parent.height

        source: Screen.sizeCategory >= Screen.Large
                ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-launcher.png")
                : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-launcher.png")
    }

    Image {
        source: "image://theme/graphic-edge-swipe-handle-bottom"

        anchors {
            top: applicationGrid.top
            horizontalCenter: applicationGrid.horizontalCenter
        }
    }

    HintLabel {
        id: hintLabel
        opacity: 0.0
    }

    TouchInteractionHint {
        id: hint
        loops: Animation.Infinite
        interactionMode: TouchInteraction.EdgeSwipe
    }

    EdgeBlocker { edge: Qt.TopEdge }

    EdgeBlocker { edge: Qt.BottomEdge }

    EdgeBlocker { edge: Qt.LeftEdge }

    EdgeBlocker { edge: Qt.RightEdge }

    Binding {
        id: dragEdgeBinding
        when: false
        target: applicationGrid
        property: "y"
        value: appGridPeek.topActive ? appGridPeek.absoluteProgress : lesson.height - appGridPeek.absoluteProgress
    }

    NumberAnimation {
        id: applicationGridEndAnimation
        target: applicationGrid
        property: "y"
        easing.type: Easing.OutQuad

        onRunningChanged: {
            if (timelineCounter === 2 && !running)
                timer.start()
        }
    }

    Timer {
        id: timer

        interval: 800
        onTriggered: jumpToLesson("SwipeLesson.qml")
    }
}
