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
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Theme.horizontalPageMargin

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
    property int _seconds: (_timeout + 999) / 1000
    property int _secsRemaining: (_msRemaining + 999) / 1000
    property real _msRemaining: _timeout
    property Item _item
    property Item _page
    property bool _triggered
    property real _contentOpacity

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
            PropertyChanges {
                target: remorseItem
                anchors.fill: _item
                opacity: 1
                visible: true
                _contentOpacity: 1
            }
            PropertyChanges {
                target: _item
                opacity: 0
            }
        },
        State {
            name: "activePending"
            extend: "active"
            PropertyChanges {
                target: remorseItem
                opacity: 0
            }
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
                ParallelAnimation {
                    FadeAnimation {
                        target: remorseItem
                        duration: 200
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 150 }
                        PropertyAnimation {
                            target: remorseItem
                            property: "_contentOpacity"
                            duration: 150
                        }
                    }
                }
            }
        },
        Transition {
            to: ""
            SequentialAnimation {
                FadeAnimation {
                    target: remorseItem
                    duration: 200
                }
                PropertyAction { target: remorseItem; property: "visible" }
                ScriptAction { script: { RemorseItem.remorseItemDeactivated(remorseItem) } }
                FadeAnimation {
                    target: _item
                    duration: 100
                }
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

    Row {
        id: row

        property real cellWidth: (parent.width - ((repeater.count - 1) * spacing)) / repeater.count

        height: parent.height
        spacing: 1

        Repeater {
            id: repeater

            model: _seconds

            Rectangle {
                width: row.cellWidth
                height: parent ? parent.height : 0
                color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                opacity: remorseItem._secsRemaining > Positioner.index ? 0.7 : 0
                Behavior on opacity {
                    FadeAnimation { duration: 200 }
                }
            }
        }
    }
    Column {
        anchors {
            left: parent.left
            right: parent.right
            topMargin: Theme.paddingLarge
            bottomMargin: Theme.paddingLarge
            leftMargin: remorseItem.leftMargin
            rightMargin: remorseItem.rightMargin
            verticalCenter: parent.verticalCenter
        }
        Label {
            id: titleLabel
            //% "in %n seconds"
            text: remorseItem.text + " " + qsTrId("components-la-in-n-seconds", remorseItem._secsRemaining)
            width: parent.width
            color: remorseItem.down ? Theme.highlightColor : Theme.primaryColor
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
