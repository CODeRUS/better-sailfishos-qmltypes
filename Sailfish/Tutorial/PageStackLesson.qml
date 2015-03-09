import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: root

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
                //% "Here is running Gallery app"
                appInfo.text = qsTrId("tutorial-la-gallery_app")
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
                galleryApp.enabled = true
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
        exclude: [ galleryApp ]

        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    MouseArea {
        id: galleryApp
        x: 24 * xScale
        y: 545 * yScale
        width: 148 * xScale
        height: 235 * yScale
        visible: fader.opacity > 0.0
        enabled: false

        onClicked: {
            enabled = false
            showGalleryAnimation.start()
        }

        Rectangle {
            visible: parent.pressed && parent.containsMouse
            anchors.fill: parent
            color: Theme.rgba(tutorialTheme.highlightColor, 0.3)
        }

        TapInteractionHint {
            running: galleryApp.enabled && appInfo.opacity === 1.0
            anchors.centerIn: parent
        }
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
        id: galleryMainPage
        opacity: 0.0
        source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-gallery-index.png")
        sourceSize {
            width: 540 * xScale
            height: 960 * yScale
        }
        width: sourceSize.width
        height: sourceSize.height

        BackgroundItem {
            id: photosItem
            width: parent.width
            height: 135 * yScale
            highlightedColor: Theme.rgba(tutorialTheme.highlightColor, 0.3)
            enabled: appInfoLabel.opacity === 1.0

            onClicked: {
                pageStack.push(photosPage)
                galleryFader.opacity = 0.0
                appInfoLabel.opacity = 0.0
            }
        }

        TapInteractionHint {
            visible: appInfoLabel.opacity !== 0.0
            running: photosItem.enabled
            anchors.centerIn: photosItem
        }

        Rectangle {
            id: galleryFader
            anchors {
                fill: parent
                topMargin: photosItem.height
            }
            color: tutorialTheme.highlightDimmerColor
            opacity: 0.0
            Behavior on opacity { FadeAnimation { duration: 500 } }
        }

        InfoLabel {
            id: appInfoLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: photosItem.bottom
                topMargin: 2 * Theme.paddingLarge
            }
            opacity: 0.0
            color: tutorialTheme.highlightColor
            //% "Tap to open"
            text: qsTrId("tutorial-la-tap_to_open")
            Behavior on opacity { FadeAnimation { duration: 500 } }
        }
    }

    SequentialAnimation {
        id: showGalleryAnimation
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
            target: galleryMainPage
            property: "opacity"
            to: 1.0
            duration: 500
        }
        PauseAnimation { duration: 1000 }
        ScriptAction {
            script: {
                galleryFader.opacity = 0.8
                appInfoLabel.opacity = 1.0
            }
        }
    }

    SequentialAnimation {
        id: closeAnimation
        PauseAnimation { duration: 200 }
        FadeAnimation {
            target: root
            to: 0.0
            duration: 2000
        }
    }

    Component {
        id: photosPage
        PhotosPage {
            Component.onDestruction: {
                background.returnToBounds()
                closeAnimation.restart()
                lessonCompleted(200)
            }
        }
    }
}
