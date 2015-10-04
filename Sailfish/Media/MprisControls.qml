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
    property color textColor: Theme.primaryColor
    property real buttonSize: Theme.iconSizeLarge

    readonly property real _squareSize: width > 3 * buttonSize ? buttonSize : width / 3

    signal playPauseRequested ()
    signal nextRequested ()
    signal previousRequested ()

    height: mainColumn.height

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

    MouseArea {
        anchors {
            left: parent.left
            right: parent.right
            top: mainColumn.top
            bottom: mainColumn.bottom
        }
    }

    Column {
        id: mainColumn

        anchors {
            left: parent.left
            right: parent.right
        }

        MouseArea {
            anchors {
                left: parent.left
                right: parent.right
            }
            height: artistAndSong.height
            enabled: mprisPlayerControls.isPlaying ? mprisPlayerControls.pauseEnabled : mprisPlayerControls.playEnabled

            onPressed: songLabel.color = Theme.highlightColor
            onReleased: songLabel.color = mprisPlayerControls.textColor
            onCanceled: songLabel.color = mprisPlayerControls.textColor
            onClicked: mprisPlayerControls.playPauseRequested()

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

                Label {
                    id: songLabel

                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Fade
                    horizontalAlignment: contentWidth > Math.ceil(width) ? Text.AlignHLeft : Text.AlignHCenter
                    color: mprisPlayerControls.textColor
                    maximumLineCount: 1
                }

                Label {
                    id: artistLabel

                    width: parent.width
                    font.pixelSize: Theme.fontSizeMedium
                    truncationMode: TruncationMode.Fade
                    horizontalAlignment: contentWidth > Math.ceil(width) ? Text.AlignHLeft : Text.AlignHCenter
                    color: songLabel.color
                    maximumLineCount: 1
                }
            }
        }

        Row {
            id: playerButtons

            spacing: mprisPlayerControls.width / 3 - mprisPlayerControls._squareSize
            anchors.horizontalCenter: parent.horizontalCenter

            IconButton {
                anchors.leftMargin: 0.5 * playerButtons.spacing
                enabled: mprisPlayerControls.previousEnabled
                opacity: enabled ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation {} }
                width: mprisPlayerControls._squareSize
                height: width
                icon.source: "image://theme/icon-m-previous"

                onClicked: mprisPlayerControls.previousRequested()
            }

            IconButton {
                id: playPauseButton

                property string iconSource: {
                    if (!enabled) return ""
                    return mprisPlayerControls.isPlaying ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
                }

                enabled: mprisPlayerControls.isPlaying ? mprisPlayerControls.pauseEnabled : mprisPlayerControls.playEnabled
                width: mprisPlayerControls._squareSize
                height: width

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
                icon.source: "image://theme/icon-m-next"

                onClicked: mprisPlayerControls.nextRequested()
            }
        }
    }
}
