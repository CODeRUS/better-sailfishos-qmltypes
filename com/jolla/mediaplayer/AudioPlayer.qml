// -*- qml -*-

pragma Singleton
import QtQuick 2.0
import com.jolla.mediaplayer 1.0
import org.nemomobile.mpris 1.0

Container {
    id: player

    property bool shuffle
    property bool repeat
    property bool repeatOne
    property bool rewinding
    property bool forwarding

    property bool _resume
    property int _seekOffset
    property bool _seekRepeat
    property var _metadata: ({})

    readonly property alias currentItem: audio.currentItem

    readonly property alias metadata: player._metadata
    readonly property alias duration: audio.duration
    readonly property alias state: audio.playbackState
    readonly property alias playModel: audio.model
    readonly property bool active: audio.model.count > 0
    readonly property int position: audio.position + _seekOffset
    readonly property bool playing: audio.playbackState == Audio.Playing || _resume

    readonly property bool _seeking: player.rewinding || player.forwarding

    signal tryingToPlay

    onRepeatChanged: if (!repeat) repeatOne = false

    function setPosition(position) {
        audio.position = position
        mprisPlayer.emitSeeked()
    }

    function setSeekRepeat(repeat) {
        _seekRepeat = repeat
    }

    function seekForward(time) {
        _seekOffset += time
        if (position > duration) {
            _seekOffset = duration - audio.position
        }
        mprisPlayer.emitSeeked()
    }

    function seekBackward(time) {
        _seekOffset -= time
        if (position < 0) {
            _seekOffset = -audio.position
        }
        mprisPlayer.emitSeeked()
    }

    function playIndex(index) {
        if (!playModel) {
            return
        }

        audio.model.currentIndex = index
        _play()
    }

    function play(model, index) {
        if (model !== undefined && index !== undefined) {
            audio.setPlayModel(model)
            audio.model.currentIndex = playModel.shuffledIndex(index)
        }

        _play()
    }

    function shuffleAndPlay(model, modelSize) {
        audio.setPlayModel(model)

        audio.model.currentIndex = Math.floor(Math.random() * modelSize)
        playModel.shuffle()
        _play()
    }

    function addToQueue(mediaOrModel) {
        audio.addToQueue(mediaOrModel)
    }

    function removeFromQueue(index) {
        if (index >= playModel.count || index < 0) {
            console.warn("Invalid index passed to removeFromQueue()")
            return
        }

        // If it's the current item then we try to play the next one:
        if (index == playModel.currentIndex) {
            if (repeat || index !== playModel.count - 1) {
                audio.playNext()
            } else {
                stop()
                audio.model.currentIndex = 0
            }

            if (state != Audio.Playing) {
                stop()
            }
        }

        // If it's still the currentIndex then we just stop playback.
        if (index == playModel.currentIndex) {
            audio.model.currentIndex = -1
        }

        audio.removeFromQueue(index)
    }

    function removeItemFromQueue(mediaItem)
    {
        for (var i = audio.indexOf(mediaItem, 0); i != -1; i = audio.indexOf(mediaItem, i)) {
            removeFromQueue(i)
        }
    }

    function playUrl(url) {
        playModel.clear()
        playModel.appendUrl(url)
        playIndex(0)
    }

    function playPause() {
        if (playing) {
            pause()
        } else {
            _play()
        }
    }

    function _play() {
        if (_seeking) {
            _resume = true
        } else if (audio.isEndOfMedia()) {
            audio.playNext()
        } else {
            audio.play()
        }
        tryingToPlay()
    }

    function pause() {
        _resume = false
        audio.pause()
    }

    function stop() {
        audio.stop()
    }

    function playPrevious(warn) {
        audio.playPrevious()
        if (warn) {
            tryingToPlay()
        }
    }

    function playNext(warn) {
        audio.playNext()
        if (warn) {
            tryingToPlay()
        }
    }

    on_SeekingChanged: {
        if (_seeking) {
            _resume = state == Audio.Playing
            audio.pause()
        } else {
            audio.position += _seekOffset
            _seekOffset = 0
            if (_resume) {
                _resume = false
                audio.play()
            }
        }
    }

    onShuffleChanged: if (audio.model.shuffled != shuffle) audio.model.shuffled = !audio.model.shuffled

    onRewindingChanged: {
        if (rewinding) {
            if (_seekRepeat) {
                _seekRepeat = false
                seekBackward(1000)
                previousTimer.stop()
            } else {
                seekBackward(5000)

                // Wired headsets can overload the fast forward key to mean next if held, but
                // bluetooth headsets will manage this themselves, and will auto repeat the key if held.
                // To support the wired headset we restart a timer on each key press and cancel it on
                // release, triggering the next song action on the timer expiring.  If the key auto
                // repeats the restart will prevent the timer expiring and holding will act as a
                // series of successive presses.
                previousTimer.restart()
            }
        } else {
            _seekRepeat = false
            previousTimer.stop()
        }
    }

    onForwardingChanged: {
        if (forwarding) {
            if (_seekRepeat) {
                _seekRepeat = false
                seekForward(1000)
                nextTimer.stop()
            } else {
                seekForward(5000)
                nextTimer.restart()
            }
        } else {
            _seekRepeat = false
            nextTimer.stop()
        }
    }

    Timer { id: nextTimer; interval: 500; onTriggered: audio.playNext() }
    Timer { id: previousTimer; interval: 500; onTriggered: audio.playPrevious() }

    Audio {
        id: audio

        property int playbackState
        property bool changingItem

        onEndOfMedia: {
            if (repeatOne) {
                audio.playCurrent()
            } else if (repeat || model.currentIndex + 1 < model.count) {
                audio.playNext()
            } else {
                stop()
                playbackState = Audio.Stopped
            }
        }
        model.onShuffledChanged: if (player.shuffle != model.shuffled) player.shuffle = !player.shuffle

        onCurrentItemChanged: {
            player._seekOffset = 0

            var metadata = {}
            if (currentItem) {
                metadata = {
                    'url'       : audio.currentItem.url,
                    'title'     : audio.currentItem.title,
                    'artist'    : audio.currentItem.author,
                    'album'     : audio.currentItem.album,
                    'genre'     : "",
                    'track'     : audio.model.currentIndex,
                    'trackCount': audio.model.count,
                    'duration'  : audio.currentItem.duration * 1000
                }
            }

            player._metadata = metadata
        }

        onStateChanged: {
            if (playbackState == state) return

            // We don't want the transition to stop state when
            // choosing to play the next or previous song, or when the
            // current song has finished and it will transit
            // automatically to the next one.
            if (Audio.Stopped == state && (changingItem || isEndOfMedia())) return

            playbackState = state
        }

        onPlaybackStateChanged: {
            if (playbackState == Audio.Playing && !player._resume) {
                player.tryingToPlay()
            } else if (playbackState == Audio.Stopped) {
                player._resume = false
            }
        }

        function playCurrent() {
            changingItem = true
            play()
            changingItem = false
            playbackState = state
        }

        function playNext() {
            changingItem = true
            model.currentIndex = model.currentIndex < model.count - 1
                    ? model.currentIndex + 1
                    : 0
            play()
            changingItem = false
            playbackState = state
        }

        function playPrevious() {
            // We play previous if less than 5 seconds have elapsed.
            // otherwise we rewind the playing song
            if (playModel.count === 1 || audio.position >= 5000) {
                player.setPosition(0)
                return
            }

            changingItem = true
            model.currentIndex = model.currentIndex >= 1
                    ? model.currentIndex - 1
                    : model.count - 1
            play()
            changingItem = false
            playbackState = state
        }
    }

    BluetoothMediaPlayer {
        id: bluetoothMediaPlayer

        status: {
            if (audio.playbackState == Audio.Playing) {
                return BluetoothMediaPlayer.Playing
            } else if (audio.playbackState == Audio.Stopped) {
                return BluetoothMediaPlayer.Stopped
            } else if (player.rewinding) {
                return BluetoothMediaPlayer.ReverseSeek
            } else if (player.forwarding) {
                return BluetoothMediaPlayer.ForwardSeek
            } else {
                return BluetoothMediaPlayer.Paused
            }
        }

        repeat: player.repeat
                    ? BluetoothMediaPlayer.RepeatAllTracks
                    : BluetoothMediaPlayer.RepeatOff

        shuffle: player.shuffle
                    ? BluetoothMediaPlayer.ShuffleAllTracks
                    : BluetoothMediaPlayer.ShuffleOff

        position: audio.position

        metadata: player.metadata ? player.metadata : {}

        onChangeRepeat: {
            if (repeat == BluetoothMediaPlayer.RepeatOff) {
                player.repeat = false
            } else if (repeat == BluetoothMediaPlayer.RepeatAllTracks) {
                player.repeat = true
            }
        }

        onChangeShuffle: {
            if (shuffle == BluetoothMediaPlayer.ShuffleOff) {
                player.shuffle = false
            } else if (shuffle == BluetoothMediaPlayer.ShuffleAllTracks) {
                player.shuffle = true
            }
        }

        onNextRequested: audio.playNext()
        onPreviousRequested: audio.playPrevious()
        onPlayRequested: player._play()
        onPauseRequested: player.pause()
        onSeekRequested: {
            var position = audio.position + (offset / 1000)

            if (offset > 0) {
                position = (Math.ceil(position / 1000) + 1) * 1000
            } else if (offset < 0) {
                position = (Math.floor(position / 1000) - 1) * 1000
            }

            player.setPosition(Math.max(0, position))
        }

    }

    MprisPlayer {
        id: mprisPlayer

        property alias localMetadata: player.metadata

        function emitSeeked() {
            seeked(audio.position * 1000)
        }

        serviceName: "jolla-mediaplayer"

        // Mpris2 Root Interface
        identity: qsTrId("mediaplayer-ap-name")
        // Hard coded. FIXME: JB#22001.
        desktopEntry: "jolla-mediaplayer"
        supportedUriSchemes: ["file", "http", "https"]
        supportedMimeTypes: ["audio/x-wav", "audio/mp4", "audio/mpeg", "audio/x-vorbis+ogg"]

        // Mpris2 Player Interface
        canControl: true

        canGoNext: {
            if (!active) return false
            if ((audio.model.currentIndex + 1 >= audio.model.count) && (loopStatus != Mpris.Playlist)) return false
            return true
        }
        canGoPrevious: {
            if (!active) return false

            // Always possible to go to the beginning of the song
            // This is NOT how Mpris should behave but ... oh, well ...
            if (position >= 5000000) return true

            if (audio.model.currentIndex < 1) return false
            return true
        }
        // Do we have an item URL in the metadata?
        canPause: localMetadata ? 'url' in localMetadata : false
        canPlay: localMetadata ? 'url' in localMetadata : false
        canSeek: localMetadata ? 'url' in localMetadata : false

        loopStatus: player.repeat ? Mpris.Playlist : Mpris.None
        playbackStatus: {
            if (audio.playbackState == Audio.Playing) {
                return Mpris.Playing
            } else if (audio.playbackState == Audio.Stopped) {
                return Mpris.Stopped
            } else {
                return Mpris.Paused
            }
        }
        position: audio.position * 1000
        shuffle: player.shuffle
        volume: 1

        onPauseRequested: player.pause()
        onPlayRequested: player._play()
        onPlayPauseRequested: player.playPause()
        onStopRequested: audio.stop()

        // This will start playback in any case. Mpris says to keep
        // paused/stopped if we were before but I suppose this is just
        // our general behavior decision here.
        onNextRequested: audio.playNext()
        onPreviousRequested: audio.playPrevious()

        onSeekRequested: {
            var position = audio.position + (offset / 1000)
            player.setPosition(position < 0 ? 0 : position)
        }
        onSetPositionRequested: player.setPosition(position / 1000)
        onOpenUriRequested: playUrl(url)

        onLoopStatusRequested: {
            if (loopStatus == Mpris.None) {
                player.repeat = false
            } else if (loopStatus == Mpris.Playlist) {
                player.repeat = true
            }
        }
        onShuffleRequested: player.shuffle = shuffle

        onLocalMetadataChanged: {
            var metadata = {}

            if (localMetadata && 'url' in localMetadata) {
                metadata[Mpris.metadataToString(Mpris.Url)] = localMetadata['url'] // Url

                // FIXME: Related to JB#13207. The "id" has to be an
                // unique identifier and it is not.
                metadata[Mpris.metadataToString(Mpris.TrackId)] = "/com/jolla/mediaplayer/" + Qt.md5(localMetadata['url'].toString()) // DBus object path
                metadata[Mpris.metadataToString(Mpris.Length)] = localMetadata['duration'] * 1000 // Microseconds
                metadata[Mpris.metadataToString(Mpris.Album)] = localMetadata['album'] // String
                metadata[Mpris.metadataToString(Mpris.Artist)] = [localMetadata['artist']] // List of strings
                metadata[Mpris.metadataToString(Mpris.Genre)] = [localMetadata['genre']] // List of strings
                metadata[Mpris.metadataToString(Mpris.Title)] = localMetadata['title'] // String
                metadata[Mpris.metadataToString(Mpris.TrackNumber)] = localMetadata['track'] // Int
            }

            mprisPlayer.metadata = metadata
        }
    }
}
