import QtQuick 2.6
import Sailfish.Silica 1.0
import QtMultimedia 5.0

VideoOutput {
    id: output

    property GalleryMediaPlayer player

    source: player
    visible: player && player.playbackState !== MediaPlayer.StoppedState

    BusyIndicator {
        id: busyIndicator
        z: 1
        anchors.centerIn: parent
        size: BusyIndicatorSize.Large
        opacity: 1.0
        visible: running
        parent: output.parent
        running: player && player.busy
    }
}
