/****************************************************************************************
**
** Copyright (C) 2018 - 2020 Jolla Ltd.
** Copyright (c) 2019 - 2020 Open Mobile Platform LLC.
** Contact: Joona Petrell <joona.petrell@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**       notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**       notice, this list of conditions and the following disclaimer in the
**       documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**       names of its contributors may be used to endorse or promote products
**       derived from this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
** ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
** WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
** DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
** ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
** (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
** LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
** ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
****************************************************************************************/

import QtQuick 2.6
import Sailfish.Silica.private 1.0
import Sailfish.Silica 1.0

BackgroundItem {
    id: root

    signal swipedAway
    property bool draggable: true

    readonly property bool swipeActive: drag.active || dismissAnimation.running
    readonly property bool showSwipeHint: down && (_longPress || drag.active || _triggeredWithGesture)
    property int swipeDistance: _page ? _page.width : width

    property bool _triggeredWithGesture
    property bool _longPress
    property Item _page

    function swipeAway() {
        dismissAnimation.dismiss(contentItem, _page ? _page.width : width)
    }

    onPressAndHold: if (draggable) _longPress = true
    onPressed: {
        _longPress = false
        drag.target = draggable ? contentItem : null
    }
    onVisibleChanged: if (!visible) dismissAnimation.reset()

    drag {
        minimumX: -drag.maximumX
        maximumX: swipeDistance
        axis: Drag.XAxis
        onActiveChanged: {
            if (!drag.active) {
                _triggeredWithGesture = dismissAnimation.animate(contentItem, 0, swipeDistance)
            }
        }
    }

    highlighted: down && !showSwipeHint

    contentItem.transform: Translate {
        // wiggle the banner when pressed to hint it can be swiped away
        GestureHintAnimation on x {
            id: swipeHint
            running: root.down && root._longPress && !root.drag.active
        }
    }

    DismissAnimation {
        id: dismissAnimation
        onCompleted: {
            root.swipedAway()
            _triggeredWithGesture = false
        }
    }
}
