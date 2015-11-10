import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: page

    _clickablePageIndicators: false
    showNavigationIndicator: false

    onStatusChanged: {
        if (status === PageStatus.Active) {
            timeline.restart()
        } else if (status === PageStatus.Deactivating) {
            hintLabel.opacity = 0.0
            hint.stop()
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
                //% "Swipe right to go back to previous page"
                hintLabel.text = qsTrId("tutorial-la-swipe_to_previous")
                hintLabel.opacity = 1.0
                hint.start()

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
                if (pageStack.pressed)
                    hint.stop()
                else
                    hint.start()
            }
        }
    }

    GlassItem {
        id: pageIndicator

        x: -width/2 + (pageStack && pageStack._currentContainer ? pageStack._currentContainer.x : 0)
        color: Theme.primaryColor
        radius: 0.22
        falloffRadius: 0.18
        parent: __silica_applicationwindow_instance.indicatorParentItem
    }

    SilicaFlickable {
        anchors.fill: parent

        interactive: false

        PullDownMenu {
            highlightColor: tutorialTheme.highlightColor
            backgroundColor: tutorialTheme.highlightBackgroundColor
        }
    }

    PageHeader {
        id: pageHeader

        //% "Photos"
        title: qsTrId("tutorial-la-gallery_photos_album")
        _titleItem.color: tutorialTheme.highlightColor
    }

    Image {
        anchors {
            top: pageHeader.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }
        sourceSize.width: width
        sourceSize.height: height

        source: Screen.sizeCategory >= Screen.Large
                ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-gallery-app-grid.png")
                : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-gallery-app-grid.png")
    }

    TouchInteractionHint {
        id: hint
        direction: TouchInteraction.Right
        loops: Animation.Infinite
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
        highlightBackgroundColor: tutorialTheme.highlightBackgroundColor
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
