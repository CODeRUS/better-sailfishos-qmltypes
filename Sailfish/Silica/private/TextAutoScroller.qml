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

Item {
    property variant innerFlickable
    property variant outerFlickable
    property variant editor

    onEditorChanged: updateFlickables()

    function updateFlickables() {
        innerFlickable = null
        outerFlickable = null
        if (editor) {
            var parentItem = editor.parent
            while (parentItem) {
                if (parentItem.maximumFlickVelocity) {
                    if (innerFlickable) {
                        outerFlickable = parentItem
                        break
                    } else {
                        innerFlickable = parentItem
                    }
                }
                parentItem = parentItem.parent
            }
            delayedLoading.restart()
        }
    }
    function ensureVisible(flickable, animate) {
        if (editor && editor.activeFocus && flickable && flickable.visible && flickable.interactive) {
            var verticallyFlickable = (flickable.flickableDirection == Flickable.HorizontalAndVerticalFlick || flickable.flickableDirection == Flickable.VerticalFlick
                                       || flickable.flickableDirection == Flickable.AutoFlickDirection) && flickable.contentHeight > flickable.height
            var horizontallyFlickable = (flickable.flickableDirection == Flickable.HorizontalAndVerticalFlick || flickable.flickableDirection == Flickable.HorizontalFlick
                                         || flickable.flickableDirection == Flickable.AutoFlickDirection) && flickable.contentWidth > flickable.width

            if (!verticallyFlickable && !horizontallyFlickable)
                return

            var cursorRectangle = editor.mapToItem(flickable, editor.cursorRectangle.x, editor.cursorRectangle.y)

            if (verticallyFlickable) {
                var to = flickable.contentY
                var scrollMarginVertical = (flickable && flickable.scrollMarginVertical) ? flickable.scrollMarginVertical : Theme.itemSizeLarge/2
                if (cursorRectangle.y < scrollMarginVertical) {
                    to = Math.max(flickable.originY, flickable.contentY + cursorRectangle.y - scrollMarginVertical)
                } else if (cursorRectangle.y + editor.cursorRectangle.height + scrollMarginVertical > flickable.height) {
                    to = Math.min(flickable.originY + flickable.contentHeight - flickable.height,
                                  flickable.contentY + cursorRectangle.y + editor.cursorRectangle.height + scrollMarginVertical - flickable.height)
                }

                if (to !== flickable.contentY) {
                    if (to < flickable.originY) {
                        to = flickable.originY
                    }

                    if (animate) {
                        verticalAnim.target = flickable
                        verticalAnim.to = to
                        verticalAnim.restart()
                    } else {
                        flickable.contentY = to
                    }
                }
            }
            if (horizontallyFlickable) {
                var scrollMarginHorizontal = (flickable && flickable.scrollMarginHorizontal) ? flickable.scrollMarginHorizontal : Theme.paddingLarge + Theme.paddingSmall

                if (cursorRectangle.x < scrollMarginHorizontal) {
                    flickable.contentX = Math.max(flickable.originX, flickable.contentX + cursorRectangle.x - scrollMarginHorizontal)
                } else if (cursorRectangle.x + editor.cursorRectangle.width + scrollMarginHorizontal > flickable.width) {
                    flickable.contentX = Math.min(flickable.originX + flickable.contentWidth - flickable.width,
                                               flickable.contentX + cursorRectangle.x + editor.cursorRectangle.width + scrollMarginHorizontal - flickable.width)
                }
            }
        }
    }
    Timer {
        id: delayedLoading
        interval: 10
        onTriggered: {
            ensureVisible(innerFlickable, false)
            ensureVisible(outerFlickable, true)
        }
    }
    Timer {
        id: preventScrolling
        interval: 150
    }
    NumberAnimation {
        id: verticalAnim
        property: "contentY"
        easing.type: Easing.InOutQuad
        duration: 160
        onStopped: if (outerFlickable) outerFlickable.returnToBounds()
    }

    Connections {
        ignoreUnknownSignals: true
        target: editor && editor.activeFocus ? editor : null
        onCursorPositionChanged: delayedLoading.restart()
    }

    Connections {
        target: editor && editor.activeFocus
                ? (editor.hasOwnProperty("_preeditText") ? editor._preeditText : editor)
                : null
        onTextChanged: delayedLoading.restart()
    }

    Connections {
        ignoreUnknownSignals: true
        target: outerFlickable ? outerFlickable : null
        onHeightChanged: if (!outerFlickable.moving) ensureVisible(outerFlickable, false)
        onContentHeightChanged: if (!outerFlickable.moving && !preventScrolling.running) ensureVisible(outerFlickable, false)
        onMovementEnded: preventScrolling.restart()
        onInteractiveChanged: ensureVisible(outerFlickable, false)
    }
}
