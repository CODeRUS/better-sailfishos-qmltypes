import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Tutorial 1.0
import "private"

Lesson {
    id: page

    //% "Now you know that the dot on the top left indicates that you are in a subpage and swipe to right moves you to previous page"
    recapText: qsTrId("tutorial-la-recap_page_navigation")

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
        opacity: galleryMainPageWrapper.opacity
        source: Screen.sizeCategory >= Screen.Large
                ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-app-background.png")
                : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-app-background.png")
    }

    Item {
        id: galleryMainPageWrapper

        anchors.fill: parent
        opacity: 0.0

        GalleryMainPage {
            id: galleryMainPage
        }

        Item {
            id: shadow

            width: galleryMainPage.interactionItem.width
            height: galleryMainPage.interactionItem.height
            x: galleryMainPage.x + galleryMainPage.interactionItem.x
            y: galleryMainPage.y + galleryMainPage.interactionItem.y
        }

        Connections {
            target: galleryMainPage
            onItemClicked: {
                pageStack.animatorPush(photosPage)
                galleryFader.opacity = 0.0
                appInfoLabel.opacity = 0.0
            }
        }

        TapInteractionHint {
            visible: appInfoLabel.opacity !== 0.0
            running: galleryMainPage.interactionItem.enabled
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
            target: galleryMainPageWrapper
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
                closeAnimation.restart()
                lessonCompleted(200)
            }
        }
    }
}
