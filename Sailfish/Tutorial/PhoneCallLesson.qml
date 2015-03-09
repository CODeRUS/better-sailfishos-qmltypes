import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

    anchors.fill: parent
    opacity: 0.0

    Component.onCompleted: {
        timeline.restart()
    }

    SequentialAnimation {
        id: timeline
        FadeAnimation {
            target: root
            to: 1.0
            duration: 500
        }
        PauseAnimation { duration: 1500 }
        ScriptAction  {
            script: {
                //% "This is an incoming call"
                hintLabel.text = qsTrId("tutorial-la-incoming_call")
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
                //% "The glows on top and bottom indicate the pulley menus"
                hintLabel.text = qsTrId("tutorial-la-pulley_explanation")
                hintLabel.opacity = 1.0
                answerMenu.busy = true
                rejectMenu.busy = true
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
                //% "Pull down to accept the call"
                hintLabel.text = qsTrId("tutorial-la-pull_down_to_answer")
                hintLabel.opacity = 1.0
                hintLabel.atBottom = true
                hint.running = true
                answerMenu.busy = false
                answerMenu.acceptAction = true
                rejectMenu.busy = false
                touchBlocker.enabled = false
            }
        }
    }

    SequentialAnimation {
        id: timeline2
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Pull up to ignore the call"
                hintLabel.text = qsTrId("tutorial-la-pull_down_to_ignore")
                hintLabel.opacity = 1.0
                hintLabel.atBottom = false
                hint.direction = TouchInteraction.Up
                hint.running = true
                rejectMenu.acceptAction = true
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
        source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-incoming-call.png")
        sourceSize {
            width: 540 * xScale
            height: 960 * yScale
        }
        width: sourceSize.width
        height: sourceSize.height
    }

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: height

        property bool menuActive: answerMenu.active || rejectMenu.active

        onMenuActiveChanged: {
            if (answerMenu.acceptAction || rejectMenu.acceptAction) {
                hintLabel.opacity = menuActive ? 0.0 : 1.0
                hint.running = menuActive ? false : true
            }
        }

        Item {
            id: content

            width: flickable.width
            height: flickable.height

            Label {
                //: The name of the caller
                //% "Friend"
                text: qsTrId("tutorial-la-friend")
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: callingLabel.top
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
                horizontalAlignment: Text.AlignHCenter
                font { family: Theme.fontFamilyHeading; pixelSize: Theme.fontSizeHuge }
            }
            Label {
                id: callingLabel
                //: Needs to match with voicecall-la-calling
                //% "calling"
                text: qsTrId("tutorial-la-calling")
                anchors {
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: 140/854*screen.height
                    leftMargin: Theme.paddingLarge
                    rightMargin: Theme.paddingLarge
                }
                horizontalAlignment: Text.AlignHCenter
                font { family: Theme.fontFamilyHeading; pixelSize: Theme.fontSizeHuge }
            }

            Image {
                y: Theme.paddingLarge
                anchors.horizontalCenter: parent.horizontalCenter
                source: "image://theme/icon-l-answer?#00CC00"
            }

            Image {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                    bottomMargin: Theme.paddingMedium
                }
                source: "image://theme/icon-l-reject?#CC0000"
            }

            HintLabel {
                id: hintLabel
                opacity: 0.0
            }
        }

        PullDownMenu {
            id: answerMenu

            property bool acceptAction

            highlightColor: "#80ff91"
            backgroundColor: "#19ff38"
            quickSelect: true

            MenuItem {
                color: "#aaff80"
                //: Needs to match with voicecall-me-answer
                //% "Answer"
                text: qsTrId("tutorial-me-answer")
                onClicked: {
                    if (answerMenu.acceptAction) {
                        answerMenu.acceptAction = false
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
            id: rejectMenu

            property bool acceptAction

            highlightColor: "#ff8084"
            backgroundColor: "#ff1a22"
            quickSelect: true

            Item {
                height: Theme.itemSizeExtraSmall
                width: parent.width
            }
            MenuItem {
                color: "#ff8080"
                //: Needs to match with voicecall-me-ignore
                //% "Ignore"
                text: qsTrId("tutorial-me-ignore")
                onClicked: {
                    if (rejectMenu.acceptAction) {
                        rejectMenu.acceptAction = false
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
        loops: Animation.Infinite
        anchors.horizontalCenter: parent.horizontalCenter
    }

    MouseArea {
        id: touchBlocker
        anchors.fill: parent
        preventStealing: true
    }
}
