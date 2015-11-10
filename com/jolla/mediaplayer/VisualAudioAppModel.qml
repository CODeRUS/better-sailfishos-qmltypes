/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

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
