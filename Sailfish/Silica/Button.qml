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
import Sailfish.Silica.private 1.0

MouseArea {
    id: button

    property bool down: pressed && containsMouse && !DragFilter.canceled
    property alias text: buttonText.text
    property bool _showPress: down || pressTimer.running
    property color color: Theme.primaryColor
    property color highlightColor: Theme.highlightColor
    property color highlightBackgroundColor: Theme.highlightBackgroundColor
    property real preferredWidth: Theme.buttonWidthSmall
    property bool __silica_button

    onPressedChanged: {
        if (pressed) {
            pressTimer.start()
        }
    }
    onCanceled: {
        button.DragFilter.end()
        pressTimer.stop()
    }
    onPressed: button.DragFilter.begin(mouse.x, mouse.y)
    onPreventStealingChanged: if (preventStealing) button.DragFilter.end()

    height: Theme.itemSizeExtraSmall
    implicitWidth: Math.max(preferredWidth, buttonText.width+Theme.paddingLarge)

    Rectangle {
        anchors {
            fill: parent
            topMargin: (button.height-Theme.itemSizeExtraSmall)/2
            bottomMargin: anchors.topMargin
        }
        radius: Theme.paddingSmall
        color: _showPress ? Theme.rgba(button.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                          : Theme.rgba(button.color, 0.2)

        opacity: button.enabled ? 1.0 : 0.4

        Label {
            id: buttonText
            anchors.centerIn: parent
            color: _showPress ? button.highlightColor : button.color
        }
    }

    Timer {
        id: pressTimer
        interval: Theme.minimumPressHighlightTime
    }
}
