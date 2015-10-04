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
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Theme.horizontalPageMargin

    function execute(title, callback, timeout) {
        remorsePopup.text = title
        Remorse.callback = callback
        _timeout = timeout === undefined ? 5000 : timeout
        _triggered = false
        _page = Util.findPage(remorsePopup)
        if (_page) {
            parent = _page
        }
        state = "active"
    }
    function cancel() {
        _close()
        canceled()
    }

    function _close() {
        countdown.stop()
        state = "inactive"
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
    property int _seconds: (_timeout + 999) / 1000
    property int _secsRemaining: (_msRemaining + 999) / 1000
    property real _msRemaining: _timeout
    property Item _page
    property bool _triggered
    property real _contentOpacity

    signal canceled
    signal triggered

    visible: false
    width: parent ? parent.width : Screen.width
    height: Theme.itemSizeSmall + Theme.paddingSmall
    y: -height
    z: 1
    _screenMargin: 0

    onClicked: cancel()

    states: [
        State {
            name: "active"
            PropertyChanges {
                target: _page
                showNavigationIndicator: false
            }
            PropertyChanges {
                target: remorsePopup
                visible: true
                y: 0
                _contentOpacity: 1
            }
        }, State {
            name: "inactive"
            PropertyChanges {
                target: _page
                showNavigationIndicator: false
            }
            PropertyChanges {
                target: remorsePopup
                visible: true
                _contentOpacity: 1
            }
        }
    ]
    transitions: [
        Transition {
            to: "active"
            SequentialAnimation {
                PropertyAction { properties: "showNavigationIndicator" }
                PropertyAction { properties: "visible" }
                ParallelAnimation {
                    PropertyAnimation {
                        target: remorsePopup
                        property: "y"
                        duration: 200
                        easing.type: Easing.OutQuad
                    }
                    SequentialAnimation {
                        PauseAnimation { duration: 150 }
                        PropertyAnimation {
                            target: remorsePopup
                            property: "_contentOpacity"
                            duration: 150
                        }
                    }
                    ScriptAction {
                        script: countdown.restart()
                    }
                }
            }
        },
        Transition {
            to: "inactive"
            SequentialAnimation {
                PropertyAnimation {
                    target: remorsePopup
                    property: "y"
                    duration: 200
                    easing.type: Easing.OutQuad
                }
                ScriptAction {
                    script: remorsePopup.state = ""
                }
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
        color: Qt.rgba(0, 0, 0, 0.6)
    }

    Row {
        id: row

        property real cellWidth: (parent.width - ((repeater.count - 1) * spacing)) / repeater.count

        height: Theme.paddingSmall
        spacing: 1

        Repeater {
            id: repeater

            model: _seconds

            Rectangle {
                width: row.cellWidth
                height: parent ? parent.height : 0
                color: Theme.highlightBackgroundColor
                opacity: remorsePopup._secsRemaining > Positioner.index ? 0.6 : 0
                Behavior on opacity {
                    FadeAnimation { duration: 200 }
                }
            }
        }
    }
    Image {
        id: promptIcon

        anchors {
            verticalCenter: parent.verticalCenter
            verticalCenterOffset: row.height/2
            left: row.left
            leftMargin: Theme.paddingMedium
        }
        source: "image://theme/icon-m-clear" + (remorsePopup.highlighted ? "?" + Theme.highlightColor : "")
        smooth: true
        fillMode: Image.PreserveAspectFit
        opacity: remorsePopup._contentOpacity
    }
    Column {
        anchors {
            verticalCenter: promptIcon.verticalCenter
            left: promptIcon.right
            leftMargin: Theme.paddingMedium
            right: parent.right
        }
        Label {
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
            color: remorsePopup.highlighted ? Theme.highlightColor : Theme.primaryColor
            textFormat: Text.PlainText
            maximumLineCount: 1
            opacity: remorsePopup._contentOpacity
            //: Describes the remaining time to prevent action trigger
            //% "in %n seconds"
            text: remorsePopup.text + " " + qsTrId("components-la-in-n-seconds", remorsePopup._secsRemaining) +
                  //: Prompts the user to cancel the pending action, appended to the description
                  //% ", Tap to cancel"
                  (screen.sizeCategory > Screen.Medium ? qsTrId("components-la-tap-to-cancel-appended") : "")
        }
        Label {
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
            color: remorsePopup.highlighted ? Theme.highlightColor : Theme.primaryColor
            textFormat: Text.PlainText
            maximumLineCount: 1
            opacity: remorsePopup._contentOpacity
            //: Prompts the user to cancel the pending action
            //% "Tap to cancel"
            text: qsTrId("components-la-tap-to-cancel")
            visible: screen.sizeCategory <= Screen.Medium
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
