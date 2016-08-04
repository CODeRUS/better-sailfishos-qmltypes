import QtQuick 2.0
import Sailfish.Silica 1.0
import QtMultimedia 5.0

DockedPanel {
    id: panel

    property bool fullscreen
    property real fullscreenWidth: parent.width
    property real fullscreenHeight: parent.height

    property bool playing: player.playbackState == MediaPlayer.Playing

    property bool _playing
    property bool paused

    property int position: !_loading ? player.position / 1000 : 0
    property bool atEnd: player.status == MediaPlayer.EndOfMedia

    property real _fullscreenProgress: panel.fullscreen ? 1.0 : 0.0
    Behavior on _fullscreenProgress { NumberAnimation { duration: 500 } }

    property bool _loading
    property bool _isVertical: dock == Dock.Bottom

    property bool effectivePaused: !panel.expanded
                || panel.paused
                || (!_isVertical && background.width < panel.fullscreenWidth)
                || (_isVertical && background.height < panel.fullscreenHeight)

    property bool effectivePlaying: _playing && !effectivePaused && player.source != ""
    onEffectivePlayingChanged: {
        if (effectivePlaying) {
            player.play()
        } else if (player.playbackState != MediaPlayer.Stopped) {
            player.pause()
        }
    }


    // compat
    property bool isPortrait: true
    dock: isPortrait ? Dock.Bottom : Dock.Right

    property alias buttons: buttonsContainer.children

    function play(url, position) {
        if (player.source != url) {
            player.source = url
            panel._loading = true
        } else if (!panel._loading) {
            panel.fullscreen = true
            panel.open = true
        }
        if (position !== undefined) {
            player.position = position * 1000
        }
        panel._playing = true
        panel.paused = false
    }

    function pause() {
        panel.paused = true
    }

    function stop() {
        player.stop()
        panel.paused = false
    }

    width: !_isVertical ? parent.width / 2 : parent.width
    height: _isVertical ? parent.height / 2 : parent.height

    Rectangle {
        id: background

        color: "black"
        clip: panel._fullscreenProgress < 2.0
        anchors { bottom: parent.bottom; right: parent.right }
        width: !_isVertical
                ? panel.width + ((panel.fullscreenWidth - panel.width) * panel._fullscreenProgress)
                : panel.width
        height: _isVertical
                ? panel.height + ((panel.fullscreenHeight - panel.height) * panel._fullscreenProgress)
                : panel.height

        MouseArea {
            anchors.fill: parent

            onClicked: {
                if (!panel.fullscreen) {
                    panel.fullscreen = true
                    panel._playing = true
                } else {
                    panel.fullscreen = false
                }
            }
        }

        VideoOutput {
            anchors.centerIn: parent

            scale: _isVertical
                    ? (implicitHeight !== 0 ? fullscreenHeight / implicitHeight : 1.0)
                    : (implicitWidth !== 0 ? fullscreenWidth / implicitWidth : 1.0)

            source: MediaPlayer {
                id: player

                onStopped: panel.fullscreen = false

                onStatusChanged: {
                    if (panel._loading && (status == MediaPlayer.Loaded || status == MediaPlayer.Buffered)) {
                        panel._loading = false
                        panel.fullscreen = true
                        panel.open = true
                    }
                }

                onPositionChanged: if (!positionSlider.pressed) positionSlider.value = position / 1000
            }
        }

        Item {
            id: controls
            anchors.centerIn: parent
            width: panel.width
            height: panel.height

            enabled: opacity > 0.5
            opacity: 1 - panel._fullscreenProgress

            Rectangle {
                color: "black"
                anchors.centerIn: parent
                width: background.width
                height: background.height
                opacity: 0.5
            }

            MouseArea {
                anchors.fill: buttonsContainer
            }

            Row {
                id: buttonsContainer
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge  // ### Spread evenly across full width, or fixed spacing centered?
            }

            Image {
                anchors.centerIn: parent

                source: "image://theme/icon-video-overlay-play"
            }

            MouseArea {
                anchors.fill: positionSlider
            }

            Slider {
                id: positionSlider

                anchors { left: parent.left; right: parent.right; bottom: parent.bottom }

                handleVisible: false
                minimumValue: 0
                maximumValue: player.duration / 1000
                valueText: Format.formatDuration(value, value >= 3600
                            ? Format.LongDuration
                            : Format.ShortDuration)

                onReleased: player.position = value * 1000
            }
        }
    }
}
