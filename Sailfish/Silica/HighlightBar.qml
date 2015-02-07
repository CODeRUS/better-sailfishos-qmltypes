/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Bea Lam <bea.lam@jollamobile.com>
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

Rectangle {
    id: highlightItem

    property bool audioEnabled
    property Item highlightedItem
    property int opacityAnimationDuration: 200
    property color color: Theme.highlightColor

    property QtObject _ngfEffect

    function clearHighlight() {
        if (highlightedItem) {
            highlightedItem.highlighted = false
        }

        highlightedItem = null
    }

    function highlight(item, container) {
        // This is a change of item so we deactivate the old item (to stop non-visual feedback)
        if (!item) {
            clearHighlight()
            return
        }
        var newY = parent.mapFromItem(item, 0, item.height/2).y - highlightItem.height/2
        width = item.width

        if (y !== newY && highlightedItem !== null && highlightedItem !== item) {
            animateY.enabled = true
        }
        y = newY

        if (highlightedItem !== item) {
            if (highlightedItem) {
                highlightedItem.highlighted = false
            }
            highlightedItem = item
            if (highlightedItem) {
                highlightedItem.highlighted = true
            }
            if (audioEnabled && _ngfEffect) {
                _ngfEffect.play()
            }
        }
    }

    height: Math.round(Theme.itemSizeExtraSmall/2)
    opacity: highlightedItem ? 0.3 : 0.0

    Component.onCompleted: {
        // avoid hard dependency to ngf module
        _ngfEffect = Qt.createQmlObject("import org.nemomobile.ngf 1.0; NonGraphicalFeedback { event: 'pulldown_highlight' }",
                           highlightItem, 'NonGraphicalFeedback');
    }

    Behavior on opacity { FadeAnimation { duration: highlightItem.opacityAnimationDuration } }
    Behavior on y {
        id: animateY
        enabled: false
        SequentialAnimation {
            SmoothedAnimation { easing.type: Easing.InOutQuad; duration: 50 }
            PropertyAction {
                target: animateY
                property: "enabled"
                value: false
            }
        }
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: "transparent" }
        GradientStop { position: 0.5; color: highlightItem.color }
        GradientStop { position: 1.0; color: "transparent" }
    }
}
