/****************************************************************************************
**
** Copyright (C) 2019 Open Mobile Platform LLC.
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

import QtQuick 2.6
import Sailfish.Silica 1.0
import "Util.js" as Util

Row {
    id: row
    readonly property Item _tabView: Util.findParentWithProperty(row, '__silica_tab_view')
    property var _buttons: []
    property int _buttonFontSize: Theme.fontSizeLarge
    property int __silica_tab_button_row
    property bool _initialized

    width: parent.width

    onWidthChanged: _updateButtonFontSize()
    onImplicitWidthChanged: _updateX()
    Component.onCompleted: {
        _initialized = true
        _updateButtonFontSize()
    }

    function _registerButton(button) {
        var buttons = _buttons
        buttons.push(button)
        _buttons = buttons
        _updateButtonFontSize()
    }

    function _deregisterButton(button) {
        var buttons = _buttons
        buttons.splice(buttons.indexOf(button), 1)
        _buttons = buttons
        _updateButtonFontSize()
    }

    function _updateButtonFontSize() {
        if (!_initialized || width <= 0) return
        var fontSize = Theme.fontSizeLarge
        var availableWidth = width - (2 * Theme.horizontalPageMargin)
        var largeWidth = (_buttons.length - 1)* Theme.paddingLarge // spacings
        for (var i = 0; i < _buttons.length; i++) {
            var button = _buttons[i]
            largeWidth = largeWidth + fontMetrics.advanceWidth(button.title)
            if (largeWidth > availableWidth) {
                fontSize = Theme.fontSizeMedium
                break
            }
        }
        _buttonFontSize = fontSize
    }

    function _updateX() {
        if (!_tabView || _tabView.width <= 0) return 0

        var currentButtonX = _buttonPosition(_tabView.currentIndex)
        if (_tabView._nextIndex === -1 || !_tabView.panning) {
            x = currentButtonX
        } else {
            var nextButtonX = _buttonPosition(_tabView._nextIndex)
            x = (1 - _tabView.slideProgress) * currentButtonX + _tabView.slideProgress * nextButtonX
        }
    }

    function _buttonPosition(index) {
        var margin = Theme.horizontalPageMargin - Theme.paddingMedium
        var leftAlign = margin
        var rightAlign = _tabView.width - implicitWidth - margin

        if ((index === _tabView.count - 1) || // last
                (implicitWidth < _tabView.width - 2 * margin)) { // fits
            return rightAlign
        } else if (index === 0) { // first
            return leftAlign
        } else { // somewhere in between
            var button = _buttonAt(index)
            var centerAlign = -button.x - margin + (_tabView.width - button.width)/2
            return Math.max(rightAlign, Math.min(leftAlign, centerAlign))
        }
    }

    function _buttonAt(index) {
        return children[index]
    }

    Behavior on x {
        id: xBehavior
        enabled: false
        XAnimator { duration: 200; easing.type: Easing.InOutQuad }
    }

    Connections {
        target: _tabView
        onWidthChanged: {
            xBehavior.enabled = false
            _updateX()
        }
        onPanningChanged: {
            if (_tabView.panning) {
                xBehavior.enabled = false
            } else {
                xBehavior.enabled = true
            }
            _updateX()
        }
        onCurrentIndexChanged: {
            xBehavior.enabled = true
            _updateX()
        }
        onSlideProgressChanged: _updateX()
    }

    FontMetrics {
        id: fontMetrics
        font.pixelSize: Theme.fontSizeLarge
    }
}
