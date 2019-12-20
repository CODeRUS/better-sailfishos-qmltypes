/****************************************************************************************
**
** Copyright (C) 2018 Jolla Ltd.
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
import "Util.js" as Util

Rectangle {
    id: root
    property alias wallpaperHidden: binding.when
    property bool fullscreen: page && page.status === PageStatus.Active && !pageStack.dragInProgress && !pageStack._snapBackAnimation.running
    property Page page: Util.findPage(root)

    onFullscreenChanged: {
        if (fullscreen) {
            wallpaperHidden = true
            delayedHide.restart()
        } else {
            visible = true
            delayedHide.restart()
        }
    }

    z: -1
    anchors.fill: parent
    color: "black"

    // hide asynchronously
    Timer {
        id: delayedHide
        interval: 1
        onTriggered: {
            if (fullscreen) {
                visible = false
            } else {
                wallpaperHidden = false
            }
        }
    }

    Binding {
        id: binding
        when: false
        target: __silica_applicationwindow_instance
        property: "_backgroundVisible"
        value: false
    }

    Binding {
        when: fullscreen
        target: __silica_applicationwindow_instance.__quickWindow
        property: "color"
        value: Qt.application.active ? color : "transparent"
    }
}
