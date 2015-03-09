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
import "private/RemorseItem.js" as RemorseItem
import "private/Util.js" as Util

BackgroundItem {
    id: remorseItem
    property string text
    property alias cancelText: cancelTextLabel.text
    property alias wrapMode: titleLabel.wrapMode
    property alias horizontalAlignment: titleLabel.horizontalAlignment
    property alias pending: countdown.running

    function execute(item, title, callback, timeout) {
        remorseItem.text = title
        Remorse.callback = callback
        _timeout = timeout === undefined ? 5000 : timeout
        _triggered = false
        parent = item.parent
        _item = item
        _page = Util.findPage(remorseItem)
        state = "active"
        countdown.restart()
        RemorseItem.remorseItemCancel(remorseItem)
        RemorseItem.remorseItemActivated(remorseItem)
    }
    function cancel() {
        _close()
        canceled()
        RemorseItem.remorseItemCancel(remorseItem)
    }
    function trigger() {
        if (countdown.running) {
            countdown.stop()
            return _execute(false)
        }
        return false
    }

    function _close() {
        countdown.stop()
        state = ""
    }
    function _execute(closeAfterExecute) {
        if (!_triggered) {
            _triggered = true
            RemorseItem.remorseItemTrigger(remorseItem, Remorse.callback, closeAfterExecute)
            return true
        }
        return false
    }

    property int _timeout: 5000
    property int _secsRemaining: Math.ceil(_msRemaining/1000).toFixed(0)
    property real _msRemaining: _timeout
    property Item _item
    property Item _page
    property bool _triggered

    signal canceled
    signal triggered

    opacity: 0.0
    visible: false
    width: parent ? parent.width : Screen.width
    height: Theme.itemSizeSmall
    z: 2

    onClicked: cancel()

    states: [
        State {
            name: "active"
            PropertyChanges { target: remorseItem; anchors.fill: _item; opacity: 1.0; visible: true }
            PropertyChanges { target: _item; opacity: 0.0 }
        },
        State {
            name: "activePending"
            extend: "active"
            PropertyChanges { target: remorseItem; opacity: 0.0 }
        },
        State {
            // Empty state to restore target item state without any transitions.
            name: "destroying"
        }
    ]

    transitions: [
        Transition {
            to: "active"
            SequentialAnimation {
                PropertyAction { target: remorseItem; properties: "anchors.fill,visible" }
                FadeAnimation {}
            }
        },
        Transition {
            to: ""
            SequentialAnimation {
                FadeAnimation {}
                PropertyAction { target: remorseItem; property: "visible" }
                ScriptAction { script: { RemorseItem.remorseItemDeactivated(remorseItem) } }
            }
        }
    ]

    Connections {
        target: _page
        onStatusChanged: {
            if (_page && _page.status == PageStatus.Deactivating && countdown.running) {
                // if the page is changed then execute immediately
                _execute(false)
            }
        }
    }

    Rectangle {
        id: progress
        width: parent.width * _msRemaining / _timeout
        height: parent.height
        color: Theme.highlightBackgroundColor
        opacity: 0.3
    }
    Rectangle {
        anchors.left: progress.right
        anchors.right: parent.right
        height: parent.height
        color: "black"
        opacity: 0.15
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: Theme.paddingLarge
        anchors.verticalCenter: parent.verticalCenter
        Label {
            id: titleLabel
            //% "in %n seconds"
            text: remorseItem.text + " " + qsTrId("components-la-in-n-seconds", remorseItem._secsRemaining)
            width: parent.width
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeSmall
            truncationMode: wrapMode != Text.NoWrap ? TruncationMode.None : TruncationMode.Fade
        }
        Label {
            id: cancelTextLabel
            //% "Tap to cancel"
            text: qsTrId("components-la-tap-to-cancel")
            width: parent.width
            color: remorseItem.down ? Theme.secondaryHighlightColor : Theme.secondaryColor
            font.pixelSize: Theme.fontSizeExtraSmall
            truncationMode: titleLabel.truncationMode
            horizontalAlignment: titleLabel.horizontalAlignment
        }
    }

    NumberAnimation {
        id: countdown
        target: remorseItem
        property: "_msRemaining"
        from: _timeout
        to: 0
        duration: _timeout
        onRunningChanged: {
            if (!running && _msRemaining == 0) {
                remorseItem.state = "activePending"
                _execute(true)
            }
        }
    }

    Component.onDestruction: {
        if (countdown.running) {
            _execute(false)
        }
        RemorseItem.remorseItemDeactivated(remorseItem)
        state = "destroying"
    }
}
