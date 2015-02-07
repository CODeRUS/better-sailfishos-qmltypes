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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "private/HintReferenceCounter.js" as HintReferenceCounter

Image {
    id: root

    property real startX: parent ? parent.width/2 - width/2 : 0
    property real startY: parent ? parent.height/2 - height/2 : 0
    property real distance: Screen.width/2
    property int direction: TouchInteraction.Right
    property alias running: animationGroup.running
    property alias alwaysRunToEnd: animationGroup.alwaysRunToEnd
    property alias loops: animationGroup.loops
    property bool _testMode

    function start() {
        animationGroup.start()
    }
    function restart() {
        animationGroup.restart()
    }
    function stop() {
        animationGroup.stop()
    }

    onRunningChanged: {
        if (running) {
            HintReferenceCounter.increase()
        } else {
            HintReferenceCounter.decrease()
            opacity = 0.0
        }
    }
    Component.onDestruction: if (running) HintReferenceCounter.decrease()

    opacity: 0.0
    source: "image://theme/graphic-gesture-hint"
    Behavior on opacity { FadeAnimation {} }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if (animationGroup.running) {
                if (Qt.application.active) {
                    animationGroup.resume()
                } else {
                    animationGroup.pause()
                }
            }
        }
    }
    SequentialAnimation {
        id: animationGroup

        loops: 3
        ScriptAction {
            script: {
                opacity = 1.0
                switch (direction) {
                case TouchInteraction.Up:
                case TouchInteraction.Down:
                    root.y = startY
                    break
                case TouchInteraction.Left:
                case TouchInteraction.Right:
                    root.x = startX
                    break
                default:
                    break
                }
            }
        }
        ParallelAnimation {
            SequentialAnimation {
                PauseAnimation { duration: _testMode ? 10 : 300 }
                NumberAnimation {
                    target: root
                    property: "opacity"
                    to: 0
                    easing.type: Easing.InCubic
                    duration: _testMode ? 10 : 500
                }
            }
            NumberAnimation {
                target: root
                property: direction === TouchInteraction.Up || direction === TouchInteraction.Down ? "y" : "x"
                to: {
                    switch (direction) {
                    case TouchInteraction.Up:
                        return startY - distance
                    case TouchInteraction.Down:
                        return startY + distance
                    case TouchInteraction.Left:
                        return startX - distance
                    case TouchInteraction.Right:
                        return startX + distance
                    default:
                        console.log("Invalid TouchInteraction.Direction value defined")
                        return 0
                    }
                }
                easing.type: Easing.InCubic
                duration: _testMode ? 20 : 800
            }
        }
        PauseAnimation { duration: _testMode ? 10 : 800 }
    }
}
