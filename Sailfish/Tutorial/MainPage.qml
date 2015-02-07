import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    id: mainPage

    property alias background: flickable
    property int lessonCounter: 0
    property int maxLessons: androidLauncher ? 3 : 6
    property real xScale: Screen.width / 540.0
    property real yScale: Screen.height / 960.0
    property bool androidLauncher

    function lessonCompleted(pauseDuration) {
        recap.show(pauseDuration)
    }

    function showLesson() {
        // Reset source in order to make sure a new instance is always created
        lessonLoader.source = ""
        if (lessonCounter === 1) {
            lessonLoader.source = Qt.resolvedUrl("LauncherLesson.qml")
        } else if (lessonCounter === 2) {
            lessonLoader.source = Qt.resolvedUrl("SwipeLesson.qml")
        } else if (lessonCounter === 3) {
            lessonLoader.source = androidLauncher
                    ? Qt.resolvedUrl("PulleyLessonAlternative.qml")
                    : Qt.resolvedUrl("EventsViewLesson.qml")
        } else if (androidLauncher) {
            Qt.quit()
        } else if (lessonCounter === 4) {
            lessonLoader.source = Qt.resolvedUrl("PageStackLesson.qml")
        } else if (lessonCounter === 5) {
            lessonLoader.source = Qt.resolvedUrl("PulleyLesson.qml")
        } else if (lessonCounter === 6) {
            lessonLoader.source = Qt.resolvedUrl("PhoneCallLesson.qml")
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
        highlightRangeMode: ListView.StrictlyEnforceRange
        maximumFlickVelocity: 4000 * yScale
        highlightMoveDuration: 300
        pressDelay: 0
        interactive: false

        property real offset: contentY / (contentHeight - height)

        model: ListModel {}
        delegate: Item { height: model.height }

        Component.onCompleted: {
            flickable.model.append({ height: 1020 * yScale })
            flickable.model.append({ height: 960 * yScale })
            flickable.model.append({ height: 960 * yScale })
        }
    }

    Column {
        width: parent.width
        y: -flickable.contentY

        Image {
            source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-launcher-overlay.png")
            sourceSize {
                width: 540 * xScale
                height: 2940 * yScale
            }
            width: sourceSize.width
            height: sourceSize.height

            Image {
                source: Qt.resolvedUrl("/usr/share/sailfish-tutorial/graphics/tutorial-launcher-background.jpg")
                y: Math.max(0, flickable.offset * (parent.height - height))
                z: -1
                sourceSize {
                    width: 540 * xScale
                    height: 1600 * yScale
                }
                width: sourceSize.width
                height: sourceSize.height

                Rectangle {
                    anchors.fill: parent
                    opacity: flickable.offset
                    color: tutorialTheme.highlightDimmerColor
                }
            }
        }
    }

    Loader {
        id: lessonLoader
        anchors.fill: parent
    }

    RecapItem {
        id: recap
    }
}
