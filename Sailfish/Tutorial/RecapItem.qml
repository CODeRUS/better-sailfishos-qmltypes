import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Tutorial 1.0

Item {
    id: root
    anchors.fill: parent
    opacity: 0.0

    property int completedLessons
    property bool buttonsEnabled: showAnimation.running || root.opacity === 1.0
    property bool upgradeMode

    function show(pauseDuration) {
        showPause.duration = pauseDuration !== undefined ? pauseDuration : 500
        if (lessonCounter === 0) {
            if (androidLauncher) {
                //: The primary label shown when the tutorial is started on Android
                //% "Learn basics of Jolla Launcher"
                label.text = qsTrId("tutorial-la-learn_basics_alternative")
            } else {
                if (upgradeMode) {
                    //: The primary label shown when the tutorial is show after an upgrade
                    //% "Congratulations on upgrading to Sailfish OS 2.0!"
                    label.text = qsTrId("tutorial-la-thanks_for_updating")
                } else {
                    //: The primary label shown when the tutorial is started
                    //% "Learn basics of your Jolla"
                    label.text = qsTrId("tutorial-la-learn_basics")
                }
            }
            againButton.visible = false
            //% "Start"
            continueButton.text = qsTrId("tutorial-bt-start")
        } else {
            //% "Well done!"
            label.text = qsTrId("tutorial-la-well_done")
            againButton.visible = true
            continueButton.text = lessonCounter === maxLessons
                    //: The button text shown at the end of the tutorial. Pressing this quits the tutorial.
                    //% "Close tutorial"
                    ? qsTrId("tutorial-bt-close_tutorial")
                    //% "Continue"
                    : qsTrId("tutorial-bt-continue")
            completedLessons = lessonCounter
        }

        switch (lessonCounter) {
        case 0:
            if (androidLauncher) {
                //: The secondary label shown when the tutorial is started on Android
                //% "Simply hold the device in one hand and follow the instructions on screen to learn how to navigate in Jolla Launcher"
                description.text = qsTrId("tutorial-la-follow_the_instructions_alternative")
            } else {
                if (upgradeMode) {
                    //: The secondary label shown when the tutorial is started after an upgrade
                    //% "We've made some exciting changes. Start the Tutorial to learn about them!"
                    description.text = qsTrId("tutorial-la-exciting_changes")
                } else {
                    if (Screen.sizeCategory >= Screen.Large) {
                        //: The secondary label shown when the tutorial is started (for large screen devices)
                        //% "Simply hold the device comfortably and follow the instructions on screen to learn how to navigate in Sailfish OS"
                        description.text = qsTrId("tutorial-la-follow_the_instructions_tablet")
                    } else {
                        //: The secondary label shown when the tutorial is started (for small screen devices)
                        //% "Simply hold the device in one hand and follow the instructions on screen to learn how to navigate in Sailfish OS"
                        description.text = qsTrId("tutorial-la-follow_the_instructions")
                    }
                }
            }
            break
        case 1:
            //% "Now you know how to navigate between Lock screen, Home and Events"
            description.text = qsTrId("tutorial-la-recap_home")
            break
        case 2:
            //% "Now you know that swiping from the left or right edge brings you back to Home"
            description.text = qsTrId("tutorial-la-recap_swipe_to_close")
            break
        case 3:
            if (androidLauncher) {
                //: This text has a full stop at the end unlike the other "recap labels" because
                //: it's shown together with tutorial-la-recap_tutorial_completed
                //% "Now you know that the line at the top of the view is the pulley menu and learned how to find more information about Jolla Launcher."
                description.text = qsTrId("tutorial-la-recap_pulley_menu_alternative")
                description.text += "\n\n"
                //: Text shown at the end of the tutorial below tutorial-la-recap_pulley_menu_alternative
                //% "This was the last part of the Tutorial. Now jump into the Sailfish experience!"
                description.text += qsTrId("tutorial-la-recap_tutorial_completed_alternative")
            } else {
                //% "Now you know that the dot on the top left indicates that you are in a subpage and swipe to right moves you to previous page"
                description.text = qsTrId("tutorial-la-recap_page_navigation")
            }
            break
        case 4:
            if (Tutorial.deviceType === Tutorial.PhoneDevice) {
                //% "Now you know that the line at the top of the view is the pulley menu and you learned how to call a phone number"
                description.text = qsTrId("tutorial-la-recap_phone_pulley_menu")
            } else if (Tutorial.deviceType === Tutorial.TabletDevice) {
                //% "Now you know that the line at the top of the view is the pulley menu"
                description.text = qsTrId("tutorial-la-recap_tablet_pulley_menu")
            } else {
                description.text = ""
            }
            break
        case 5:
            if (Tutorial.deviceType === Tutorial.PhoneDevice) {
                //: This text has a full stop at the end unlike the other "recap labels" because
                //: it's shown together with tutorial-la-recap_tutorial_completed
                //% "Now you know what to do when you get a call."
                description.text = qsTrId("tutorial-la-recap_incoming_call")
            } else if (Tutorial.deviceType === Tutorial.TabletDevice) {
                //: This text has a full stop at the end unlike the other "recap labels" because
                //: it's shown together with tutorial-la-recap_tutorial_completed
                //% "Now you know what to do when an alarm rings."
                description.text = qsTrId("tutorial-la-recap_alarm")
            } else {
                description.text = ""
            }

            description.text += "\n\n"
            //: Text shown at the end of the tutorial below tutorial-la-recap_incoming_call
            //% "This was the last part of the Tutorial. Now jump into the Jolla experience!"
            description.text += qsTrId("tutorial-la-recap_tutorial_completed")
            break
        }
        showAnimation.restart()
    }

    SequentialAnimation {
        id: showAnimation
        PauseAnimation { id: showPause }
        FadeAnimation {
            target: root
            property: "opacity"
            to: 1.0
            duration: 1000
        }
        ScriptAction {
            script: {
                if (allowSystemGesturesBetweenLessons) {
                    __quickWindow.flags &= ~(Qt.WindowOverridesSystemGestures)
                }
            }
        }
    }

    SequentialAnimation {
        id: hideAnimation
        ScriptAction {
            script: {
                if (allowSystemGesturesBetweenLessons) {
                    __quickWindow.flags |= Qt.WindowOverridesSystemGestures
                }
            }
        }
        FadeAnimation {
            target: root
            property: "opacity"
            to: 0.0
            duration: 1000
        }
        ScriptAction { script: showLesson() }
    }

    Rectangle {
        anchors.fill: parent
        color: tutorialTheme.highlightDimmerColor
        opacity: 0.9
    }

    InfoLabel {
        id: label
        y: 4 * Theme.paddingLarge
        color: tutorialTheme.highlightColor
    }

    Label {
        id: description
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        x: Theme.horizontalPageMargin
        anchors {
            top: label.bottom
            topMargin: Theme.paddingLarge
        }
        width: parent.width - 2 * x
        color: tutorialTheme.highlightColor
    }

    MouseArea {
        property int step
        anchors.fill: parent
        // Use "visible" for disabling the mouse area because it
        // will also disable the children.
        visible: lessonCounter === 0

        function handleClick(number) {
            if (number === 0) {
                step = 1
            } else if (number === step) {
                if (number === 3) {
                    Qt.quit()
                } else {
                    step++
                }
            } else {
                step = 0
            }
        }

        onClicked: step = 0

        MouseArea {
            anchors { left: parent.left; top: parent.top }
            width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
            onClicked: parent.handleClick(0)
        }

        MouseArea {
            anchors { right: parent.right; top: parent.top }
            width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
            onClicked: parent.handleClick(1)
        }

        MouseArea {
            anchors { right: parent.right; bottom: parent.bottom }
            width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
            onClicked: parent.handleClick(2)
        }

        MouseArea {
            anchors { left: parent.left; bottom: parent.bottom }
            width: Theme.itemSizeLarge; height: Theme.itemSizeLarge
            onClicked: parent.handleClick(3)
        }
    }


    Button {
        id: againButton
        anchors {
            bottom: continueButton.top
            bottomMargin: 2 * Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        color: tutorialTheme.primaryColor
        highlightColor: tutorialTheme.highlightColor
        highlightBackgroundColor: tutorialTheme.highlightBackgroundColor
        enabled: buttonsEnabled
        //% "Try again"
        text: qsTrId("tutorial-bt-try_again")

        onClicked: hideAnimation.restart()
    }

    Button {
        id: continueButton
        anchors {
            bottom: progress.top
            bottomMargin: 4*Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        color: tutorialTheme.primaryColor
        highlightColor: tutorialTheme.highlightColor
        highlightBackgroundColor: tutorialTheme.highlightBackgroundColor
        enabled: buttonsEnabled

        onClicked: {
            lessonCounter++
            hideAnimation.restart()
        }
    }

    Row {
        id: progress

        anchors {
            bottom: parent.bottom
            bottomMargin: 3 * Theme.paddingLarge
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Theme.paddingMedium
        visible: completedLessons > 0

        Repeater {
            model: maxLessons
            Image {
                source: "image://theme/graphic-tutorial-progress-" + (index + 1) +
                        "?" + tutorialTheme.highlightColor
                opacity: (completedLessons > index) ? 1.0 : 0.5
            }
        }
    }
}
