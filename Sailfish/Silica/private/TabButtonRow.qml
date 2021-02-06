/****************************************************************************************
**
** Copyright (C) 2020 Open Mobile Platform LLC.
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
    property bool _animated
    property bool flickable
    property real contentWidth

    signal updatePosition(real pos, bool animated)

    onWidthChanged: {
        _updateButtonFontSize()
        _updateContentWidth()
    }
    onImplicitWidthChanged: _updateX()
    Component.onCompleted: {
        _initialized = true
        _updateButtonFontSize()
        _updateContentWidth()
    }

    function _registerButton(button) {
        var buttons = _buttons
        buttons.push(button)
        _buttons = buttons
        _updateButtonFontSize()
        _updateContentWidth()
    }

    function _deregisterButton(button) {
        var buttons = _buttons
        buttons.splice(buttons.indexOf(button), 1)
        _buttons = buttons
        _updateButtonFontSize()
        _updateContentWidth()
    }

    function _updateButtonFontSize() {
        if (!_initialized || width <= 0 || !_tabView) return

        var fontSize = Theme.fontSizeLarge
        var availableWidth = _tabView.width
        var largeWidth = 0
        var i = 0
        for (; i < _buttons.length; i++) {
            var button = _buttons[i]
            largeWidth = largeWidth + largeFontMetrics.advanceWidth(button.title) + Theme.paddingMedium * 2
                       + (button.count >= 0 ? tinyFontMetrics.advanceWidth(button.count) + Theme.paddingSmall * 2 : "")
            if (largeWidth > availableWidth) {
                fontSize = Theme.fontSizeMedium
                break
            }
        }
        _buttonFontSize = fontSize
    }

    function _updateContentWidth() {
        var buttonsWidth = 0
        var i = 0
        for (; i < _buttons.length; i++) {
            var button = _buttons[i]
            buttonsWidth += button.contentWidth
        }
        row.contentWidth = buttonsWidth
    }

    function _updateX() {
        if (!_tabView || _tabView.width <= 0)
            return 0

        var contentPos = 0
        var currentButtonX = _buttonPosition(_tabView.currentIndex)
        if (_tabView._nextIndex === -1 || !_tabView.panning) {
            contentPos = currentButtonX
        } else {
            var nextButtonX = _buttonPosition(_tabView._nextIndex)
            contentPos = (1 - _tabView.slideProgress) * currentButtonX
                    + _tabView.slideProgress * nextButtonX
        }

        updatePosition(contentPos, _animated)
    }

    function _buttonPosition(index) {
        var leftAlign = 0
        var rightAlign = _tabView.width - implicitWidth

        if (implicitWidth < _tabView.width) { // fits
            row.flickable = false
            return rightAlign
        } else if (index === _tabView.count - 1) { // last
            row.flickable = true
            return _tabView.width - implicitWidth
        } else if (index === 0) { // first
            row.flickable = true
            return leftAlign
        } else { // somewhere in between
            row.flickable = true
            var button = _buttonAt(index)
            var centerAlign = -button.x + (_tabView.width - button.width) * 0.5
            return Math.max(rightAlign, Math.min(leftAlign, centerAlign))
        }
    }

    function _buttonAt(index) {
        return children[index]
    }

    Connections {
        target: _tabView
        onWidthChanged: {
            _animated = false
            _updateX()
        }
        onPanningChanged: {
            _animated = true
            _updateX()
        }
        onCurrentIndexChanged: {
            _animated = true
            _updateX()
        }
        onSlideProgressChanged: {
            _animated = true
            _updateX()
        }
    }

    FontMetrics {
        id: largeFontMetrics
        font.pixelSize: Theme.fontSizeLarge
    }

    FontMetrics {
        id: tinyFontMetrics
        font.pixelSize: Theme.fontSizeTiny
    }
}
