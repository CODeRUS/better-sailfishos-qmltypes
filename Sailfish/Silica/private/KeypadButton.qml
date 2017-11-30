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
import Sailfish.Silica.private 1.0

MouseArea {
    id: dialerButton

    property int key
    property string text
    property string secondaryText
    property bool down: pressed && containsMouse

    onClicked: dialer._buttonClicked(text)
    onPressed: {
        dialerButton.DragFilter.begin(mouse.x, mouse.y)
        dialer._buttonPressed(dialerButton, text)
    }
    onReleased: dialer._buttonReleased(text)
    onCanceled: {
        dialerButton.DragFilter.end()
        dialer._buttonCanceled(text)
    }

    onEntered: dialer._buttonEntered()
    onExited: dialer._buttonExited()

    width: dialer._buttonWidth
    height: dialer._buttonHeight

    preventStealing: down
    onPreventStealingChanged: if (preventStealing) dialerButton.DragFilter.end()

    Label {
        id: numberLabel
        anchors {
            centerIn: parent
            verticalCenterOffset: dialer.vanityDialNumbersVisible ? -((vanityLabel.font.pixelSize)/2) : 0
        }
        font.pixelSize: Theme.fontSizeExtraLarge
        color: dialerButton.down ? dialer.pressedTextColor : dialer.textColor
        text: dialerButton.text
    }

    Label {
        id: vanityLabel
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: numberLabel.bottom
            topMargin: -Theme.paddingSmall
        }
        font.pixelSize: Theme.fontSizeExtraSmall
        visible: dialer.vanityDialNumbersVisible
        opacity: 0.6

        color: dialerButton.down ? dialer.pressedTextColor : dialer.textColor
        text: dialerButton.secondaryText
    }
}
