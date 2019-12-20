import QtQuick 2.0
import Sailfish.Silica 1.0
import org.nemomobile.thumbnailer 1.0

Item {
    id: root

    signal togglePlay

    property url source
    property string mimeType

    property bool playing
    property bool loaded
    property alias busy: busyIndicator.running
    property alias status: poster.status

    property real contentWidth: width
    property real contentHeight: height

    property bool overlayMode
    property bool transpose
    readonly property bool error: !!poster.errorLabel
    readonly property bool down: videoMouse.pressed && videoMouse.containsMouse

    signal clicked

    function displayError() {
        poster.errorLabel = errorLabelComponent.createObject(poster)
    }

    implicitWidth: poster.implicitWidth
    implicitHeight: poster.implicitHeight

    onSourceChanged: {
        if (poster.errorLabel) {
            poster.errorLabel.destroy()
            poster.errorLabel = null
        }
    }

    MouseArea {
        id: videoMouse
        anchors {
            fill: parent
            margins: Theme.paddingLarge // don't react near display edges
        }
        onClicked: root.clicked()
    }

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
                   + "?" + (iconMouse.down ? Theme.highlightColor : Theme.lightPrimaryColor)
        }
        MouseArea {
            id: iconMouse

            property bool down: pressed && containsMouse
            anchors.fill: parent
            onClicked: togglePlay()
        }
    }
    Component {
        id: errorLabelComponent
        Rectangle {
            anchors.fill: parent
            color: Theme.rgba(Theme.overlayBackgroundColor, Theme.highlightBackgroundOpacity)

            opacity: 0
            FadeAnimator on opacity { from: 0; to: 1 }
            InfoLabel {
                //% "Oops, can't load the video"
                text: qsTrId("components_gallery-la-video-loading-failed")
                anchors.verticalCenter: parent.verticalCenter

            }
        }
    }

}
