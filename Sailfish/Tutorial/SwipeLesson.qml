import QtQuick 2.0
import Sailfish.Silica 1.0

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

    Image {
        id: appMainPage
        opacity: 0.0
        source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-people-index.png")
        sourceSize {
            width: 540 * xScale
            height: 960 * yScale
        }
        width: sourceSize.width
        height: sourceSize.height

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
                peekArea.peekEnabled = true
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
                lessonCompleted(200)
            }
        }
    }

    PeekArea {
        id: peekArea

        peekEnabled: false

        onOffsetChanged: {
            if (peekEnabled) {
                appMainPage.opacity = 1.0 - offset
            }
        }

        onPressedChanged: {
            if (peekEnabled) {
                hintLabel.opacity = pressed ? 0.0 : 1.0
                hint.running = pressed ? false : true
            }
        }

        onReleased: {
            if (offset === 1.0) {
                peekEnabled = false
                closeAppAnimation.restart()
            }
        }
    }
}
