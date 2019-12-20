/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Martin Jones <martin.jones@jollamobile.com>
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
import Sailfish.Silica.private 1.0 as Private
import "private/Util.js" as Util
import "private"

Private.SilicaRectangle {
    id: verticalScrollDecorator

    property Flickable flickable
    property Item page

    property real _headerSpacing
    property real _topMenuSpacing: flickable.pullDownMenu ? flickable.pullDownMenu.spacing : 0
    property real _bottomMenuSpacing: flickable.pushUpMenu ? flickable.pushUpMenu.spacing : 0
    property bool _inBounds: (!flickable.pullDownMenu || !flickable.pullDownMenu.active) && (!flickable.pushUpMenu || !flickable.pushUpMenu.active)
    property real _sizeRatio: (flickable.height - _headerSpacing) / (flickable.contentHeight + _topMenuSpacing + _bottomMenuSpacing)

    function showDecorator() {
        timer.showDecorator = true
    }

    // If we were declared in a Flickable then our parent is contentItem rather than the Flickable itself
    onFlickableChanged: parent = flickable

    width: Math.round(Theme.paddingSmall/2)
    height: _sizeRatio * flickable.height
    anchors.right: parent ? parent.right : undefined
    color: palette.primaryColor
    opacity: (timer.moving && _inBounds) || timer.running ? 1.0 : 0.0
    visible: flickable.contentHeight > flickable.height
    Behavior on opacity { FadeAnimation { duration: 400 } }
    y: Math.max(0, Math.min(
                (_headerSpacing + (flickable.contentY - flickable.originY + _topMenuSpacing) * _sizeRatio),
                (flickable.height - height)))

    Component.onCompleted: {
        if (!flickable) {
            flickable = Util.findFlickable(verticalScrollDecorator)
        }
        if (!page) {
            page = Util.findPage(verticalScrollDecorator)
        }
        if (page && page["_dialogHeader"] !== undefined) {
            if (Util.findFlickable(page._dialogHeader) === flickable) {
                // The DialogHeader is a child of the flickable
                _headerSpacing = Qt.binding(function() { return page._dialogHeader._overlayHeight })
            }
        }
    }

    Timer {
        id: timer

        property bool moving: flickable.movingVertically
        property bool showDecorator

        onMovingChanged: {
            if (!moving && _inBounds) {
                showDecorator = false
                restart()
            }
        }
        onShowDecoratorChanged: if (showDecorator) restart()
        interval: showDecorator ? 800 : 300
        onTriggered: showDecorator = false
    }
}
