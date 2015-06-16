/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
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

/*

With labelVisible: true (default)

  -------------------------
  |                       |
  |     textTopMargin     |
  |                       |
  | - - - - - - - - - - - |
  |                       |
  |                       |
  |                       |
  |      contentItem      |
  |                       |
  |                       |
  |                       |
  | - - - - - - - - - - - |
  | Theme.paddingSmall/2  |
  ------------------------- background rule
  | Theme.paddingSmall/2  |
  | - - - - - - - - - - - |
  |                       |
  |       labelItem       |
  |                       |
  | - - - - - - - - - - - |
  |                       |
  |   Theme.paddingSmall  |
  |                       |
  -------------------------


With labelVisible: false

  -------------------------
  |                       |
  |     textTopMargin     |
  |                       |
  | - - - - - - - - - - - |
  |                       |
  |                       |
  |                       |
  |     contentItem       |
  |                       |
  |                       |
  |                       |
  | - - - - - - - - - - - |
  | Theme.paddingSmall/2  |
  ------------------------- background rule
  | Theme.paddingSmall/2  |
  | - - - - - - - - - - - |
  |                       |
  |   Theme.paddingSmall  |
  |                       |
  -------------------------

*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "TextAutoScroller.js" as TextAutoScroller

TextBaseItem {
    id: textBase

    property alias label: labelItem.text
    property alias color: labelItem.color
    property color cursorColor: Theme.primaryColor
    property alias placeholderText: placeholderTextLabel.text
    property alias placeholderColor: placeholderTextLabel.color
    property bool softwareInputPanelEnabled: true
    property bool errorHighlight: false
    property real textMargin: Theme.horizontalPageMargin
    property real textLeftMargin: textMargin
    property real textRightMargin: textMargin
    property real textTopMargin: Theme.paddingSmall
    // TODO: Change to use "placeholderTextLabel.lineHeight once merge request #298 is merged.
    readonly property real textVerticalCenterOffset: textTopMargin + placeholderTextLabel.height / 2
    property int selectionMode: TextInput.SelectCharacters
    property alias font: placeholderTextLabel.font
    property int focusOutBehavior: FocusBehavior.ClearItemFocus
    property bool autoScrollEnabled: true
    property Component background: Separator {
        x: textLeftMargin
        anchors {
            bottom: contentItem.bottom
            bottomMargin: -Theme.paddingSmall/2
        }
        width: contentItem.width
        color: labelItem.color
        horizontalAlignment: placeholderTextLabel.horizontalAlignment
    }

    // TODO: Remove this wrongly-formulated property name once users have been migrated, and version incremented
    property alias enableSoftwareInputPanel: textBase.softwareInputPanelEnabled

    property bool _suppressPressAndHoldOnText
    property Item _backgroundItem
    property QtObject _feedbackEffect
    property variant _appWindow: __silica_applicationwindow_instance

    property alias _flickableDirection: flickable.flickableDirection

    property Item _editor
    property alias editor: textBase._editor  //XXX Deprecated
    property bool labelVisible: true

    default property alias _children: contentItem.data
    property alias _contentItem: contentItem
    property alias _labelItem: labelItem
    property alias _placeholderTextLabel: placeholderTextLabel
    property bool focusOnClick: !readOnly

    function forceActiveFocus() { _editor.forceActiveFocus() }
    function cut() { _editor.cut() }
    function copy() { _editor.copy() }
    function paste() { _editor.paste() }
    function select(start, end) { _editor.select(start, end) }
    function selectAll() { _editor.selectAll() }
    function selectWord() { _editor.selectWord() }
    function deselect() { _editor.deselect() }
    function positionAt(mouseX, mouseY) {
        var translatedPos = mapToItem(_editor, mouseX, mouseY)
        return _editor.positionAt(translatedPos.x, translatedPos.y)
    }
    function positionToRectangle(position) {
        var rect = _editor.positionToRectangle(position)
        var translatedPos = mapFromItem(_editor, rect.x, rect.y)
        rect.x = translatedPos.x
        rect.y = translatedPos.y
        return rect;
    }

    onHorizontalAlignmentChanged: {
        if (explicitHorizontalAlignment) {
            placeholderTextLabel.horizontalAlignment = horizontalAlignment
            labelItem.horizontalAlignment = horizontalAlignment
        }
    }
    onExplicitHorizontalAlignmentChanged: {
        if (explicitHorizontalAlignment) {
            placeholderTextLabel.horizontalAlignment = horizontalAlignment
            labelItem.horizontalAlignment = horizontalAlignment
        } else {
            placeholderTextLabel.horizontalAlignment = undefined
            labelItem.horizontalAlignment = undefined
        }
    }

    function _updateBackground() {
        if (_backgroundItem) {
            _backgroundItem.destroy()
            _backgroundItem = null
        }
        if (!readOnly && background && background.status) {
            _backgroundItem = background.createObject(textBase)
            _backgroundItem.z = -1
        }
    }

    function _updateFlickables() {
        if (autoScrollEnabled) {
            TextAutoScroller.autoScroller.updateFlickables()
        } else {
            TextAutoScroller.autoScroller.editor = null
        }
    }

    signal clicked(variant mouse)
    signal pressAndHold(variant mouse)

    implicitHeight: _editor.height + Theme.paddingMedium + textTopMargin + (labelVisible ? labelItem.height : 0) + Theme.paddingSmall

    onBackgroundChanged: _updateBackground()
    Component.onCompleted: {
        if (!_backgroundItem) {
            _updateBackground()
        }
        // Avoid hard dependency to feedback - NOTE: Qt5Feedback doesn't support TextSelection effect
        _feedbackEffect = Qt.createQmlObject("import QtQuick 2.0; import QtFeedback 5.0; ThemeEffect { effect: ThemeEffect.PressWeak }",
                           textBase, 'ThemeEffect');

        // calling ThemeEffect.supported initializes the feedback backend,
        // without the initialization here the first playback drops few frames
        if (_feedbackEffect && !_feedbackEffect.supported) {
            _feedbackEffect = null
        }
    }

    // This is the container item for the editor.  It is not the flickable because we want mouse
    // interaction to extend to the full bounds of the item but painting to be clipped so that
    // it doesn't exceed the margins or overlap with the label text.  So we have this item which
    // looks like a flickable to TextAutoScroller but occupies less space than the actual flickable.
    Item {
        id: contentItem

        property real maximumFlickVelocity: 1
        property alias originX: flickable.originX
        property alias originY: flickable.originY
        property alias contentX: flickable.contentX
        property alias contentY: flickable.contentY
        property alias flickableDirection: flickable.flickableDirection
        property alias interactive: flickable.interactive
        property real contentWidth: _editor.width + Theme.paddingSmall
        property real contentHeight: _editor.height + Theme.paddingSmall

        clip: flickable.interactive

        anchors {
            left: parent.left; top: parent.top;
            right: parent.right; bottom: parent.bottom
            leftMargin: textLeftMargin; topMargin: textTopMargin
            rightMargin: textRightMargin
            bottomMargin: (labelVisible ? labelItem.height + labelItem.anchors.bottomMargin : Theme.paddingSmall) + Theme.paddingSmall
        }
    }

    Label {
        id: placeholderTextLabel

        color: _editor.activeFocus ? Theme.secondaryHighlightColor : Theme.secondaryColor

        opacity: (textBase.text.length === 0 && !_editor.inputMethodComposing) ? 1.0 : 0.0
        Behavior on opacity { FadeAnimation {} }
        elide: Text.ElideRight
        anchors {
            left: parent.left; top: parent.top; right: parent.right
            leftMargin: textLeftMargin; topMargin: textTopMargin; rightMargin: textRightMargin
        }
    }

    Label {
        id: labelItem

        anchors {
            left: parent.left; bottom: parent.bottom; right: parent.right
            leftMargin: textLeftMargin
            bottomMargin: readOnly ? Theme.paddingMedium : Theme.paddingSmall
            rightMargin: textRightMargin
        }
        visible: labelVisible
        color: textBase.errorHighlight
               ? "#ff4d4d"
               : (_editor.activeFocus ? Theme.highlightColor : Theme.primaryColor)
        opacity: (textBase.errorHighlight || _editor.activeFocus ? 1.0 : 0.6) * (1 - placeholderTextLabel.opacity)
        elide: Text.ElideRight
        font.pixelSize: Theme.fontSizeSmall
    }

    Flickable {
        id: flickable

        anchors {
            left: parent.left; top: parent.top;
            right: parent.right; bottom: parent.bottom
            leftMargin: textLeftMargin; topMargin: textTopMargin
            rightMargin: textRightMargin
        }

        pixelAligned: true
        contentHeight: _editor.height + parent.height - contentItem.height
        contentWidth: _editor.width + Theme.paddingSmall
        interactive: _editor.height > contentItem.height || _editor.width > contentItem.width
        boundsBehavior: Flickable.StopAtBounds
    }

    MouseArea {
        id: mouseArea

        property real initialMouseX
        property real initialMouseY
        property bool hasSelection: _editor !== null && _editor.selectedText != ""
        property bool cursorHit
        property bool cursorGrabbed
        property bool handleGrabbed
        property bool textSelected
        property Item selectionStartHandle
        property Item selectionEndHandle
        property int cursorStepThreshold: Theme.itemSizeSmall / 2
        property real scaleFactor: 2
        property int scaleOffset: Theme.itemSizeSmall / 2
        property int scaleTopMargin: Theme.paddingLarge
        property int touchAreaSize: Theme.itemSizeExtraSmall
        property int moveThreshold: Theme.paddingMedium
        property int touchOffset

        function positionAt(mouseX, mouseY) {
            var translatedPos = mapToItem(_editor, mouseX, mouseY)
            translatedPos.x = Math.max(0, Math.min(_editor.width - 1, translatedPos.x))
            translatedPos.y = Math.max(0, Math.min(_editor.height - 1 , translatedPos.y))
            return _editor.positionAt(translatedPos.x, translatedPos.y)
        }

        function positionHit(position, mouseX, mouseY) {
            var rect = _editor.positionToRectangle(position)
            var translatedPos = mapToItem(_editor, mouseX, mouseY)
            return translatedPos.x > rect.x - touchAreaSize / 2
                    && translatedPos.x < rect.x + touchAreaSize / 2
                    && translatedPos.y > rect.y
                    && translatedPos.y < rect.y + Math.max(rect.height, touchAreaSize)
        }

        function moved(mouseX, mouseY) {
            return (Math.abs(initialMouseX - mouseX) > moveThreshold ||
                    Math.abs(initialMouseY - mouseY) > moveThreshold)
        }

        function updateTouchOffsetAndScaleOrigin(reset) {
            if (_appWindow !== undefined) {
                var cursorRect = _editor.cursorRectangle
                var translatedPos = mapToItem(_appWindow._rotatingItem, mouseX, mouseY)
                var offset = Math.min(cursorRect.height / 2 + scaleOffset / scaleFactor,
                                      (translatedPos.y - scaleTopMargin) / scaleFactor - cursorRect.height / 2)
                if (reset || offset > touchOffset) {
                    touchOffset = offset
                }

                var cursorPos = _editor.mapToItem(_appWindow._rotatingItem, cursorRect.x, cursorRect.y)

                var originX = mouseArea.mapToItem(_appWindow._rotatingItem, mouseX, 0).x;
                var originY = 0
                if (reset) {
                    originY = (cursorPos.y < (scaleFactor - 1) * cursorRect.height + scaleOffset + scaleTopMargin)
                            ? (scaleFactor * cursorPos.y - scaleTopMargin) / (scaleFactor - 1)
                            : cursorPos.y + cursorRect.height + scaleOffset / (scaleFactor - 1)
                } else {
                    var mappedOrigin = _appWindow.contentItem.mapToItem(_appWindow._rotatingItem,
                                                                        _appWindow._contentScale.origin.x,
                                                                        _appWindow._contentScale.origin.y);
                    var scaledCursorHeight = cursorRect.height * scaleFactor / (scaleFactor - 1)
                    if (cursorPos.y < scaleTopMargin) {
                        originY = Math.max(0, mappedOrigin.y - scaledCursorHeight)
                    } else if (cursorPos.y + scaleFactor * cursorRect.height + Theme.paddingMedium > _appWindow._rotatingItem.height) {
                        originY = Math.min(_appWindow._rotatingItem.height, mappedOrigin.y + scaledCursorHeight)
                    } else {
                        originY = mappedOrigin.y
                    }
                }

                var mappedPos = _appWindow._rotatingItem.mapToItem(_appWindow.contentItem, originX, originY);
                _appWindow._contentScale.origin.x = mappedPos.x
                _appWindow._contentScale.origin.y = mappedPos.y
            }
        }

        function reset() {
            selectionTimer.stop()
            cursorHit = false
            cursorGrabbed = false
            handleGrabbed = false
            preventStealing = false
            textSelected = false
        }

        parent: flickable
        anchors.fill: parent

        width: textBase.width
        height: textBase.height
        enabled: textBase.enabled

        onPressed: {
            if (!_editor.activeFocus) {
                return
            }
            initialMouseX = mouseX
            initialMouseY = mouseY
            if (!hasSelection) {
                if (positionHit(_editor.cursorPosition, mouseX, mouseY)) {
                    cursorHit = true
                }
            } else if (positionHit(_editor.selectionStart, mouseX, mouseY)) {
                var selectionStart = _editor.selectionStart
                _editor.cursorPosition = _editor.selectionEnd
                _editor.moveCursorSelection(selectionStart, TextInput.SelectCharacters)
                handleGrabbed = true
                preventStealing = true
            } else if (positionHit(_editor.selectionEnd, mouseX, mouseY)) {
                var selectionEnd = _editor.selectionEnd
                _editor.cursorPosition = _editor.selectionStart
                _editor.moveCursorSelection(selectionEnd, TextInput.SelectCharacters)
                handleGrabbed = true
                preventStealing = true
            }
            if (!handleGrabbed) {
                selectionTimer.resetAndRestart()
            }
        }

        onClicked: {
            textBase.clicked(mouse)
        }
        onPressAndHold: {
            if (!_editor.activeFocus || !_suppressPressAndHoldOnText) {
                textBase.pressAndHold(mouse)
            }
        }

        onPositionChanged: {
            if (!handleGrabbed && !cursorGrabbed && moved(mouseX, mouseY)) {
                selectionTimer.stop()
                if (cursorHit) {
                    cursorGrabbed = true
                    preventStealing = true
                    Qt.inputMethod.commit()
                }
            }
            if (handleGrabbed || cursorGrabbed) {
                if (_appWindow !== undefined && _appWindow._contentScale.animationRunning) {
                    // Don't change the cursor position during animation
                    return
                }
                updateTouchOffsetAndScaleOrigin(false)
                var cursorPosition = mouseArea.positionAt(mouseX, mouseY - mouseArea.touchOffset)
                if (handleGrabbed) {
                    _editor.moveCursorSelection(cursorPosition, textBase.selectionMode)
                } else {
                    _editor.cursorPosition = cursorPosition
                }
            }
        }

        onReleased: {
            if (!handleGrabbed && !textSelected && !cursorGrabbed && containsMouse && (focusOnClick || _editor.activeFocus)) {
                Qt.inputMethod.commit()
                var translatedPos = mouseArea.mapToItem(_editor, mouseX, mouseY)
                var cursorRect = _editor.positionToRectangle(_editor.cursorPosition)
                var cursorPosition
                if (translatedPos.x < cursorRect.x && translatedPos.x > cursorRect.x - cursorStepThreshold &&
                    translatedPos.y > cursorRect.y && translatedPos.y < cursorRect.y + cursorRect.height) {
                    // step one character backward
                    cursorPosition = _editor.cursorPosition - 1
                } else if (translatedPos.x > cursorRect.x + cursorRect.width &&
                           translatedPos.x < cursorRect.x + cursorRect.width + cursorStepThreshold &&
                           translatedPos.y > cursorRect.y && translatedPos.y < cursorRect.y + cursorRect.height) {
                    // step one character forward
                    cursorPosition = _editor.cursorPosition + 1
                } else {
                    // reselect position
                    cursorPosition = _editor.positionAt(translatedPos.x, translatedPos.y)
                    if (cursorPosition > 1 &&
                        _editor.text.charAt(cursorPosition - 1) == ' ' &&
                        _editor.text.charAt(cursorPosition - 2) != ' ' &&
                        cursorPosition !== _editor.text.length) {
                        // space hit, move to the end of the previous word
                        cursorPosition--
                    }
                }
                _editor.cursorPosition = cursorPosition
                if (_editor.activeFocus) {
                    if (textBase.softwareInputPanelEnabled) {
                        Qt.inputMethod.show()
                    }
                } else {
                    _editor.forceActiveFocus()
                }
            }
            reset()
        }

        onCanceled: reset()

        onHasSelectionChanged: {
            if (selectionStartHandle === null) {
                selectionStartHandle = handleComponent.createObject(_editor)
                selectionStartHandle.start = true
            }
            if (selectionEndHandle === null) {
                selectionEndHandle = handleComponent.createObject(_editor)
                selectionEndHandle.start = false
            }
        }

        onHandleGrabbedChanged: {
            if (!handleGrabbed && _editor.selectedText !== "") {
                _editor.copy()
            }
        }
    }

    InverseMouseArea {
        anchors.fill: parent
        enabled: _editor.activeFocus && textBase.softwareInputPanelEnabled
        onClickedOutside: focusLossTimer.start()
    }

    Timer {
        id: selectionTimer

        property int counter

        repeat: true

        function resetAndRestart() {
            counter = 0
            interval = 800
            restart()
        }

        function positionAfter(position, mouseX, mouseY) {
            var rect = _editor.positionToRectangle(position)
            return mouseY > rect.y + Math.max(rect.height, mouseArea.touchAreaSize) ||
                   (mouseY >= rect.y &&
                    mouseX > rect.x + rect.width + mouseArea.touchAreaSize / 2)
        }

        onTriggered: {
            var origSelectionStart = _editor.selectionStart
            var origSelectionEnd = _editor.selectionEnd
            var translatedPos = mouseArea.mapToItem(_editor, mouseArea.initialMouseX, mouseArea.initialMouseY)
            if (counter == 0) {
                if (_suppressPressAndHoldOnText) {
                    Qt.inputMethod.commit()
                    if (_editor.length == 0 || positionAfter(_editor.length - 1, translatedPos.x, translatedPos.y)) {
                        // This selection is outside the text itself - deselect and pass through as press-and-hold
                        _editor.deselect()
                        mouseArea.reset()
                        textBase.pressAndHold({ 'x': mouseArea.initialMouseX, 'y': mouseArea.initialMouseY })
                        return
                    }
                }

                _editor.cursorPosition = _editor.positionAt(translatedPos.x, translatedPos.y)
                _editor.selectWord()
                if (origSelectionStart != _editor.selectionStart || origSelectionEnd != _editor.selectionEnd) {
                    if (mouseArea.selectionStartHandle !== null)
                        mouseArea.selectionStartHandle.showAnimation.restart()
                    if (mouseArea.selectionEndHandle !== null)
                        mouseArea.selectionEndHandle.showAnimation.restart()
                }
                interval = 600
            } else if (counter == 1) {
                 _editor.select(_editor.positionAt(0, translatedPos.y),
                                _editor.positionAt(_editor.width, translatedPos.y))
            } else {
                _editor.cursorPosition = _editor.text.length
                _editor.selectAll()
                stop()
            }
            if (origSelectionStart != _editor.selectionStart || origSelectionEnd != _editor.selectionEnd) {
                if (_feedbackEffect) {
                    _feedbackEffect.play()
                }
                if (_editor.selectedText !== "") {
                    _editor.copy()
                }
                mouseArea.textSelected = true
            }
            mouseArea.cursorHit = false
            counter++
        }
    }

    Timer {
        id: focusLossTimer
        interval: 1
        onTriggered: {
            // Note: textBase.focus.  Removing focus from the editor item breaks the focus
            // inheritence chain making it impossible for the editor to regain focus without
            // using forceActiveFocus()
            if (!textBase.activeFocus) {
            } else if (textBase.focusOutBehavior === FocusBehavior.ClearItemFocus) {
                textBase.focus = false
            } else if (textBase.focusOutBehavior === FocusBehavior.ClearPageFocus) {
                // Just remove the focus from the application window (that is a focus scope).
                // This allows an item to clear its active focus without breaking the focus
                // chain within a page.
                if (_appWindow !== undefined) {
                    _appWindow.focus = false
                } else {
                    textBase.focus = false // fallback
                }
            } else if (!_editor.activeFocus) {
                // Happens e.g. when keyboard is closed
                textBase.focus = false
            } else {
                _editor.deselect()
            }
        }
    }

    StateGroup {
        states: State {
            when: (mouseArea.handleGrabbed || mouseArea.cursorGrabbed) && _appWindow !== undefined
            PropertyChanges {
                target: _appWindow ? _appWindow._contentScale : null
                xScale: mouseArea.scaleFactor
                yScale: mouseArea.scaleFactor
            }
            StateChangeScript {
                script: {
                    mouseArea.updateTouchOffsetAndScaleOrigin(true)
                }
            }
        }
    }

    Connections {
        ignoreUnknownSignals: true
        target: _editor
        onActiveFocusChanged: {
            if (_editor.activeFocus) {
                if (textBase.autoScrollEnabled) {
                    TextAutoScroller.create(_editor)
                }
                if (textBase.softwareInputPanelEnabled) {
                    Qt.inputMethod.show()
                }
            } else {
                // When keyboard is explicitly closed (by swipe down) only _editor.focus is cleared.
                // Need to use focusLossTimer for clearing the focus of the parent.
                // (See the comments in focusLossTimer.)
                focusLossTimer.start()
            }
        }
    }

    Component {
        id: handleComponent

        Rectangle {
            id: handleId
            property bool start
            property variant cursorRect: {
                _editor.width // creates a binding. we want to refresh the cursor rect e.g. on orientation change
                _editor.positionToRectangle(start ? _editor.selectionStart : _editor.selectionEnd)
            }
            property alias showAnimation: showAnimationId
            property int xAnimationLength: Theme.itemSizeExtraLarge

            color: textBase.cursorColor
            parent: _editor
            x: Math.round(cursorRect.x + cursorRect.width / 2 - width / 2)
            y: Math.round(cursorRect.y + cursorRect.height / 2 - height / 2)
            width: Math.round(Theme.iconSizeSmall / 4) * 2 // ensure even number
            height: width
            radius: width / 2
            smooth: true
            visible: mouseArea.hasSelection && textBase.activeFocus

            states: State {
                when: mouseArea.handleGrabbed
                name: "grabbed"
                PropertyChanges {
                    target: handleId
                    width: 2
                    height: cursorRect.height
                    radius: 0
                }
            }

            transitions: Transition {
                to: "grabbed"
                reversible: true
                SequentialAnimation {
                    NumberAnimation { property: "width"; duration: 100 }
                    PropertyAction { property: "radius" }
                    NumberAnimation { property: "height"; duration: 100 }
                }
            }

            ParallelAnimation {
                id: showAnimationId
                FadeAnimation {
                    target: handleId
                    from: 0
                    to: 1
                }
                NumberAnimation {
                    target: handleId
                    property: "x"
                    from: start ? handleId.x - xAnimationLength : handleId.x + xAnimationLength
                    to: handleId.x
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
