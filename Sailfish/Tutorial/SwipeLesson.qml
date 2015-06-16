import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

Item {
    anchors.fill: parent

    Component.onCompleted: {
        // Make sure the background is at correct position
        background.currentIndex = 1
        timeline.restart()
    }

    SequentialAnimation {
        id: timeline
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                fader.opacity = 0.8

                appInfo.text = androidLauncher
                        //% "Here is a running app"
                        ? qsTrId("tutorial-la-running_app")
                        //% "Here is running People app"
                        : qsTrId("tutorial-la-people_app")
                appInfo.opacity = 1.0
            }
        }
        PauseAnimation { duration: 3000 }
        ScriptAction  {
            script: {
                appInfo.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Tap to open"
                appInfo.text = qsTrId("tutorial-la-tap_to_open")
                appInfo.opacity = 1.0
                peopleApp.enabled = true
            }
        }
    }

    DimmedRegion {
        id: fader
        anchors.fill: parent
        color: tutorialTheme.highlightDimmerColor
        opacity: 0.0
        target: mainPage
        area: Qt.rect(0, 0, parent.width, parent.height)
        exclude: [ peopleApp ]

        Behavior on opacity { FadeAnimation { duration: 500 } }
    }


    BackgroundItem {
        id: peopleApp
        x: 24 * xScale
        y: 24 * yScale
        width: 148 * xScale
        height: 235 * yScale
        highlightedColor: Theme.rgba(tutorialTheme.highlightColor, 0.3)
        enabled: false

        onClicked: {
            enabled = false
            appInfo.opacity = 0.0
            openAppAnimation.start()
        }
    }

    TapInteractionHint {
        running: peopleApp.enabled
        anchors.centerIn: peopleApp
    }

    InfoLabel {
        id: appInfo
        anchors {
            centerIn: parent
            verticalCenterOffset: -3 * Theme.paddingLarge
        }
        opacity: 0.0
        color: tutorialTheme.highlightColor
        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    Item {
        id: clipItem
        anchors.fill: parent
        clip: x > 0 || width < parent.width
        Image {
            id: appMainPage
            opacity: 0.0

            Behavior on opacity { SmoothedAnimation { duration: 400; velocity: 1000 / duration } }
            source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-people-index.png")
            sourceSize {
                width: 540 * xScale
                height: 960 * yScale
            }
            width: sourceSize.width
            height: sourceSize.height
            x: -parent.x

        }
    }
    HintLabel {
        id: hintLabel
        atBottom: true
        opacity: 0.0
    }

    TouchInteractionHint {
        id: hint
        direction: TouchInteraction.Left
        loops: Animation.Infinite
        anchors.verticalCenter: parent.verticalCenter
        startX: hint.direction === TouchInteraction.Left
                ? parent.width
                : -width
    }

    SequentialAnimation {
        id: openAppAnimation
        NumberAnimation {
            target: fader
            property: "opacity"
            to: 0.0
            duration: 100
        }
        NumberAnimation {
            target: background
            property: "contentY"
            to: 780 * yScale
            duration: 200
        }
        NumberAnimation {
            target: appMainPage
            property: "opacity"
            to: 1.0
            duration: 500
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Swipe from the outside of the screen to go back to Home"
                hintLabel.text = qsTrId("tutorial-la-swipe_to_home")
                hintLabel.opacity = 1.0

                hint.running = true
                peekFilter.enabled = true
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
                directionSwitcher.start()
                //% "You can swipe either from left or right side"
                hintLabel.text = qsTrId("tutorial-la-swipe_from_left_or_right")
                hintLabel.opacity = 1.0
            }
        }
    }

    Timer {
        id: directionSwitcher
        repeat: true
        interval: 4800
        triggeredOnStart: true
        onTriggered: {
            hint.direction = hint.direction === TouchInteraction.Left
                ? TouchInteraction.Right
                : TouchInteraction.Left
        }

    }

    SequentialAnimation {
        id: closeAppAnimation
        NumberAnimation {
            target: background
            property: "contentY"
            to: 1020 * yScale
            duration: 200
        }
        ScriptAction  {
            script: {
                hint.running = false
                hintLabel.opacity = 0.0
                lessonCompleted(200)
            }
        }
    }

    PeekFilter {
        id: peekFilter

        property bool pressed: leftActive || rightActive

        enabled: false
        onProgressChanged: if (enabled) appMainPage.opacity = 1.0 - Math.max(0.0, progress-0.3)/0.7
        onPressedChanged: {
            hintLabel.opacity = pressed ? 0.0 : 1.0
            hint.running = pressed ? false : true
        }
        leftEnabled: true
        rightEnabled: true
        onGestureStarted: {
            clipEndAnimation.complete()
            var margin = leftActive ? "leftMargin" : "rightMargin"
            dragEdgeBinding.property = margin
            clipEndAnimation.property = margin
            dragEdgeBinding.when = true
        }
        onGestureCanceled: {
            dragEdgeBinding.when = false
            clipEndAnimation.to = 0
            clipEndAnimation.duration = 200
            clipEndAnimation.start()
        }
        onGestureTriggered: {
            enabled = false
            // make sure open animation has already finished
            openAppAnimation.stop()
            closeAppAnimation.restart()
            dragEdgeBinding.when = false
            clipEndAnimation.to = parent.width
            clipEndAnimation.duration = 400*(clipEndAnimation.to - peekFilter.absoluteProgress)/Screen.width
            clipEndAnimation.start()
        }
    }
    Binding {
        id: dragEdgeBinding
        when: false
        target: clipItem.anchors
        value: peekFilter.absoluteProgress
    }
    NumberAnimation {
        id: clipEndAnimation
        easing.type: Easing.InOutQuad
        target: clipItem.anchors
    }
}
