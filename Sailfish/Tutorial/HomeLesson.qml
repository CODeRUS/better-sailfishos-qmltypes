import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Tutorial 1.0
import "private"

Item {
    id: root

    anchors.fill: parent

    property int originalIndex
    property int targetIndex: -1
    property int timelineCounter: -1

    Component.onCompleted: {
        // Make sure the background is at correct position
        showApplicationOverlay = false
        showStatusBarClock = false
        background.currentIndex = 1
        lockHintTimeline.restart()
    }

    onTimelineCounterChanged: {
        if (timelineCounter === 3)
            lessonCompleted()
        else
            timeline.restart()
    }

    SequentialAnimation {
        id: lockHintTimeline

        alwaysRunToEnd: true
        PauseAnimation { duration: 1000 }
        ParallelAnimation {
            FadeAnimation {
                targets: [leftIndicator, rightIndicator]
                duration: 400
                from: 0.5
                to: 1.0
            }
            FadeAnimation {
                target: clock
                from: 0
                to: 1
            }
            SmoothedAnimation {
                target: leftIndicator
                property: "offset"
                duration: 700
                velocity: 1000 / duration
                from: 0
                to: leftSwipeArrow.width
            }
            SmoothedAnimation {
                target: rightIndicator
                property: "offset"
                duration: 700
                velocity: 1000 / duration
                from: 0
                to: rightSwipeArrow.width
            }
            SmoothedAnimation {
                target: clock
                property: "hintOffset"
                duration: 700
                velocity: 1000 / duration
                from: 0
                to: 2*Theme.paddingLarge
            }
        }
        PauseAnimation { duration: 1500 }
        ParallelAnimation {
            SmoothedAnimation {
                target: leftIndicator
                property: "offset"
                duration: 400
                velocity: 1000 / duration
                from: leftSwipeArrow.width
                to: 0
            }
            SmoothedAnimation {
                target: rightIndicator
                property: "offset"
                duration: 400
                velocity: 1000 / duration
                from: rightSwipeArrow.width
                to: 0
            }
        }
        ScriptAction {
            script: timelineCounter = 0
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
                          //% "This is Home, showing your minimized apps"
                          ? qsTrId("tutorial-la-home")
                          //% "Here are your notifications and social feeds"
                          : qsTrId("tutorial-la-events_view_description")
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
                        ? //% "Swipe from the left or right edge to unlock"
                          qsTrId("tutorial-la-unlock_to_home")
                        : timelineCounter === 1
                          //% "Swipe right to access Events"
                          ? qsTrId("tutorial-la-swipe_to_eventsview")
                          //% "Swipe left to go back Home"
                          : qsTrId("tutorial-la-swipe_left_to_home")
                hintLabel.opacity = 1.0
                hint.direction = timelineCounter === 2
                        ? TouchInteraction.Left
                        : TouchInteraction.Right
                hint.start()
                lock.interactive = timelineCounter === 0
                background.interactive = timelineCounter > 0
                originalIndex = background.currentIndex
                targetIndex = timelineCounter === 1 ? 0 : 1
            }
        }
    }

    SequentialAnimation {
        id: unlockAnimation

        ParallelAnimation {
            ScriptAction {
                script: showStatusBarClock = true
            }
            FadeAnimation {
                targets: [leftIndicator, rightIndicator, clock]
                to: 0
            }
            NumberAnimation {
                target: clock
                property: "hintOffset"
                to: -2*Theme.paddingLarge
            }
        }
        ScriptAction {
            script: {
                showApplicationOverlay = true
                timelineCounter++
            }
        }
    }

    Connections {
        target: background

        onMovingChanged: {
            if (targetIndex !== -1) {
                if (!background.moving && background.currentIndex === targetIndex) {
                    background.interactive = false
                    targetIndex = -1
                    timelineCounter++
                } else {
                    hintLabel.opacity = background.moving ? 0.0 : 1.0
                    if (background.moving)
                        hint.stop()
                    else
                        hint.start()
                    if (!background.moving) {
                        background.currentIndex = originalIndex
                    }
                }
            }
        }
    }

    SilicaListView {
        id: lock

        property real threshold: Theme.itemSizeLarge/2

        anchors.fill: parent

        boundsBehavior: Flickable.DragOverBounds
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        highlightRangeMode: ListView.StrictlyEnforceRange
        pressDelay: 0
        interactive: false

        model: 1

        delegate: Item {
            width: lock.width
            height: lock.height
        }

        onMovingChanged: {
            if (lock.interactive) {
                hintLabel.opacity = moving ? 0.0 : 1.0
                if (moving)
                    hint.stop()
                else
                    hint.start()
            }
        }

        onDraggingChanged: {
            if (!dragging && timelineCounter === 0) {
                if (contentX <= -threshold)
                    rightIndicator.opacity = 0
                else if (contentX >= threshold)
                    leftIndicator.opacity = 0
                else
                    return

                lock.interactive = false
                background.interactive = false
                targetIndex = -1
                clock.hintOffset = 0
                unlockAnimation.restart()
            }
        }
    }

    Item {
        id: clock

        property real hiddenOffset: 0
        property bool cannotCenter: isPortrait && Screen.sizeCategory <= Screen.Medium
        property real progress: lock.dragging ? Math.min(1, 0.5 * Math.abs(lock.contentX)/lock.threshold) : 0
        property real hintOffset: 0
        property real offset: progress * hiddenOffset * 0.5 - (cannotCenter ? Theme.paddingLarge : 0)

        anchors {
            top: cannotCenter ? parent.top : undefined
            horizontalCenter: parent.horizontalCenter
            centerIn: cannotCenter ? undefined : parent
            topMargin: Theme.paddingMedium + Theme.paddingLarge + hintOffset - (progress * 2 * Theme.paddingLarge)
            verticalCenterOffset: hintOffset - (progress * 2 * Theme.paddingLarge)
        }

        width: Math.max(timeText.width, weekday.width, month.width)
        height: timeText.primaryPixelSize + weekday.font.pixelSize + month.font.pixelSize + 2*Theme.paddingMedium
        baselineOffset: timeText.y + timeText.baselineOffset
        opacity: 0

        ClockItem {
            id: timeText

            anchors {
                bottom: parent.top
                bottomMargin: -timeText.primaryPixelSize
                horizontalCenter: parent.horizontalCenter
            }

            time: tutorialDate
            primaryPixelSize: Theme.fontSizeHuge * 2.0
            color: tutorialTheme.primaryColor
        }

        Text {
            id: weekday

            anchors {
                top: timeText.baseline
                topMargin: Theme.paddingMedium
                horizontalCenter:  parent.horizontalCenter
            }

            color: timeText.color
            font { pixelSize: Theme.fontSizeLarge; family: Theme.fontFamily }
            text: {
                var day = Format.formatDate(tutorialDate, Format.WeekdayNameStandalone)
                return day[0].toUpperCase() + day.substring(1)
            }
        }

        Text {
            id: month

            anchors {
                top: weekday.baseline
                topMargin: Theme.paddingMedium
                horizontalCenter: parent.horizontalCenter
            }

            color: timeText.color
            font { pixelSize: Theme.fontSizeExtraLarge * 1.1; family: Theme.fontFamily }
            text: Format.formatDate(tutorialDate, Format.DateMediumWithoutYear)
        }
    }

    Item {
        id: leftIndicator

        property real offset: 0

        anchors.verticalCenter: parent.verticalCenter
        x: unlockAnimation.running
           ? lock.threshold
           : Math.min(lock.threshold, -lock.contentX - width + offset)

        width: leftSwipeArrow.height
        height: leftSwipeArrow.width

        Image {
            id: leftSwipeArrow

            anchors.centerIn: parent
            source: "image://theme/graphics-edge-swipe-arrow"
            rotation: 90
        }
    }

    Item {
        id: rightIndicator

        property real offset: 0

        anchors.verticalCenter: parent.verticalCenter
        x: unlockAnimation.running
           ? parent.width - lock.threshold - width
           : Math.max(parent.width - lock.threshold - width, parent.width + lock.contentWidth - (lock.contentX + lock.width) - offset)

        width: rightSwipeArrow.height
        height: rightSwipeArrow.width

        Image {
            id: rightSwipeArrow

            anchors.centerIn: parent
            source: "image://theme/graphics-edge-swipe-arrow"
            rotation: -90
        }
    }

    HintLabel {
        id: hintLabel
        opacity: 0.0
    }

    TouchInteractionHint {
        id: hint
        loops: Animation.Infinite

        interactionMode: timelineCounter === 0 ? TouchInteraction.EdgeSwipe : TouchInteraction.Swipe

        on_LoopsRunChanged: {
            // alternate direction of hint every 2 times
            if (timelineCounter === 0 && _loopsRun % 2 === 0)
                direction = direction === TouchInteraction.Right ? TouchInteraction.Left : TouchInteraction.Right
        }
    }

    EdgeBlocker { edge: Qt.TopEdge }

    EdgeBlocker { edge: Qt.BottomEdge }
}
