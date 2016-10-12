import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: mprisControls

    property bool isPlaying
    property alias artistAndSongText: artistAndSong.artistAndSongText
    property bool nextEnabled
    property bool previousEnabled
    property bool playEnabled
    property bool pauseEnabled
    property color textColor: Theme.primaryColor
    property real buttonSize: Theme.iconSizeLarge

    readonly property real _squareSize: Math.min(buttonSize, width / 3)

    signal playPauseRequested()
    signal nextRequested()
    signal previousRequested()

    height: artistAndSong.height + playerButtons.height

    MouseArea {
        id: artistSongArea

        width: Math.min(parent.width,
                        Math.max(songLabel.implicitWidth, artistLabel.implicitWidth) + 2*Theme.paddingLarge)
        height: artistAndSong.height
        anchors.horizontalCenter: artistAndSong.horizontalCenter
        enabled: mprisControls.isPlaying ? mprisControls.pauseEnabled : mprisControls.playEnabled
        onClicked: mprisControls.playPauseRequested()
    }

    Column {
        id: artistAndSong

        property var artistAndSongText: { "artist": "", "song": "" }

        width: parent.width

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

        Label {
            id: songLabel

            width: parent.width
            font.pixelSize: Theme.fontSizeMedium
            truncationMode: TruncationMode.Fade
            horizontalAlignment: implicitWidth > width ? Text.AlignHLeft : Text.AlignHCenter
            color: artistSongArea.pressed ? Theme.highlightColor : mprisControls.textColor
            maximumLineCount: 1
        }

        Label {
            id: artistLabel

            width: parent.width
            font.pixelSize: Theme.fontSizeMedium
            truncationMode: TruncationMode.Fade
            horizontalAlignment: implicitWidth > width ? Text.AlignHLeft : Text.AlignHCenter
            color: songLabel.color
            maximumLineCount: 1
        }
    }

    Row {
        id: playerButtons

        spacing: mprisControls.width / 3 - mprisControls._squareSize
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: artistAndSong.bottom

        IconButton {
            enabled: mprisControls.previousEnabled
            opacity: enabled ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
            width: mprisControls._squareSize
            height: width
            icon.source: "image://theme/icon-m-previous"

            onClicked: mprisControls.previousRequested()
        }

        IconButton {
            id: playPauseButton

            property string iconSource: enabled ? (mprisControls.isPlaying ? "image://theme/icon-m-pause"
                                                                           : "image://theme/icon-m-play")
                                                : ""

            enabled: mprisControls.isPlaying ? mprisControls.pauseEnabled : mprisControls.playEnabled
            width: mprisControls._squareSize
            height: width

            onClicked: mprisControls.playPauseRequested()
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
            enabled: mprisControls.nextEnabled
            opacity: enabled ? 1.0 : 0.0
            Behavior on opacity { FadeAnimation {} }
            width: mprisControls._squareSize
            height: width
            icon.source: "image://theme/icon-m-next"

            onClicked: mprisControls.nextRequested()
        }
    }
}
