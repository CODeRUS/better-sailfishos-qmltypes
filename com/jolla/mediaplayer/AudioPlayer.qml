// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0
import org.nemomobile.policy 1.0

DockedPanel {
    id: player

    property bool active: audio.model.count > 0
    property bool showAddToPlaylistButton: true

    property bool _grabKeys: active && keysResource.acquired

    property alias currentItem: audio.currentItem
    property alias duration: audio.duration
    property int position: audio.position + _seekOffset
    property alias state: audio.state
    property alias playModel: audio.model
    readonly property bool playing: audio.state == Audio.Playing || _resume
    readonly property bool seeking: forwardKey.pressed || rewindKey.pressed
    property bool _resume
    property int _seekOffset

    function seekForward(time) {
        player._seekOffset += time
        if (player.position > audio.duration) {
            player._seekOffset = audio.duration - audio.position
        }
        // Wired headsets can overload the fast forward key to mean next if held, but
        // bluetooth headsets will manage this themselves, and will auto repeat the key if held.
        // To support the wired headset we restart a timer on each key press and cancel it on
        // release, triggering the next song action on the timer expiring.  If the key auto
        // repeats the restart will prevent the timer expiring and holding will act as a
        // series of successive presses.
        nextTimer.restart()
    }

    function seekBackward(time) {
        player._seekOffset -= time
        if (player.position < 0) {
            player._seekOffset = -audio.position
        }
        previousTimer.restart()
    }

    width: parent.width

    height: column.height + 2*Theme.paddingLarge
    contentHeight: height
    flickableDirection: Flickable.VerticalFlick

    visible: active && root.applicationActive

    opacity: Qt.inputMethod.visible ? 0.0 : 1.0
    Behavior on opacity { FadeAnimation {}}


    function playIndex(index) {
        if (!audio.model) {
            return
        }

        audio.model.currentIndex = index
        _play()
    }

    function play(model, index) {
        audio.setPlayModel(model)
        audio.model.currentIndex = audio.model.shuffledIndex(index)

        _play()
    }

    function shuffleAndPlay(model, modelSize) {
        audio.setPlayModel(model)

        audio.model.currentIndex = Math.floor(Math.random() * modelSize)
        audio.model.shuffle()
        _play()
    }

    function addToQueue(mediaOrModel) {
        audio.addToQueue(mediaOrModel)
    }

    function removeFromQueue(index) {
        var isPlaying = audio.state == Audio.Playing
        var isVisible = player.visible

        if (index >= audio.model.count || index < 0) {
            console.log("Invalid index passed to removeFromQueue()")
            return
        }

        // If it's the current item then we try to play the next one:
        if (index == audio.model.currentIndex) {
            audio.playNext()

            if (!isPlaying) {
                player.stop()
            }
        }

        // If it's still the currentIndex then we just stop playback.
        if (index == audio.model.currentIndex) {
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
        audio.model.clear()
        audio.model.appendUrl(url)
        playIndex(0)
    }

    function toggle() {
        if (playing) {
            pause()
        } else {
            _play()
        }
    }

    function _play() {
        if (seeking) {
            _resume = true
        } else {
            audio.play()
        }
        showControls()
    }

    function pause() {
        _resume = false
        audio.pause()
    }

    function playNext() {
        audio.playNext()
        showControls()
    }

    function showControls() {
        if (playing) {
            open = true
        }
    }

    function hideControls() {
        open = false
    }

    onOpenChanged: {
        if (!open) {
            audio.pause()
        }
    }

    onSeekingChanged: {
        if (seeking) {
            _resume = audio.state == Audio.Playing
            audio.pause()
        } else {
            audio.position += _seekOffset
            _seekOffset = 0
            if (_resume) {
                _resume = false
                audio.play()
            }
            mprisPlayer.emitSeeked()
        }
    }

    onPositionChanged: if (!slider.pressed) slider.value = position / 1000

    MediaKey { enabled: player._grabKeys; key: Qt.Key_MediaTogglePlayPause; onPressed: player.toggle() }
    MediaKey { enabled: player._grabKeys; key: Qt.Key_MediaPlay; onPressed: player._play() }
    MediaKey { enabled: player._grabKeys; key: Qt.Key_MediaPause; onPressed: player.pause() }
    MediaKey { enabled: player._grabKeys; key: Qt.Key_MediaStop; onPressed: audio.stop() }
    MediaKey { enabled: player._grabKeys; key: Qt.Key_MediaNext; onPressed: audio.playNext() }
    MediaKey { enabled: player._grabKeys; key: Qt.Key_MediaPrevious; onPressed: audio.playPrevious() }
    MediaKey { enabled: player._grabKeys; key: Qt.Key_ToggleCallHangup; onPressed: player.toggle() }

    MediaKey {
        id: forwardKey

        enabled: player._grabKeys
        key: Qt.Key_AudioForward
        onPressed: player.seekForward(5000)
        onRepeat: player.seekForward(1000)
        onReleased: nextTimer.stop()
    }
    Timer { id: nextTimer; interval: 500; onTriggered: audio.playNext() }

    MediaKey {
        id: rewindKey

        enabled: player._grabKeys
        key: Qt.Key_AudioRewind
        onPressed: player.seekBackward(5000)
        onRepeat: player.seekBackward(1000)
        onReleased: previousTimer.stop()
    }
    Timer { id: previousTimer; interval: 500; onTriggered: audio.playPrevious() }

    Permissions {
        enabled: player.active
        applicationClass: "player"

        Resource {
            id: keysResource
            type: Resource.HeadsetButtons
            optional: true
        }
    }

    Audio {
        id: audio
        onEndOfMedia: audio.playNext()
        model.currentIndex: audio.model.currentIndex
        model.onShuffledChanged: shuffleSwitch.checked = model.shuffled

        model.onCurrentIndexChanged: {
            if (model.currentIndex == -1) {
                audio.model.currentIndex = -1
            }
        }

        onCurrentItemChanged: {
            player._seekOffset = 0

            var metadata
            if (currentItem) {
                metadata = {
                    'url'       : currentItem.url,
                    'title'     : currentItem.title,
                    'artist'    : currentItem.author,
                    'album'     : currentItem.album,
                    'genre'     : "",
                    'track'     : model.currentIndex,
                    'trackCount': model.count,
                    'duration'  : currentItem.duration * 1000
                }
            }
            bluetoothMediaPlayer.metadata = metadata
            mprisPlayer.localMetadata = metadata
        }

        onStateChanged: {
            if (state == Audio.Playing && !player._resume) {
                player.open = true
            } else if (state == Audio.Stopped) {
                player._resume = false
            }
        }
        function playNext() {
            var index = model.currentIndex + 1
            if (index >= model.count) {
                if (!repeatSwitch.checked) {
                    return
                }
                index = 0
            }

            model.currentIndex = index
            play()
        }

        function playPrevious() {
            var position = audio.position

            // We play previous if less than 5 seconds have elapsed.
            // otherwise we rewind the playing song
            if (position >= 5000) {
                audio.position = 0
                mprisPlayer.emitSeeked()
                return
            }

            var index = model.currentIndex - 1
            if (index < 0) {
                return
            }

            model.currentIndex = index
            play()
        }

        function setShuffle(shuffle) {
            model.shuffled = shuffle
        }
    }

    BluetoothMediaPlayer {
        id: bluetoothMediaPlayer

        status: {
            if (audio.state == Audio.Playing) {
                return BluetoothMediaPlayer.Playing
            } else if (audio.state == Audio.Stopped) {
                return BluetoothMediaPlayer.Stopped
            } else if (rewindKey.pressed) {
                return BluetoothMediaPlayer.ReverseSeek
            } else if (forwardKey.pressed) {
                return BluetoothMediaPlayer.ForwardSeek
            } else {
                return BluetoothMediaPlayer.Paused
            }
        }

        repeat: repeatSwitch.checked
                    ? BluetoothMediaPlayer.RepeatAllTracks
                    : BluetoothMediaPlayer.RepeatOff

        shuffle: shuffleSwitch.checked
                    ? BluetoothMediaPlayer.ShuffleAllTracks
                    : BluetoothMediaPlayer.ShuffleOff

        position: audio.position

        onChangeRepeat: {
            if (repeat == BluetoothMediaPlayer.RepeatOff) {
                repeatSwitch.checked = false
            } else if (repeat == BluetoothMediaPlayer.RepeatAllTracks) {
                repeatSwitch.checked = true
            }
        }

        onChangeShuffle: {
            if (shuffle == BluetoothMediaPlayer.ShuffleOff) {
                shuffleSwitch.checked = false
            } else if (shuffle == BluetoothMediaPlayer.ShuffleAllTracks) {
                shuffleSwitch.checked = true
            }
        }
    }

    MprisPlayer {
        id: mprisPlayer

        property var localMetadata

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
            if ((audio.model.currentIndex + 1 >= audio.model.count) && (loopStatus != MprisPlayer.Playlist)) return false
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
        canPause: currentItem
        canPlay: currentItem
        canSeek: currentItem

        loopStatus: repeatSwitch.checked ? MprisPlayer.Playlist : MprisPlayer.None
        playbackStatus: {
            if (audio.state == Audio.Playing) {
                return MprisPlayer.Playing
            } else if (audio.state == Audio.Stopped) {
                return MprisPlayer.Stopped
            } else {
                return MprisPlayer.Paused
            }
        }
        position: audio.position * 1000
        shuffle: shuffleSwitch.checked
        volume: 1

        onPauseRequested: player.pause()
        onPlayRequested: player._play()
        onPlayPauseRequested: player.toggle()
        onStopRequested: audio.stop()

        // This will start playback in any case. Mpris says to keep
        // paused/stopped if we were before but I suppose this is just
        // our general behavior decision here.
        onNextRequested: audio.playNext()
        onPreviousRequested: audio.playPrevious()

        onSeekRequested: {
            var position = audio.position + (offset / 1000)
            audio.position = position < 0 ? 0 : position
            emitSeeked()
        }
        onSetPositionRequested: {
            audio.position = position / 1000
            emitSeeked()
        }
        onOpenUriRequested: playUrl(url)

        onLoopStatusRequested: {
            if (loopStatus == MprisPlayer.None) {
                repeatSwitch.checked = false
            } else if (loopStatus == MprisPlayer.Playlist) {
                repeatSwitch.checked = true
            }
        }
        onShuffleRequested: shuffleSwitch.checked = shuffle

        onLocalMetadataChanged: {
            var metadata = {}

            if ('url' in localMetadata) {
                metadata[metadataToString(MprisPlayer.Url)] = localMetadata['url'] // Url

                // FIXME: Related to JB#13207. The "id" has to be an
                // unique identifier and it is not.
                metadata[metadataToString(MprisPlayer.TrackId)] = "/com/jolla/mediaplayer/" + Qt.md5(localMetadata['url'].toString()) // DBus object path
            }
            if ('duration' in localMetadata) metadata[metadataToString(MprisPlayer.Length)] = localMetadata['duration'] * 1000 // Microseconds
            if ('album' in localMetadata) metadata[metadataToString(MprisPlayer.Album)] = localMetadata['album'] // String
            if ('artist' in localMetadata) metadata[metadataToString(MprisPlayer.Artist)] = [localMetadata['artist']] // List of strings
            if ('genre' in localMetadata) metadata[metadataToString(MprisPlayer.Genre)] = [localMetadata['genre']] // List of strings
            if ('title' in localMetadata) metadata[metadataToString(MprisPlayer.Title)] = localMetadata['title'] // String
            if ('track' in localMetadata) metadata[metadataToString(MprisPlayer.TrackNumber)] = localMetadata['track'] // Int

            mprisPlayer.metadata = metadata
        }
    }

    Column {
        id: column

        width: parent.width
        y: Theme.paddingMedium
        spacing: Theme.paddingLarge

        Slider {
            id: slider

            property string author: currentItem ? currentItem.author : ""
            property string title: currentItem ? currentItem.title : ""

            width: parent.width
            handleVisible: false
            valueText: Format.formatDuration(slider.value, slider.value >= 3600
                                             ? Format.DurationLong
                                             : Format.DurationShort)

            label: {
                if (author.length > 0) {
                    if (title.length > 0) {
                        return "%0 - %1".arg(author).arg(title)
                    } else {
                        return author
                    }
                } else if (title.length > 0) {
                    return title
                }
                return ""
            }

            minimumValue: 0
            maximumValue: audio.duration / 1000
            onReleased: {
                audio.position = value * 1000
                mprisPlayer.emitSeeked()
            }
        }
        Row {
            id: navigation
            width: parent.width

            IconButton {
                id: gotoPrevious
                width: parent.width / 3
                icon.source: "image://theme/icon-m-previous"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: audio.playPrevious()
            }

            IconButton {
                id: playPause
                width: parent.width / 3
                icon.source: audio.state == Audio.Playing ? "image://theme/icon-m-pause?" + Theme.highlightColor : "image://theme/icon-m-play"
                onClicked: audio.toggle()
            }

            IconButton {
                id: gotoNext
                width: parent.width / 3
                icon.source: "image://theme/icon-m-next"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: audio.playNext()
            }
        }
    }

    PushUpMenu {
        id: bottomMenu

        Row {
            id: row
            width: parent.width

            property real childWidth: width / (showAddToPlaylistButton ? 3 : 2)

            Behavior on childWidth {
                NumberAnimation { duration: 250 }
            }

            IconButton {
                id: addToPlaylistButton
                width: row.childWidth
                anchors.bottom: parent.bottom
                anchors.bottomMargin: -Theme.paddingSmall
                icon.source: "image://theme/icon-m-add"
                opacity: showAddToPlaylistButton ? 1.0 : 0
                visible: opacity != 0

                Behavior on opacity { FadeAnimation {} }

                onClicked: {
                    bottomMenu.hide()
                    pageStack.push(Qt.resolvedUrl("AddToPlaylistPage.qml"), {media: audio.currentItem})
                }
            }

            /*
            TODO: Implement sharing
            IconButton {
                width: row.childWidth
                anchors.bottom: parent.bottom
                icon.source: "image://theme/icon-l-share"
            }
            */

            Switch {
                id: shuffleSwitch
                width: row.childWidth
                anchors.bottom: parent.bottom
                icon.source: "image://theme/icon-m-shuffle"
                onCheckedChanged: audio.setShuffle(checked)
            }

            Switch {
                id: repeatSwitch
                width: row.childWidth
                anchors.bottom: parent.bottom
                icon.source: "image://theme/icon-m-repeat"
            }
        }
    }
}
