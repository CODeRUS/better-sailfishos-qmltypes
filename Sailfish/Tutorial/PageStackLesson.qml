import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Tutorial 1.0
import "private"

Item {
    id: page

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
                //% "Here is the minimized Gallery app"
                appInfo.text = qsTrId("tutorial-la-gallery_app")
                appInfo.opacity = 1.0
                galleryApp.enabled = true
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
        exclude: [ galleryApp ]

        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    CoverItem {
        id: galleryApp

        row: 1
        column: 2

        onClicked: {
            timeline.complete()
            enabled = false
            appInfo.opacity = 0
            showGalleryAnimation.start()
        }
    }

    TapInteractionHint {
        running: galleryApp.enabled && appInfo.opacity === 1.0
        anchors.centerIn: galleryApp
    }

    InfoLabel {
        id: appInfo
        anchors {
            bottom: galleryApp.top
            bottomMargin: 3 * Theme.paddingLarge
        }
        opacity: 0.0
        color: tutorialTheme.highlightColor
        Behavior on opacity { FadeAnimation { duration: 500 } }
    }

    Image {
        parent: applicationBackground
        anchors.fill: parent
        opacity: galleryMainPage.opacity
        source: Screen.sizeCategory >= Screen.Large
                ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-app-background.png")
                : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-app-background.png")
    }

    Item {
        id: galleryMainPage

        anchors.fill: parent
        opacity: 0.0

        Loader {
            id: pageContent

            source: Screen.sizeCategory >= Screen.Large
                    ? Qt.resolvedUrl("private/GalleryMainPageTablet.qml")
                    : Qt.resolvedUrl("private/GalleryMainPagePhone.qml")

            anchors.fill: parent
        }

        Item {
            id: shadow

            width: pageContent.item.interactionItem.width
            height: pageContent.item.interactionItem.height
            x: pageContent.x + pageContent.item.interactionItem.x
            y: pageContent.y + pageContent.item.interactionItem.y
        }

        Connections {
            target: pageContent.item
            onItemClicked: {
                pageStack.push(photosPage)
                galleryFader.opacity = 0.0
                appInfoLabel.opacity = 0.0
            }
        }

        TapInteractionHint {
            visible: appInfoLabel.opacity !== 0.0
            running: pageContent.item.interactionItem.enabled
            anchors.centerIn: shadow
        }

        DimmedRegion {
            id: galleryFader
            anchors.fill: parent
            color: tutorialTheme.highlightDimmerColor
            opacity: 0.0
            target: page
            area: Qt.rect(0, 0, page.width, page.height)
            exclude: [shadow]
            Behavior on opacity { FadeAnimation { duration: 500 } }
        }

        InfoLabel {
            id: appInfoLabel
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: shadow.bottom
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
            target: galleryMainPage
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
