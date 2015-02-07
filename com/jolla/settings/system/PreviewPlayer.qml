import QtQuick 2.0
import QtMultimedia 5.0

Audio {
    id: previewPlayer

    property string title

    function toggle(source) {
        if (playbackState == Audio.PlayingState || source == "") {
            stop()
        } else {
            play()
        }
    }

    onStatusChanged: {
        if (status == Audio.Loaded) {
            title = metaData.title ? metaData.title : ""
        }
    }
}
