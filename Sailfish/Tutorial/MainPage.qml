import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Tutorial 1.0
import "private"

Page {
    id: mainPage

    property alias background: flickable
    property alias applicationBackground: applicationBackgroundItem
    property alias applicationGridIndicator: swipeHandle
    property alias upgradeMode: recap.upgradeMode
    property int lessonCounter: 0
    property int maxLessons: androidLauncher ? 3 : 5
    property bool showApplicationOverlay: false
    property bool showStatusBarClock: false

    // This date and time is hard-coded in some of the graphical assets as well.
    property date tutorialDate: new Date(2015, 5, 8, 17, 07, 0)

    property real baseWidth: Screen.sizeCategory >= Screen.Large ? 1536 : 540
    property real baseHeight: Screen.sizeCategory >= Screen.Large ? 2048 : 960
    property real xScale: width / baseWidth
    property real yScale: height / baseHeight

    property bool androidLauncher

    Component.onCompleted: {
        // force Tutorial singleton construction now
        Tutorial.deviceType
    }

    function lessonCompleted(pauseDuration) {
        if (lessonCounter === maxLessons)
            showApplicationOverlay = false

        recap.show(pauseDuration)
    }
    function jumpToLesson(lesson) {
        lessonLoader.source = ""
        lessonLoader.source = Qt.resolvedUrl(lesson)
    }

    function showLesson() {
        // Reset source in order to make sure a new instance is always created
        lessonLoader.source = ""
        if (lessonCounter === 1) {
            lessonLoader.source = Qt.resolvedUrl("HomeLesson.qml")
        } else if (lessonCounter === 2) {
            // Launcher lesson is split in two halves. LauncherLesson will direcly load SwipeLesson
            // after it completes.
            lessonLoader.source = Qt.resolvedUrl("LauncherLesson.qml")
        } else if (lessonCounter === 3) {
            lessonLoader.source = androidLauncher
                    ? Qt.resolvedUrl("AndroidLauncherPulleyLesson.qml")
                    : Qt.resolvedUrl("PageStackLesson.qml")
        } else if (androidLauncher) {
            Qt.quit()
        } else if (lessonCounter === 4) {
            if (Tutorial.deviceType === Tutorial.PhoneDevice)
                lessonLoader.source = Qt.resolvedUrl("PhonePulleyLesson.qml")
            else
                lessonLoader.source = Qt.resolvedUrl("TabletPulleyLesson.qml")
        } else if (lessonCounter === 5) {
            if (Tutorial.deviceType === Tutorial.PhoneDevice)
                lessonLoader.source = Qt.resolvedUrl("PhoneCallLesson.qml")
            else
                lessonLoader.source = Qt.resolvedUrl("TabletAlarmLesson.qml")
        } else {
            Qt.quit()
        }
    }

    onStatusChanged: {
        if (status === PageStatus.Active && lessonCounter === 0) {
            recap.show(1000)
        }
    }

    SilicaListView {
        id: flickable

        anchors.fill: parent
        snapMode: ListView.SnapOneItem
        orientation: ListView.Horizontal
        highlightRangeMode: ListView.StrictlyEnforceRange
        maximumFlickVelocity: 4000 * xScale
        highlightMoveDuration: 300
        pressDelay: 0
        interactive: false

        property real offset: contentX / (contentWidth - width)

        model: 2
        delegate: Item { width: flickable.width; height: flickable.height }

        Component.onCompleted: positionViewAtIndex(1, ListView.SnapPosition)
    }

    Item {
        parent: __silica_applicationwindow_instance._wallpaperItem
        anchors.fill: parent
        z: -1

        Image {
            anchors.fill: parent
            source: Screen.sizeCategory >= Screen.Large
                    ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-wallpaper.png")
                    : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-wallpaper.png")
        }

        Rectangle {
            anchors.fill: parent
            opacity: (1 - flickable.offset) / 2
            color: tutorialTheme.highlightDimmerColor
        }

        Row {
            height: parent.height
            x: -flickable.contentX

            // Ensure this is not visible during the pulley menu lesson
            opacity: lessonCounter == 4 ? 0 : 1

            Item {
                width: flickable.width
                height: flickable.height

                Image {
                    anchors.fill: parent
                    source: Screen.sizeCategory >= Screen.Large
                            ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-events.png")
                            : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-events.png")
                }
            }

            Item {
                width: flickable.width
                height: flickable.height

                Image {
                    source: Screen.sizeCategory >= Screen.Large
                            ? Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-tablet-switcher.png")
                            : Qt.resolvedUrl("file:///usr/share/sailfish-tutorial/graphics/tutorial-phone-switcher.png")

                    anchors.horizontalCenter: parent.horizontalCenter
                    visible: opacity > 0
                    opacity: showApplicationOverlay ? 1 : 0
                    Behavior on opacity { FadeAnimation { duration: 400 } }
                }
            }
        }

        Item {
            id: statusIndicator

            y: Theme.paddingMedium + Theme.paddingSmall
            width: parent.width
            height: batteryIndicator.totalHeight

            BatteryStatusIndicator {
                id: batteryIndicator

                property real iconWidth: Math.floor(Theme.iconSizeSmall*0.75)
                property size iconSize: Qt.size(iconWidth,iconWidth)
                property string iconSuffix: ""

                anchors {
                    left: parent.left
                }

                color: tutorialTheme.primaryColor
            }

            ClockItem {
                anchors.centerIn: parent

                time: tutorialDate
                color: tutorialTheme.primaryColor
                primaryPixelSize: Theme.fontSizeMedium

                opacity: showStatusBarClock ? 1 : 0
                Behavior on opacity { FadeAnimation { } }
            }

            ConnectionStatusIndicator {
                property real iconWidth: Math.floor(Theme.iconSizeSmall*0.75)
                property size iconSize: Qt.size(iconWidth,iconWidth)
                property string iconSuffix: ""

                anchors {
                    right: parent.right
                    rightMargin: Theme.paddingMedium
                    verticalCenter: parent.verticalCenter
                }
            }
        }

        Image {
            id: swipeHandle

            source: "image://theme/graphics-edge-swipe-handle"

            anchors {
                bottom: parent.bottom
                horizontalCenter: parent.horizontalCenter
            }
        }
    }

    Item {
        id: applicationBackgroundItem

        parent: __silica_applicationwindow_instance._wallpaperItem
        anchors.fill: parent
    }

    Loader {
        id: lessonLoader
        anchors.fill: parent
        onSourceChanged: swipeHandle.visible = true
    }

    RecapItem {
        id: recap
    }
}
