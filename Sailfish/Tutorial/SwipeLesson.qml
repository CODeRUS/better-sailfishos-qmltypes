import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0
import Sailfish.Tutorial 1.0
import "private"

Lesson {
    id: lesson

    //% "Now you know that swiping from the left or right edge brings you back to Home"
    recapText: qsTrId("tutorial-la-recap_swipe_to_close")

    Component.onCompleted: {
        // Make sure the background is at correct position
        background.currentItem = background.switcherItem
        timeline.restart()
    }

    SequentialAnimation {
        id: timeline
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                fader.opacity = 0.8

                //% "Here is the minimized People app"
                appInfo.text = qsTrId("tutorial-la-people_app")
                appInfo.opacity = 1.0
                peopleApp.enabled = true
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

    CoverItem {
        id: peopleApp

        row: 0
        column: 0

        onClicked: {
            timeline.complete()
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
            source: Screen.sizeCategory >= Screen.Large
                    ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-app-background.png")
                    : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-app-background.png")
            width: lesson.width
            height: lesson.height
            x: -parent.x

            Image {
                anchors.fill: parent
                source: Screen.sizeCategory >= Screen.Large
                        ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-people-app.png")
                        : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-people-app.png")
            }

            SilicaFlickable {
                anchors.fill: parent

                interactive: false

                PullDownMenu {
                    colorScheme: Theme.LightOnDark
                    highlightColor: tutorialTheme.highlightColor
                    backgroundColor: tutorialTheme.highlightBackgroundColor
                }
            }

            PageHeader {
                //: Title of people application, should match contacts-ap-name
                //% "People"
                title: qsTrId("tutorial-la-people")
                _titleItem.color: tutorialTheme.highlightColor
            }
        }
    }
    HintLabel {
        id: hintLabel
        atBottom: true
        opacity: 0.0
    }

    TouchInteractionHint {
        id: hint

        interactionMode: TouchInteraction.EdgeSwipe
        direction: TouchInteraction.Right
        loops: Animation.Infinite

        on_LoopsRunChanged: {
            // alternate direction of hint every 2 times
            if (_loopsRun % 2 === 0)
                direction = direction === TouchInteraction.Right ? TouchInteraction.Left : TouchInteraction.Right
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
            target: appMainPage
            property: "opacity"
            to: 1.0
            duration: 500
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Swipe from the left or right edge to go Home"
                hintLabel.text = qsTrId("tutorial-la-swipe_left_right_to_home")
                hintLabel.opacity = 1.0

                hint.start()
                peekFilter.enabled = true
            }
        }
    }

    SequentialAnimation {
        id: closeAppAnimation
        PauseAnimation {
            duration: 200
        }
        ScriptAction  {
            script: {
                hint.stop()
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
            if (pressed)
                hint.stop()
            else
                hint.start()
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
