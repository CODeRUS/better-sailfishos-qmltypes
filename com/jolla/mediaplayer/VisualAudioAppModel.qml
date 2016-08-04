// -*- qml -*-

import QtQuick 2.0
import com.jolla.mediaplayer 1.0

VisualAudioModel {
    id: visualAudioAppModel

    readonly property alias playing: visualAudioAppModel._playing
    readonly property alias repeat: visualAudioAppModel._repeat
    readonly property alias shuffle: visualAudioAppModel._shuffle

    property bool _playing
    property bool _repeat
    property bool _shuffle

    function appModelUpdate() {
        modelUpdate()
        if (modelActive) {
            _playing = Qt.binding(function () { return AudioPlayer.playing })
            _repeat = Qt.binding(function () { return AudioPlayer.repeat })
            _shuffle = Qt.binding(function () { return AudioPlayer.shuffle })
        } else {
            _playing = _playing
            _repeat = _repeat
            _shuffle = _shuffle
        }
    }

    onModelActiveChanged: appModelUpdate()
    Component.onCompleted: appModelUpdate()
}
