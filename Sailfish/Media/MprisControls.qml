import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: mprisPlayerControls

    property bool isPlaying
    property alias artistAndSongText: artistAndSong.artistAndSongText
    property bool nextEnabled
    property bool previousEnabled
    property bool playEnabled
    property bool pauseEnabled

    readonly property real _squareSize: parent ? 0.25 * parent.width : 0

    signal playPauseRequested ()
    signal nextRequested ()
    signal previousRequested ()

    width: playerButtons.width
    height: playerButtons.height + (2 * Theme.itemSizeLarge) - Theme.itemSizeExtraSmall
    anchors.centerIn: parent

    drag.target: dummyDragItem
    drag.axis: Drag.XAxis
    drag.minimumX: nextEnabled ? -_squareSize : 0
    drag.maximumX: previousEnabled ? _squareSize : 0
    drag.filterChildren: true

    onReleased: if (drag.active) {
        if (dummyDragItem.x == _squareSize) {
            mprisPlayerControls.previousRequested()
        } else if (dummyDragItem.x == -_squareSize) {
            mprisPlayerControls.nextRequested()
        }

        dummyDragItem.x = 0
    }
    onCanceled: if (drag.active) dummyDragItem.x = 0

    Item {
        id: dummyDragItem

        visible: false
    }

    Column {
        id: artistAndSong

        property var artistAndSongText: { "artist": "", "song": "" }

        anchors {
            left: parent.left
            right: parent.right
        }

        onArtistAndSongTextChanged: {
            if (artistAndSongFadeAnimation.running) {
                artistAndSongFadeAnimation.complete()
            }
            artistAndSongFadeAnimation.artist = artistAndSongText.artist
            artistAndSongFadeAnimation.song = artistAndSongText.song
            artistAndSongFadeAnimation.running = true
        }

        SequentialAnimation {
            id: artistAndSongFadeAnimation

            property string artist
            property string song

            FadeAnimation { target: artistAndSong; properties: "opacity"; to: 0.0 }
            ScriptAction { script: { artistLabel.text = artistAndSongFadeAnimation.artist; songLabel.text = artistAndSongFadeAnimation.song } }
            FadeAnimation { target: artistAndSong; properties: "opacity"; to: 1.0 }
        }

        Text {
            id: artistLabel

            width: parent.width
            font.pixelSize: Theme.fontSizeHuge
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            maximumLineCount: 1
        }

        Text {
            id: songLabel

            width: parent.width
            font.pixelSize: Theme.fontSizeMedium
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            color: Theme.highlightColor
            maximumLineCount: 1
        }
    }

    MouseArea {
        anchors.fill: parent

        enabled: mprisPlayerControls.isPlaying ? mprisPlayerControls.pauseEnabled : mprisPlayerControls.playEnabled

        onClicked: mprisPlayerControls.playPauseRequested()
    }

    Row {
        id: playerButtons

        anchors.bottom: parent.bottom

        IconButton {
            enabled: mprisPlayerControls.previousEnabled
            opacity: enabled ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
            width: mprisPlayerControls._squareSize
            height: width
            icon.source: "image://theme/icon-cover-next-song"
            icon.mirror: true
            icon.width: Theme.iconSizeSmall
            icon.height: icon.width

            onClicked: mprisPlayerControls.previousRequested()
        }
        IconButton {
            id: playPauseButton

            property string iconSource: {
                if (!enabled) return ""
                return mprisPlayerControls.isPlaying ? "image://theme/icon-cover-pause" : "image://theme/icon-cover-play"
            }

            enabled: mprisPlayerControls.isPlaying ? mprisPlayerControls.pauseEnabled : mprisPlayerControls.playEnabled
            width: mprisPlayerControls._squareSize
            height: width
            icon.width: Theme.iconSizeSmall
            icon.height: icon.width

            onClicked: mprisPlayerControls.playPauseRequested()
            onIconSourceChanged: {
                if (playPauseButtonFadeAnimation.running) {
                    playPauseButtonFadeAnimation.complete()
                }
                playPauseButtonFadeAnimation.animationIcon = iconSource
                playPauseButtonFadeAnimation.running = true
            }

            function _setIcon (source) {
                icon.source = source
            }

            SequentialAnimation {
                id: playPauseButtonFadeAnimation

                property string animationIcon

                FadeAnimation { target: playPauseButton; properties: "opacity"; to: 0.0; }
                ScriptAction { script: playPauseButton._setIcon(playPauseButtonFadeAnimation.animationIcon) }
                FadeAnimation { target: playPauseButton; properties: "opacity"; to: 1.0; }
            }
        }
        IconButton {
            enabled: mprisPlayerControls.nextEnabled
            opacity: enabled ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
            width: mprisPlayerControls._squareSize
            height: width
            icon.source: "image://theme/icon-cover-next-song"
            icon.width: Theme.iconSizeSmall
            icon.height: icon.width

            onClicked: mprisPlayerControls.nextRequested()
        }
    }
}
