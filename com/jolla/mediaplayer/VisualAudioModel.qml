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

QtObject {
    id: visualAudioModel

    property bool modelActive

    readonly property alias metadata: visualAudioModel._metadata
    readonly property alias duration: visualAudioModel._duration
    readonly property alias state: visualAudioModel._state
    readonly property alias active: visualAudioModel._active
    readonly property alias position: visualAudioModel._position

    property var _metadata: {}
    property int _duration
    property int _state
    property bool _active
    property int _position

    function cloneMetadata(metadata) {
        if (metadata && 'url' in metadata) {
            return {
                'url'       : metadata.url,
                'title'     : metadata.title,
                'artist'    : metadata.artist,
                'album'     : metadata.album,
                'genre'     : metadata.genre,
                'track'     : metadata.track,
                'trackCount': metadata.trackCount,
                'duration'  : metadata.duration
            }
        }

        return {}
    }

    function modelUpdate() {
        if (modelActive) {
            _metadata = Qt.binding(function () { return cloneMetadata(AudioPlayer.metadata) })
            _duration = Qt.binding(function () { return AudioPlayer.duration })
            _state = Qt.binding(function () { return AudioPlayer.state })
            _active = Qt.binding(function () { return AudioPlayer.active })
            _position = Qt.binding(function () { return AudioPlayer.position })
        } else {
            _metadata = _metadata
            _duration = _duration
            _state = _state
            _active = _active
            _position = _position
        }
    }

    onModelActiveChanged: modelUpdate()
    Component.onCompleted: modelUpdate()
}
