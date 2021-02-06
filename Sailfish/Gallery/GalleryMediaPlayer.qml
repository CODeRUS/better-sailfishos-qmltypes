import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Media 1.0
import org.nemomobile.policy 1.0
import Nemo.KeepAlive 1.2
import Nemo.Notifications 1.0

MediaPlayer {
    id: root

    property bool busy

    onLoadedChanged: if (loaded) playerLoader.anchors.centerIn = currentItem
    property bool _minimizedPlaying
    property alias active: permissions.enabled
    readonly property bool playing: playbackState == MediaPlayer.PlayingState
    readonly property bool loaded: status >= MediaPlayer.Loaded && status <= MediaPlayer.EndOfMedia
    readonly property bool hasError: error !== MediaPlayer.NoError
    property bool _reseting

    signal displayError

    onPositionChanged: {
        // JB#50154: Work-around, force load frame preview when seeking the end
        if (status === MediaPlayer.EndOfMedia) {
            asyncPause.restart()
        }
        busy = false
    }

    property var asyncPause: Timer {
        interval: 16
        onTriggered: pause()
    }

    onHasErrorChanged: {
        if (error === MediaPlayer.FormatError) {
            //: %1 is replaced with specific codec
            //% "Unsupported codec: %1"
            _errorNotification.body = qsTrId("components_gallery-la-unsupported-codec").arg(errorString)
            _errorNotification.publish()
        }
    }
    onStatusChanged: {
        busy = false
        if (status === MediaPlayer.InvalidMedia) {
            displayError()
        }
    }

    autoLoad: false

    function togglePlay() {
        if (playing) {
            pause()
        } else {
            play()
        }
    }

    function reset() {
        stop()
        _reseting = true
        _reseting = false
    }

    property QtObject _errorNotification: Notification {
        isTransient: true
        urgency: Notification.Critical
        icon: "icon-system-warning"
    }

    property Item _content: Item {
        Binding {
            target: root
            when: _reseting
            property: "source"
            value: ""
        }
        Connections {
            target: Qt.application
            onActiveChanged: {
                if (!Qt.application.active) {
                    // if we were playing a video when we minimized, store that information.
                    _minimizedPlaying = playing
                    if (_minimizedPlaying) {
                        pause() // and automatically pause the video
                    }
                } else if (_minimizedPlaying) {
                    play()
                }
            }
        }

        DisplayBlanking {
            preventBlanking: playing
        }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaTogglePlayPause; onPressed: togglePlay() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPlay; onPressed: play() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaPause; onPressed: pause() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_MediaStop; onPressed: stop() }
        MediaKey { enabled: keysResource.acquired; key: Qt.Key_ToggleCallHangup; onPressed: togglePlay() }

        Permissions {
            id: permissions
            applicationClass: "player"
            Resource {
                id: keysResource
                type: Resource.HeadsetButtons
                optional: true
            }
        }
    }
}
