/****************************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Andrew den Exter <andrew.den.exter@jollamobile.com>
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

BackgroundItem {
    id: button

    property color primaryColor: Theme.primaryColor
    property color highlightColor: Theme.highlightColor
    property color highlightBackgroundColor: Theme.highlightBackgroundColor
    property alias text: label.text
    property alias icon: iconButton.icon

    down: (pressed && containsMouse) || iconButton.down
    height: Theme.itemSizeMedium
    highlightedColor: Theme.rgba(highlightBackgroundColor, Theme.highlightBackgroundOpacity)

    Label {
        id: label

        anchors {
            left: parent.left
            right: iconButton.icon.status == Image.Ready ? iconButton.left : parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Theme.horizontalPageMargin
            rightMargin: iconButton.icon.status == Image.Ready ? Theme.paddingLarge : Theme.horizontalPageMargin
        }

        color: button.highlighted ? button.highlightColor : button.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        truncationMode: TruncationMode.Fade
        opacity: button.enabled ? 1.0 : 0.4
    }

    IconButton {
        id: iconButton

        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }

        enabled: button.enabled
        icon {
            highlighted: iconButton._showPress
            color: button.primaryColor
            highlightColor: button.highlightColor
        }

        highlighted: button.down
        onClicked: button.clicked(mouse)
    }
}
