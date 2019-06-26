// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

MediaPlayerControlsPanel {
    id: panel

    property int state
    property Page addToPlaylistPage
    property alias author: authorLabel.text
    property alias title: titleLabel.text

    visible: root.applicationActive
    playing: state == Audio.Playing
    repeat: AudioPlayer.repeat ? (AudioPlayer.repeatOne ? MediaPlayerControls.RepeatTrack : MediaPlayerControls.RepeatPlaylist)
                               : MediaPlayerControls.NoRepeat
    shuffle: AudioPlayer.shuffle ? MediaPlayerControls.ShuffleTracks
                                 : MediaPlayerControls.NoShuffle
    showAddToPlaylist: addToPlaylistPage == null
    forwardEnabled: AudioPlayer.playModel.count > 1 // there needs to be something to forward to

    onPreviousClicked: AudioPlayer.playPrevious(true)
    onPlayPauseClicked: AudioPlayer.playPause()
    onNextClicked: AudioPlayer.playNext(true)

    onRepeatClicked: {
        if (AudioPlayer.repeat && !AudioPlayer.repeatOne) {
            AudioPlayer.repeatOne = true
        } else {
            AudioPlayer.repeat = !AudioPlayer.repeat
        }
    }
    onShuffleClicked: AudioPlayer.shuffle = !AudioPlayer.shuffle
    onAddToPlaylist: {
        hideMenu()
        var obj = pageStack.animatorPush(Qt.resolvedUrl("AddToPlaylistPage.qml"), { media: AudioPlayer.currentItem })
        obj.pageCompleted.connect(function(page) {
            addToPlaylistPage = page
        })
    }

    onOpenChanged: if (!open) AudioPlayer.pause()
    onSliderReleased: AudioPlayer.setPosition(value * 1000)

    Column {
        parent: extraContentItem
        width: panel.width

        Label {
            id: titleLabel

            width: Math.min(parent.width - 2*Theme.paddingMedium, implicitWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.primaryColor
            truncationMode: TruncationMode.Fade
            visible: text.length > 0
        }
        Label {
            id: authorLabel

            width: Math.min(parent.width - 2*Theme.paddingMedium, implicitWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            truncationMode: TruncationMode.Fade
            visible: text.length > 0
        }
    }
}
