import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    onStatusChanged: {
        if (status === PageStatus.Active) {
            timeline.restart()
        } else if (status === PageStatus.Deactivating) {
            hintLabel.opacity = 0.0
        }
    }

    SequentialAnimation {
        id: timeline
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                fader.opacity = 0.9
                //% "The dot on the top left indicates that you are in a subpage"
                infoLabel.text = qsTrId("tutorial-la-page_indicators")
                infoLabel.opacity = 1.0
                continueButton.enabled = true
            }
        }
    }

    SequentialAnimation {
        id: timeline2
        ScriptAction  {
            script: {
                fader.opacity = 0.0
                infoLabel.opacity = 0.0
            }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction  {
            script: {
                //% "Flick right to go back to previous view"
                hintLabel.text = qsTrId("tutorial-la-flick_to_previous")
                hintLabel.opacity = 1.0

                // This is a workaround for JB#20714, making the MouseArea
                // invisible effectively disables it:
                touchBlocker.visible = false
                //touchBlocker.enabled = false
            }
        }
    }

    Connections {
        target: pageStack
        onPressedChanged: {
            if (page.status === PageStatus.Active && !touchBlocker.enabled) {
                hintLabel.opacity = pageStack.pressed ? 0.0 : 1.0
            }
        }
    }

    Image {
        source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-gallery-photos.png")
        sourceSize {
            width: 540 * xScale
            height: 960 * yScale
        }
        width: sourceSize.width
        height: sourceSize.height
    }

    Item {
        id: pageIndicator
        width: Theme.itemSizeSmall
        height: Theme.itemSizeLarge
    }

    TouchInteractionHint {
        id: hint
        direction: TouchInteraction.Right
        loops: Animation.Infinite
        running: hintLabel.opacity > 0
        anchors.verticalCenter: parent.verticalCenter
    }

    HintLabel {
        id: hintLabel
        atBottom: true
        opacity: 0.0
    }

    DimmedRegion {
        id: fader
        anchors.fill: parent
        color: tutorialTheme.highlightDimmerColor
        opacity: 0.0
        target: page
        area: Qt.rect(0, 0, parent.width, parent.height)
        exclude: [ pageIndicator ]

        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    InfoLabel {
        id: infoLabel
        anchors {
            centerIn: parent
            verticalCenterOffset: -3 * Theme.paddingLarge
        }
        opacity: 0.0
        color: tutorialTheme.highlightColor
        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    EdgeBlocker { edge: Qt.LeftEdge }

    EdgeBlocker { edge: Qt.RightEdge }

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
        opacity: enabled ? infoLabel.opacity : 0
        enabled: false
        //% "Got it!"
        text: qsTrId("tutorial-bt-got_it")

        onClicked: {
            enabled = false
            timeline2.restart()
        }
    }
}
