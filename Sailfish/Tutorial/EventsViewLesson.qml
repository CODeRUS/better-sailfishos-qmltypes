import QtQuick 2.0
import Sailfish.Silica 1.0

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


    MouseArea {
        id: bottomPeek

        property real offset: pressed
                              ? Math.min(1.0, Math.max(0.0, (height - mouseY) / (parent.height / 6)))
                              : 0.0

        enabled: false
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        height: 24 * yScale

        onPressedChanged: {
            if (enabled) {
                hintLabel.opacity = pressed ? 0.0 : 1.0
                hint.running = pressed ? false : true
            }
        }

        onReleased: {
            if (offset === 1.0) {
                enabled = false
                timelineCounter++
            }
        }
    }

    Image {
        source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-eventsview.png")
        opacity: timelineCounter === 1
            ? 1 - bottomPeek.offset
            : bottomPeek.offset
        sourceSize {
            width: 540 * xScale
            height: 960 * yScale
        }
        width: sourceSize.width
        height: sourceSize.height
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
}
