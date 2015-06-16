import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

Item {
    anchors.fill: parent

    property int timelineCounter

    Component.onCompleted: {
        // Make sure the background is at correct position
        background.currentIndex = 1
        timeline.restart()
    }

    onTimelineCounterChanged: {
        if (timelineCounter === 1) {
            timeline2.restart()
        } else {
            lessonCompleted(200)
        }
    }

    SequentialAnimation {
        id: timeline
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Swipe up from the outside of the screen to access Events view"
                hintLabel.text = qsTrId("tutorial-la-access_events_view")
                hintLabel.opacity = 1.0
                hint.running = true
                bottomPeek.enabled = true
            }
        }
    }

    SequentialAnimation {
        id: timeline2
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Here is Events view which shows missed notifications and social feeds"
                hintLabel.text = qsTrId("tutorial-la-events_view_description")
                hintLabel.opacity = 1.0
            }
        }
        PauseAnimation { duration: 4000 }
        ScriptAction  {
            script: {
                hintLabel.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Swipe up again to return to previous view"
                hintLabel.text = qsTrId("tutorial-la-close_events_view")
                hintLabel.opacity = 1.0
                hint.running = true
                bottomPeek.enabled = true
            }
        }
    }


    PeekFilter {
        id: bottomPeek

        enabled: false
        bottomEnabled: true

        onBottomActiveChanged: {
            if (enabled) {
                hintLabel.opacity = bottomActive ? 0.0 : 1.0
                hint.running = bottomActive ? false : true
            }
        }
        onGestureStarted: {
            if (timelineCounter === 1) {
                clipEndAnimation.complete()
                dragEdgeBinding.when = true
            }
        }
        onGestureTriggered: {
            enabled = false
            if (timelineCounter === 1) {
                dragEdgeBinding.when = false
                clipEndAnimation.to = parent.height
                clipEndAnimation.duration = 400*(clipEndAnimation.to - bottomPeek.absoluteProgress)/Screen.height
                clipEndAnimation.start()
            }
            timelineCounter++
        }
        onGestureCanceled: {
            if (timelineCounter === 1) {
                dragEdgeBinding.when = false
                clipEndAnimation.to = 0
                clipEndAnimation.duration = 200
                clipEndAnimation.start()
            }
        }
    }

    Item {
        id: clipItem
        anchors.fill: parent
        clip: height < parent.height
        Image {
            id: eventsView
            source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-eventsview.png")
            opacity: timelineCounter === 1
                     ? 1 - Math.max(0.0, bottomPeek.progress-0.3)/0.7
                     : bottomPeek.progress

            Behavior on opacity { SmoothedAnimation { duration: 400; velocity: 1000 / duration } }
            sourceSize {
                width: 540 * xScale
                height: 960 * yScale
            }
            width: sourceSize.width
            height: sourceSize.height
        }
    }

    HintLabel {
        id: hintLabel
        atBottom: true
        opacity: 0.0
    }
    TouchInteractionHint {
        id: hint
        direction: TouchInteraction.Up
        loops: Animation.Infinite
        anchors.horizontalCenter: parent.horizontalCenter
        startY: parent.height
    }
    Binding {
        id: dragEdgeBinding
        when: false
        target: clipItem.anchors
        property: "bottomMargin"
        value: bottomPeek.absoluteProgress
    }
    NumberAnimation {
        id: clipEndAnimation
        easing.type: Easing.InOutQuad
        target: clipItem.anchors
        property: "bottomMargin"
    }
}
