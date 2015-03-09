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
import Sailfish.Silica.private 1.0
import "private"
import "private/FastScrollAnimation.js" as FastScroll

GridView {
    id: gridView

    // Property quickScrollEnabled deprecated. Use quickScroll instead.
    property alias quickScrollEnabled: quickScrollItem.quickScroll
    property alias quickScroll: quickScrollItem.quickScroll
    property alias quickScrollAnimating: quickScrollItem.quickScrollAnimating
    property Item pullDownMenu
    property Item pushUpMenu
    property QtObject _scrollAnimation
    property bool _pulleyDimmerActive: pullDownMenu && pullDownMenu._activeDimmer || pushUpMenu && pushUpMenu._activeDimmer

    function scrollToTop() {
        FastScroll.scrollToTop(gridView, quickScrollItem)
    }
    function scrollToBottom() {
        FastScroll.scrollToBottom(gridView, quickScrollItem)
    }

    pixelAligned: true
    pressDelay: 50
    flickDeceleration: Theme.flickDeceleration
    maximumFlickVelocity: Theme.maximumFlickVelocity
    cacheBuffer: Theme.itemSizeMedium * 8
    boundsBehavior: (pullDownMenu && pullDownMenu._activationPermitted) || (pushUpMenu && pushUpMenu._activationPermitted) ? Flickable.DragOverBounds : Flickable.StopAtBounds

    BoundsBehavior { flickable: gridView }
    QuickScroll {
        id: quickScrollItem
        flickable: gridView
    }
}
