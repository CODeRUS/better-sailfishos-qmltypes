import QtQuick 2.0
import Sailfish.Silica 1.0

Lesson {
    id: root

    //: This text has a full stop at the end unlike the other "recap labels" because
    //: it's shown together with tutorial-la-recap_tutorial_completed
    //% "Now you know what to do when an alarm rings."
    recapText: qsTrId("tutorial-la-recap_alarm")

    opacity: 0.0

    Component.onCompleted: {
        timeline.restart()
    }

    SequentialAnimation {
        id: timeline
        PauseAnimation { duration: 1000 }
        FadeAnimation {
            target: root
            to: 1.0
            duration: 500
        }
        PauseAnimation { duration: 1500 }
        ScriptAction  {
            script: {
                //% "This is an alarm"
                hintLabel.text = qsTrId("tutorial-la-alarm")
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
                //% "The lines at the top and bottom indicate the pulley menus"
                hintLabel.text = qsTrId("tutorial-la-pulley_explanation")
                hintLabel.opacity = 1.0
                snoozeMenu.busy = true
                dismissMenu.busy = true
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
                //% "Pull down to snooze the alarm"
                hintLabel.text = qsTrId("tutorial-la-pull_down_to_snooze")
                hintLabel.opacity = 1.0
                hintLabel.atBottom = false
                hint.start()
                snoozeMenu.busy = false
                snoozeMenu.acceptAction = true
                dismissMenu.busy = false
                touchBlocker.enabled = false
            }
        }
    }

    SequentialAnimation {
        id: timeline2
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Pull up to dismiss the alarm"
                hintLabel.text = qsTrId("tutorial-la-pull_down_to_dismiss")
                hintLabel.opacity = 1.0
                hintLabel.atBottom = false
                hint.direction = TouchInteraction.Up
                hint.start()
                dismissMenu.acceptAction = true
                touchBlocker.enabled = false
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

    Image {
        parent: applicationBackground
        anchors.fill: parent
        opacity: root.opacity
        source: Screen.sizeCategory >= Screen.Large
                ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-app-background.png")
                : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-app-background.png")
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: height

        property bool menuActive: snoozeMenu.active || dismissMenu.active

        onMenuActiveChanged: {
            if (snoozeMenu.acceptAction || dismissMenu.acceptAction) {
                hintLabel.opacity = menuActive ? 0.0 : 1.0
                if (menuActive)
                    hint.stop()
                else
                    hint.start()
            }
        }

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            y: Theme.paddingLarge
            source: "image://theme/icon-l-snooze?" + tutorialTheme.highlightColor
        }

        Column {
            anchors {
                bottom: dismissIcon.top
                bottomMargin: Theme.itemSizeExtraSmall
                left: parent.left
                right: parent.right
                margins: Theme.horizontalPageMargin
            }

            Label {
                anchors { left: parent.left; right: parent.right }
                color: tutorialTheme.primaryColor
                font {
                    pixelSize: Theme.fontSizeHuge
                    family: Theme.fontFamilyHeading
                }

                horizontalAlignment: Text.AlignHCenter
                text: {
                    var date = new Date()
                    Format.formatDate(date, Formatter.TimeValue)
                }
            }

            Label {
                anchors { left: parent.left; right: parent.right }
                color: tutorialTheme.primaryColor
                font {
                    pixelSize: Theme.fontSizeHuge
                    family: Theme.fontFamilyHeading
                }
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 4
                wrapMode: Text.Wrap
                //: The title of the alarm
                //% "Alarm"
                text: qsTrId("tutorial-la-alarm_title")
            }
        }

        Image {
            id: dismissIcon

            anchors {
                bottom: parent.bottom
                bottomMargin: Theme.paddingLarge
                horizontalCenter: parent.horizontalCenter
            }
            source: "image://theme/icon-l-dismiss?" + tutorialTheme.highlightColor
        }

        HintLabel {
            id: hintLabel
            opacity: 0.0
        }

        PullDownMenu {
            id: snoozeMenu

            property bool acceptAction

            quickSelect: true

            colorScheme: Theme.LightOnDark
            highlightColor: tutorialTheme.highlightColor
            backgroundColor: tutorialTheme.highlightBackgroundColor

            MenuItem {
                //: Needs to match with alarm-ui-me-alarm_dialog_snooze
                //% "Snooze"
                text: qsTrId("tutorial-me-alarm_snooze")
                color: (down || highlighted)
                       ? tutorialTheme.primaryColor
                       : tutorialTheme.highlightColor
                onClicked: {
                    if (snoozeMenu.acceptAction) {
                        snoozeMenu.acceptAction = false
                        touchBlocker.enabled = true
                        timeline2.restart()
                    }
                }
            }

            Item {
                height: Theme.itemSizeExtraSmall
                width: parent.width
            }
        }

        PushUpMenu {
            id: dismissMenu

            property bool acceptAction

            quickSelect: true

            colorScheme: Theme.LightOnDark
            highlightColor: tutorialTheme.highlightColor
            backgroundColor: tutorialTheme.highlightBackgroundColor

            Item {
                height: Theme.itemSizeExtraSmall
                width: parent.width
            }
            MenuItem {
                //: Needs to match with alarm-ui-me-alarm_dialog_dismiss
                //% "Dismiss"
                text: qsTrId("tutorial-me-alarm_dismiss")
                color: (down || highlighted)
                       ? tutorialTheme.primaryColor
                       : tutorialTheme.highlightColor
                onClicked: {
                    if (dismissMenu.acceptAction) {
                        dismissMenu.acceptAction = false
                        touchBlocker.enabled = true
                        closeAnimation.restart()
                        lessonCompleted()
                    }
                }
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
}
