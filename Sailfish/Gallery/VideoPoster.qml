import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.thumbnailer 1.0

MouseArea {
    id: root

    signal togglePlay

    property url source
    property string mimeType

    property bool playing
    property bool loaded
    property alias busy: busyIndicator.running

    property real contentWidth: width
    property real contentHeight: height

    property bool overlayMode
    property bool transpose
    readonly property bool error: poster.status == Thumbnail.Error
    readonly property bool down: pressed && containsMouse

    implicitWidth: poster.implicitWidth
    implicitHeight: poster.implicitHeight

    // Poster
    Thumbnail {
        id: poster

        property var errorLabel

        anchors.centerIn: parent

        width: !transpose ? root.contentWidth : root.contentHeight
        height: !transpose ? root.contentHeight : root.contentWidth

        sourceSize.width: Screen.height
        sourceSize.height: Screen.height

        source: root.source
        mimeType: root.mimeType

        priority: Thumbnail.HighPriority
        fillMode: Thumbnail.PreserveAspectFit
        opacity: !loaded ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }
        onStatusChanged: {
            if (status == Thumbnail.Error) {
                errorLabel = errorLabelComponent.createObject(poster)
            } else if (errorLabel) {
                errorLabel.destroy()
                errorLabel = null
            }
        }

        visible: !loaded
        rotation: transpose ? (implicitHeight > implicitWidth ? 270 : 90)  : 0
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
    }

    Image {
        id: icon
        anchors.centerIn: parent
        enabled: !busy && (overlayMode || !playing) && !root.error
        opacity: enabled ? 1.0 : 0.0
        Behavior on opacity { FadeAnimator {} }

        Binding	{
            target: icon
            when: overlayMode || !playing // avoid flicker to pause icon when pressing play
            property: "source"
            value: "image://theme/icon-video-overlay-" + (playing ?  "pause" : "play")
                   + "?" + (mouseArea.down ? Theme.highlightColor : Theme.lightPrimaryColor)
        }
        MouseArea {
            id: mouseArea

            property bool down: pressed && containsMouse
            anchors.fill: parent
            onClicked: togglePlay()
        }
    }
    Component {
        id: errorLabelComponent
        InfoLabel {
            //% "Oops, can't load the video"
            text: qsTrId("components_gallery-la-video-loading-failed")
            anchors.verticalCenter: parent.verticalCenter
            opacity: poster.status == Thumbnail.Error ? 1.0 : 0.0
            Behavior on opacity { FadeAnimator {}}
        }
    }

}
