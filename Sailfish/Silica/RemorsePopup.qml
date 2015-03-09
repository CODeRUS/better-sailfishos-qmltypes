/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Martin Jones <martin.jones@jollamobile.com>
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

import QtQuick 2.0
import Sailfish.Silica 1.0
import "private/RemorsePopup.js" as Remorse
import "private/Util.js" as Util

BackgroundItem {
    id: remorsePopup
    property string text

    function execute(title, callback, timeout) {
        remorsePopup.text = title
        Remorse.callback = callback
        _timeout = timeout === undefined ? 5000 : timeout
        _triggered = false
        _page = Util.findPage(remorsePopup)
        if (_page) {
            parent = _page
        }
        countdown.restart()
        state = "active"
    }
    function cancel() {
        _close()
        canceled()
    }

    function _close() {
        countdown.stop()
        state = ""
    }
    function _execute() {
        if (!_triggered) {
            _triggered = true
            triggered()
            if (Remorse.callback !== undefined) {
                Remorse.callback.call()
            }
        }
    }

    property int _timeout: 5000
    property int _secsRemaining: Math.ceil(_msRemaining/1000).toFixed(0)
    property real _msRemaining: _timeout
    property Item _page
    property bool _triggered

    signal canceled
    signal triggered

    opacity: 0.0
    visible: false
    width: parent ? parent.width : Screen.width
    height: Theme.itemSizeSmall
    z: 1

    onClicked: cancel()

    states: State {
        name: "active"
        PropertyChanges { target: _page; showNavigationIndicator: false }
        PropertyChanges { target: remorsePopup; opacity: 1.0; visible: true }
    }
    transitions: [
        Transition {
            to: "active"
            SequentialAnimation {
                PropertyAction { properties: "showNavigationIndicator" }
                PropertyAction { properties: "visible" }
                FadeAnimation {}
            }
        },
        Transition {
            SequentialAnimation {
                FadeAnimation {}
                PropertyAction { properties: "visible" }
                PropertyAction { properties: "showNavigationIndicator" }
            }
        }
    ]

    Connections {
        target: _page
        onStatusChanged: {
            if (_page && _page.status == PageStatus.Deactivating && countdown.running) {
                // if the page is changed then execute immediately
                _execute()
                _close()
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightBackgroundColor
    }
    Rectangle {
        anchors.right: parent.right
        height: parent.height
        width: parent.width - (parent.width * _msRemaining / _timeout)
        color: "black"
        opacity: 0.2
    }
    Rectangle {
        anchors.fill: parent
        color: Theme.highlightDimmerColor
        opacity: highlighted ? 0.2 : 0.0
    }

    Image {
        anchors.top: parent.bottom
        width: parent.width
        source: "image://theme/graphic-system-gradient?" + Theme.highlightBackgroundColor
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0.7
        Label {
            id: titleLabel
            //% "in %n seconds"
            text: remorsePopup.text + " " + qsTrId("components-la-in-n-seconds", remorsePopup._secsRemaining)
            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeMedium
            color: "black"
            truncationMode: TruncationMode.Fade
        }
        Label {
            //% "Tap to cancel"
            text: qsTrId("components-la-tap-to-cancel")
            color: "black"
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    NumberAnimation {
        id: countdown
        target: remorsePopup
        property: "_msRemaining"
        from: _timeout
        to: 0
        duration: _timeout
        onRunningChanged: {
            if (!running && _msRemaining == 0) {
                _execute()
                _close()
            }
        }
    }

    Component.onDestruction: {
        if (countdown.running) {
            _execute()
        }
    }
}
