import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import Sailfish.Tutorial 1.0
import org.nemomobile.configuration 1.0
import "private"

Lesson {
    id: root

    property Item targetItem
    property int timelineCounter: -1

    property int _maximumTimelineCounter: 3 + partnerSpaceItems.count

    recapText: partnerSpaceItems.count === 0
                 //% "Now you know how to navigate between Lock screen, Home and Events"
               ? qsTrId("tutorial-la-recap_home")
               : partnerSpaceItems.item ? partnerSpaceItems.item.recapText : ""

    Item {
        visible: false

        PannableItem {
            id: eventsViewItem

            property bool dimBackground: true

            width: background.width
            height: background.height

            visible: false

            Image {
                anchors.fill: parent
                source: Screen.sizeCategory >= Screen.Large
                        ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-events.png")
                        : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-events.png")
            }
        }

        Loader {
            id: partnerSpaceItems

            property int count: item ? item.count : 0

            function itemAt(index) {
                return item ? item.itemAt(index) : null
            }

            source: Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/PartnerSpaceItems.qml")
        }
    }

    Component.onCompleted: {
        // Make sure the background is at correct position
        showApplicationOverlay = false
        showStatusBarClock = false

        // Add Partner Spaces to homescreen courasel
        var pannableItems = [ eventsViewItem, background.switcherItem ]
        for (var i = 0; i < partnerSpaceItems.count; ++i)
            pannableItems.push(partnerSpaceItems.itemAt(i))
        background.pannableItems = pannableItems
        background.currentItem = background.switcherItem

        lockHintTimeline.restart()
    }

    onTimelineCounterChanged: {
        if (timelineCounter === _maximumTimelineCounter)
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
                switch (timelineCounter) {
                case 0:
                    //% "Here is Lock screen"
                    hintLabel.text = qsTrId("tutorial-la-lock_screen")
                    break
                case 1:
                    //% "This is Home, showing your minimized apps"
                    hintLabel.text = qsTrId("tutorial-la-home")
                    break
                case 2:
                    //% "Here are your notifications and social feeds"
                    hintLabel.text = qsTrId("tutorial-la-events_view_description")
                    break
                default:
                    if (timelineCounter === _maximumTimelineCounter) {
                        hintLabel.text = ""
                    } else {
                        var index = _maximumTimelineCounter - timelineCounter - 1

                        //: %1 is partner space name
                        //% "Here is %1"
                        hintLabel.text = qsTrId("tutorial-la-partner_space_description").arg(partnerSpaceItems.itemAt(index).name)
                    }
                }

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

                switch (timelineCounter) {
                case 0:
                    //% "Swipe from the left or right edge to unlock"
                    hintLabel.text = qsTrId("tutorial-la-unlock_to_home")
                    hint.direction = TouchInteraction.Right
                    break
                case 1:
                    //% "Swipe right to access Events"
                    hintLabel.text = qsTrId("tutorial-la-swipe_to_eventsview")
                    hint.direction = TouchInteraction.Right
                    targetItem = eventsViewItem
                    background.allowPanLeft = true
                    break
                default:
                    if (partnerSpaceItems.count === 0) {
                        //% "Swipe left to go back Home"
                        hintLabel.text = qsTrId("tutorial-la-swipe_left_to_home")
                        hint.direction = TouchInteraction.Left
                        targetItem = background.switcherItem
                        background.allowPanRight = true
                    } else if (timelineCounter === _maximumTimelineCounter - 1) {
                        //% "Swipe right to go back Home"
                        hintLabel.text = qsTrId("tutorial-la-swipe_right_to_home")
                        hint.direction = TouchInteraction.Right
                        targetItem = background.switcherItem
                        background.allowPanLeft = true
                    } else {
                        var index = _maximumTimelineCounter - timelineCounter - 2

                        //: %1 is partner space name
                        //% "Swipe right to access %1"
                        hintLabel.text = qsTrId("tutorial-la-swipe_to_partner_space").arg(partnerSpaceItems.itemAt(index).name)
                        hint.direction = TouchInteraction.Right
                        targetItem = partnerSpaceItems.itemAt(index)
                        background.allowPanLeft = true
                    }
                }

                hintLabel.opacity = 1.0
                hint.start()
                lock.interactive = timelineCounter === 0
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
            if (targetItem) {
                if (!background.moving && background.currentItem === targetItem) {
                    background.allowPanLeft = false
                    background.allowPanRight = false
                    targetItem = null
                    timelineCounter++
                } else {
                    hintLabel.opacity = background.moving ? 0.0 : 1.0

                    if (background.moving)
                        hint.stop()
                    else
                        hint.start()
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
                background.allowPanLeft = false
                background.allowPanRight = false
                targetItem = null
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
