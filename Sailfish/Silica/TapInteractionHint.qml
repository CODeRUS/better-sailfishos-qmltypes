/****************************************************************************************
**
** Copyright (C) 2014 Jolla Ltd.
** Contact: Joona Petrell <joona.petrell@jollamobile.com>
** All rights reserved.
**
** This file is part of Sailfish Silica UI component package.
**
** You may use this file under the terms of BSD license as follows:
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are met:
**     * Redistributions of source code must retain the above copyright
**	 notice, this list of conditions and the following disclaimer.
**     * Redistributions in binary form must reproduce the above copyright
**	 notice, this list of conditions and the following disclaimer in the
**	 documentation and/or other materials provided with the distribution.
**     * Neither the name of the Jolla Ltd nor the
**	 names of its contributors may be used to endorse or promote products
**	 derived from this software without specific prior written permission.
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

import QtQuick 2.2
import Sailfish.Silica 1.0

Image {
    id: root

    property alias running: animationGroup.running
    property alias loops: animationGroup.loops
    property alias taps: blinkAnimation.loops
    property color color: Theme.primaryColor

    source: "image://theme/graphic-gesture-hint?" + color
    opacity: 0.0

    function start() {
        animationGroup.start()
    }
    function restart() {
        animationGroup.restart()
    }
    function stop() {
        animationGroup.stop()
    }

    onRunningChanged: if (!running) opacity = 0.0

    SequentialAnimation {
        id: animationGroup
        running: true
        loops: Animation.Infinite
        SequentialAnimation {
            id: blinkAnimation
            OpacityAnimator {
                target: root
                from: 0.0
                to: 1.0
                duration: blinkAnimation.loops > 1 ? 100 : 300
            }
            PauseAnimation {
                duration: blinkAnimation.loops > 1 ? 100 : 400
            }
            OpacityAnimator {
                target: root
                from: 1.0
                to: 0.0
                duration: blinkAnimation.loops > 1 ? 300 : 700
            }
        }
        PauseAnimation {
            duration: 2000
        }
    }
}
