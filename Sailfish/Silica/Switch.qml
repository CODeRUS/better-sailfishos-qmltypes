/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
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
import "private"

MouseArea {
    id: switchItem

    property bool checked
    property alias iconSource: image.source //XXX Deprecated
    property alias icon: image
    property bool down: pressed && containsMouse
    property bool highlighted: down
    property bool busy
    property bool automaticCheck: true

    onClicked: {
        if (automaticCheck) {
            checked = !checked
        }
    }

    width: column.width; height: column.height

    Column {
        id: column

        spacing: -28
        anchors.centerIn: parent
        GlassItem {
            id: indicator
            opacity: switchItem.enabled ? 1.0 : 0.4
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
            anchors.horizontalCenter: parent.horizontalCenter
            dimmed: !checked
            falloffRadius: checked ? defaultFalloffRadius : 0.075
            Behavior on falloffRadius {
                NumberAnimation { duration: busy ? 450 : 50; easing.type: Easing.InOutQuad }
            }
            // KLUDGE: Behavior and State don't play well together
            // http://qt-project.org/doc/qt-5/qtquick-statesanimations-behaviors.html
            // force re-evaluation of brightness when returning to default state
            brightness: { return 1.0 }
            Behavior on brightness {
                NumberAnimation { duration: busy ? 450 : 50; easing.type: Easing.InOutQuad }
            }
        }
        HighlightImage {
            id: image

            opacity: switchItem.enabled ? 1.0 : 0.4
            highlighted: switchItem.highlighted
            anchors.horizontalCenter: parent.horizontalCenter
        }
        states: State {
            when: switchItem.busy
            PropertyChanges { target: indicator; brightness: busyTimer.brightness; dimmed: false; falloffRadius: busyTimer.falloffRadius; opacity: 1.0 }
        }
        Timer {
            id: busyTimer
            property real brightness: 0.4
            property real falloffRadius: 0.075
            running: busy && Qt.application.active
            interval: 500
            repeat: true
            onRunningChanged: {
                brightness = checked ? 1.0 : 0.4
                falloffRadius = checked ? indicator.defaultFalloffRadius : 0.075
            }
            onTriggered: {
                falloffRadius = falloffRadius === 0.075 ? indicator.defaultFalloffRadius : 0.075
                brightness = brightness == 0.4 ? 1.0 : 0.4
            }
        }
    }

    // for testing
    function _indicator() {
        return indicator
    }
}
