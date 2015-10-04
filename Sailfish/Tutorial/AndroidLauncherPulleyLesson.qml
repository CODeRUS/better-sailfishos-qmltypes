import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    property bool completed

    anchors.fill: parent

    Component.onCompleted: {
        // Make sure the background is at correct position
        background.currentIndex = 0
        timeline.restart()
    }

    SequentialAnimation {
        id: timeline
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Here is Lock screen"
                hintLabel.text = qsTrId("tutorial-la-lock_screen")
                hintLabel.opacity = 1.0
            }
        }
        PauseAnimation { duration: 3000 }
        ScriptAction  {
            script: {
                flickable.y = 0  // cut the binding to background.contentY
                hintLabel.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "The line at the top of the view indicates pulley menu which has additional options"
                hintLabel.text = qsTrId("tutorial-la-pulley_menu_description")
                hintLabel.opacity = 1.0
                hintLabel.showGradient = false
                pulleyMenu.busy = true
                continueButton.enabled = true
            }
        }
    }

    SequentialAnimation {
        id: timeline2
        ScriptAction  {
            script: {
                hintLabel.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //: 'About' must match with tutorial-me-about
                //% "Pull down slowly without lifting your finger and select<br>'About'"
                hintLabel.text = qsTrId("tutorial-la-pull_down_slowly_alternative")
                hintLabel.opacity = 1.0
                hintLabel.opacityFadeDuration = 500 // quicker fade for cross-fade with overlayLabel
                hintLabel.showGradient = true
                pulleyMenu.busy = false
                hint.start()
                touchBlocker.enabled = false
            }
        }
    }

    Binding {
        target: background
        when: !touchBlocker.enabled
        property: "contentY"
        value: flickable.contentY
    }

    SequentialAnimation {
        id: timeline3

        // Something to show here?

        ScriptAction  {
            script: {
                touchBlocker.enabled = true
                background.returnToBounds()
                closeAnimation.restart()
                lessonCompleted()
            }
        }
    }

    SequentialAnimation {
        id: closeAnimation
        PauseAnimation { duration: 500 }
        FadeAnimation {
            target: root
            to: 0.0
            duration: 2000
        }
    }

    SilicaFlickable {
        id: flickable

        width: parent.width
        height: parent.height
        // This binding will be cut after the initial scroll up animation
        y: -background.contentY
        contentHeight: height

        HintLabel {
            id: hintLabel
            opacity: 0.0
        }

        Rectangle {
            // Extra dimmer when overlay label is visible
            width: flickable.width
            height: flickable.height
            color: tutorialTheme.highlightDimmerColor
            opacity: 0.7 * overlayLabel.opacity
        }

        PullDownMenu {
            id: pulleyMenu

            property bool locked: pulleyMenu._atFinalPosition && !flickable.dragging
            property bool wasLocked

            highlightColor: tutorialTheme.highlightColor
            backgroundColor: tutorialTheme.highlightBackgroundColor

            onLockedChanged: {
                if (locked) {
                    // Remember the "locked" state until the menu is closed
                    wasLocked = true
                    pulleyHideTimer.restart()
                }
            }

            on_BounceBackRunningChanged: {
                if (_bounceBackRunning) {
                    if (!completed) {
                        hintLabel.opacity = 1.0
                        hint.start()
                    }
                    overlayLabel.opacity = 0.0
                }
            }

            onActiveChanged: {
                if (!completed) {
                    hintLabel.opacity = active ? 0.0 : 1.0
                    overlayLabel.opacity = active ? 1.0 : 0.0
                    if (active)
                        hint.stop()
                    else
                        hint.start()
                } else {
                    timeline3.restart()
                }

                if (!active) {
                    // Forget the "locked" state
                    wasLocked = false
                    pulleyHideTimer.stop()
                }
            }

            MenuItem {
                id: dialerOption
                //% "About"
                text: qsTrId("tutorial-me-about")
                color: (down || highlighted)
                       ? tutorialTheme.primaryColor
                       : tutorialTheme.highlightColor
                onClicked: {
                    if (!pulleyMenu.wasLocked) {
                        completed = true
                    }
                }
            }

            MenuItem {
                //% "Camera"
                text: qsTrId("tutorial-me-camera")
                color: (down || highlighted)
                       ? tutorialTheme.primaryColor
                       : tutorialTheme.highlightColor
            }

            MenuItem {
                //: Needs to match with lipstick-jolla-home-me-sounds_off
                //% "Silence sounds"
                text: qsTrId("tutorial-me-silence")
                color: (down || highlighted)
                       ? tutorialTheme.primaryColor
                       : tutorialTheme.highlightColor
            }
        }
    }

    TouchInteractionHint {
        id: hint
        direction: TouchInteraction.Down
        interactionMode: TouchInteraction.Pull
        loops: Animation.Infinite
    }

    MouseArea {
        id: touchBlocker
        anchors.fill: parent
        preventStealing: true
    }

    Button {
        id: continueButton
        anchors {
            bottom: parent.bottom
            bottomMargin: 4 * Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        color: tutorialTheme.primaryColor
        highlightColor: tutorialTheme.highlightColor
        highlightBackgroundColor: tutorialTheme.highlightBackgroundColor
        opacity: enabled ? hintLabel.opacity : 0
        enabled: false
        //% "Got it!"
        text: qsTrId("tutorial-bt-got_it")

        onClicked: {
            enabled = false
            timeline2.restart()
        }
    }

    InfoLabel {
        id: overlayLabel
        parent: __silica_applicationwindow_instance
        y: 4 * Theme.paddingLarge - flickable.contentY
        color: tutorialTheme.highlightColor
        opacity: 0.0

        text: pulleyMenu.locked
              //% "Pull down slower"
              ? qsTrId("tutorial-la-pull_slower")
              : pulleyMenu.active && !pulleyMenu.wasLocked
                //% "Select by releasing your finger when the option is highlighted"
                ? qsTrId("tutorial-la-select_enter_phone_number")
                : ""

        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    Timer {
        id: pulleyHideTimer
        interval: 2000
        onTriggered: {
            pulleyMenu.hide()
        }
    }
}
