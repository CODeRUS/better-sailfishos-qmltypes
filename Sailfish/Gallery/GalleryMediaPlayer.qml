import QtQuick 2.0
import QtMultimedia 5.0
import Sailfish.Media 1.0
import org.nemomobile.policy 1.0

MediaPlayer {
    id: root

    property bool _minimizedPlaying
    property alias active: permissions.enabled
    readonly property bool playing: playbackState == MediaPlayer.PlayingState
    readonly property bool loaded: status >= MediaPlayer.Loaded && status < MediaPlayer.EndOfMedia
    readonly property bool hasError: error !== MediaPlayer.NoError
    property bool _reseting

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

        ScreenBlank {
            suspend: playing
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
