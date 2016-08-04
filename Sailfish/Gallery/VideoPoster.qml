import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0
import org.nemomobile.thumbnailer 1.0

MouseArea {
    id: videoItem

    property QtObject player
    property bool active
    property url source
    property string mimeType
    property int duration

    property real contentWidth: width
    property real contentHeight: height

    property bool transpose

    property bool playing: active && videoItem.player && videoItem.player.playbackState == MediaPlayer.PlayingState
    readonly property bool _loaded: active
                && videoItem.player
                && videoItem.player.status >= MediaPlayer.Loaded
                && videoItem.player.status < MediaPlayer.EndOfMedia

    implicitWidth: poster.implicitWidth
    implicitHeight: poster.implicitHeight

    Connections {
        target: videoItem._loaded ? videoItem.player : null

        onPositionChanged: positionSlider.value = videoItem.player.position / 1000
    }

    onActiveChanged: {
        if (!active) {
            positionSlider.value = 0
        }
    }

    // Poster
    Thumbnail {
        id: poster

        anchors.centerIn: parent


        width: !videoItem.transpose ? videoItem.contentWidth : videoItem.contentHeight
        height: !videoItem.transpose ? videoItem.contentHeight : videoItem.contentWidth

        sourceSize.width: Screen.height
        sourceSize.height: Screen.height

        source: videoItem.source
        mimeType: videoItem.mimeType

        priority: Thumbnail.HighPriority
        fillMode: Thumbnail.PreserveAspectFit
        opacity: !videoItem._loaded ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation { id: posterFade } }

        visible: !videoItem._loaded || posterFade.running

        rotation: videoItem.transpose ? (implicitHeight > implicitWidth ? 270 : 90)  : 0
    }

    Item {
        width: videoItem.width
        height: videoItem.height

        opacity: videoItem.playing ? 0.0 : 1.0
        Behavior on opacity { FadeAnimation { id: controlFade } }

        visible: videoItem.player && (!videoItem.playing || controlFade.running)

        Image {
            anchors.centerIn: parent
            source: "image://theme/icon-video-overlay-play?"
                    + (mouseArea.down ? Theme.highlightColor : Theme.primaryColor)

            MouseArea {
                id: mouseArea

                property bool down: pressed && containsMouse
                anchors.fill: parent
                enabled: !videoItem.playing
                onClicked: {
                    videoItem.player.source = videoItem.source
                    videoItem.player.play()
                }
            }
        }

        Slider {
            id: positionSlider

            anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

            enabled: !videoItem.playing
            height: Theme.itemSizeExtraLarge
            handleVisible: false
            minimumValue: 0
            maximumValue: videoItem._loaded ? videoItem.player.duration / 1000 : videoItem.duration

            valueText: Format.formatDuration(value, value >= 3600
                        ? Format.DurationLong
                        : Format.DurationShort)

            onReleased: {
                if (videoItem.active) {
                    videoItem.player.source = videoItem.source
                    videoItem.player.seek(value * 1000)
                    videoItem.player.pause()
                }
            }
        }
    }
}
