/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
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
import "Util.js" as Util

MouseArea {
    id: pulleyBase

    /*
    The layout model for PullDownMenu/PushUpMenu is as follows:

         ---                        +--------------
          |                         |
          | Flickable.topMargin     | PullDownMenu
          |                         |                 ---
    ---  ---      Flickable.originY +--------------    |
     |                              |                  |
     | Flickable.contentHeight      | Content area     | flickable space
     |                              |                  |
    ---  ---                        +--------------    |
          |                         |                 ---
          | Flickable.bottomMargin  | PushUpMenu
          |                         |
         ---                        +--------------

    Within the PullDownMenu, space is allocated as follows:

    +--------------  ---                             ---
    | topMargin       |                               |
    +--------------   |                               |
    |                 |                               |
    | contentColumn   | PullDownMenu._activeHeight    |
    |                 |                               |
    +--------------   |           PullDownMenu.height |
    | bottomMargin    |                               |
    +--------------  ---                              |
    | spacing                                         |
    +--------------                                  ---

    When PullDownMenu.active is false, PullDownMenu.height is equal to
    PullDownMenu.spacing + PullDownMenu._inactiveHeight.  Some element of
    the menu may be displayed inside the flickable space by placing it
    within the _inactiveHeight.

    The spacing allocation is left empty between the bottom of the menu
    and the position of the Flickable's content.  This empty space is
    visible even if the menu is inactive.

    PushUpMenu is allocated as follows:

    +--------------                                  ---
    | spacing                                         |
    +--------------  ---                              |
    | topMargin       |                               |
    +--------------   |                               |
    |                 |                               |
    | contentColumn   | PushUpMenu._activeHeight      |
    |                 |                               |
    +--------------   |             PushUpMenu.height |
    | bottomMargin    |                               |
    +--------------  ---                             ---
    */

    property bool active                // True if the menu is active
    property real spacing               // Space allocated between the menu border and the flickable content
    property Flickable flickable
    property Item menuItem
    property bool busy
    property bool quickSelect

    property real _inactiveHeight       // Height to show when the menu is inactive
    property real _activeHeight         // Height to show when the menu is active
    property real _inactivePosition     // The position to return to when becoming inactive
    property real _finalPosition        // The position where the menu is at the limit of its extent
    property bool _atInitialPosition: Math.abs(flickable.contentY - _inactivePosition) < 1.0 && !active
    property bool _atFinalPosition: Math.abs(flickable.contentY - _finalPosition) < 1.0 && active
    property bool _pullDown: _inactivePosition > _finalPosition
    property real _menuIndicatorPosition // The position of the highlight when the menu is closed
    property real _menuItemHeight: screen.sizeCategory <= Screen.Medium ? Theme.itemSizeExtraSmall : Theme.itemSizeSmall


    property bool _activationInhibited
    property bool _activationPermitted: visible && enabled && _atInitialPosition && !_activationInhibited

    property color highlightColor: Theme.highlightBackgroundColor
    property color backgroundColor: Theme.highlightBackgroundColor

    property bool _bounceBackEnabled: false
    property bool _bounceBackRunning: bounceBackAnimation.running

    property real _snapThreshold: 80
    property real _snapCalculationThreshold: 240
    property real _snapCalculationVelocity: flickable ? Math.pow(2 * flickable.flickDeceleration * _snapCalculationThreshold, 0.5) : 0

    property bool _inListView: flickable !== null && flickable.hasOwnProperty('highlightRangeMode')
    property bool _changingListView: false
    property real _shadowHeight: Theme.itemSizeExtraLarge
    property Item _page
    property bool _activeAllowed: (!_page || _page.status != PageStatus.Inactive) && Qt.application.active
    property bool _activeDimmer
    property bool _hinting
    property real _highlightIndicatorPosition
    property bool _doClick
    property bool _quickSelected
    property bool _pageActive: _page && _page.status === PageStatus.Active

    property QtObject _ngfEffect

    // Provides content column handle for PulleyMenuLogic -- fetched from c++
    property Item _contentColumn
    // "Type" of PulleyMenu, for PulleyMenuLogic
    property alias _isPullDownMenu: logic.pullDownType
    property alias _dragDistance: logic.dragDistance

    z: 10000 // we want the menu indicator and its dimmer to appear above content
    x: flickable.contentX + (flickable.width - width)/2
    width: flickable.width ? Math.min(flickable.width, screen.sizeCategory > Screen.Medium ? Screen.width*0.7 : Screen.width) : Screen.width
    height: _activeHeight + spacing

    layer.enabled: active || (flickable.dragging && __silica_applicationwindow_instance._dimmingActive)
    layer.smooth: true
    layer.sourceRect: Qt.rect(0, _isPullDownMenu ? 0 : -_shadowHeight,
                              pulleyBase.width, pulleyBase.height + _shadowHeight)
    layer.effect: Item {
        property variant source
        ShaderEffect {
            property variant source: parent.source
            property real flickOpacity: flickable ? flickable.contentItem.opacity : 1.0
            y: _isPullDownMenu ? 0 : -_shadowHeight
            width: pulleyBase.width
            height: pulleyBase.height + _shadowHeight
            fragmentShader: "
                uniform sampler2D source;
                uniform lowp float flickOpacity;
                varying highp vec2 qt_TexCoord0;
                void main(void)
                {
                    highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
                    gl_FragColor = pixelColor * flickOpacity;
                }
                "
        }
    }

    states: [
        State {
            name: "expanded"
            PropertyChanges {
                target: flickable
                highlightRangeMode: ListView.NoHighlightRange
                snapMode: ListView.NoSnap
            }
        }
    ]

    Timer {
        // Update state in timer as changing highlightRangeMode or snapMode
        // can cause view position change, which could affect active, resulting
        // in a binding loop.
        id: expandedStateTimer
        interval: 1
        onTriggered: {
            // highlightRangeMode and snapMode are changed sequentially, rather than
            // atomically -- this causes the ListView to 'fixup' while in an
            // intermediate state, snapping us back to 0,0
            _changingListView = true
            var oldContentY = flickable.contentY
            pulleyBase.state = active ? "expanded" : ""
            flickable.contentY = oldContentY
            _changingListView = false
        }
    }

    drag.target: Item {}

    onVisibleChanged: {
        if (visible) {
            _reposition()
        } else {
            hide()
            close(true)
        }
    }
    onEnabledChanged: {
        if (!enabled) {
            hide()
            close()
        }
    }

    onFlickableChanged: {
        if (flickable) {
            parent = flickable.contentItem
            _addToFlickable(flickable)
            _page = Util.findPage(flickable)
            _reposition()
        }
    }

    onPressed: {
        _highlightMenuItem(contentColumn, mouse.y - contentColumn.y)
    }
    onPositionChanged: _highlightMenuItem(contentColumn, mouse.y - contentColumn.y)
    onReleased: {
        if (menuItem !== null) {
            menuItem.clicked()
        }
        hide()
    }
    onActiveChanged: {
        _bounceBackEnabled = active
        if (_inListView) {
            expandedStateTimer.restart()
        }
        highlightItem._highlightedItemPosition = _isPullDownMenu ? -Screen.height : Screen.height
        if (!active) {
            highlightItem.clearHighlight()
        }
        _setMenuItemsInverted(active)
    }

    on_ActiveAllowedChanged: {
        if (!_activeAllowed && active) {
            close(true)
        }
    }

    on_AtFinalPositionChanged: _setMenuItemsInverted(!_atFinalPosition)

    on_PageActiveChanged: if (_pageActive) highlightItem.state = "enterView"

    Binding {
        when: active && _atFinalPosition && !flickable.dragging && !_quickSelected
        target: __silica_applicationwindow_instance
        property: "_dimScreen"
        value: active && !_bounceBackRunning
    }

    function _findMenuItem(item, allItems) {
        if (!allItems && (!item.visible || !item.enabled)) {
            return null
        }
        if (item.hasOwnProperty("__silica_menuitem")) {
            return item
        }
        for (var i = 0; i < item.children.length; ++i) {
            var mi = _findMenuItem(item.children[i])
            if (mi) {
                return mi
            }
        }
        return null
    }

    function _quickSelectMenuItem(parentItem, yPos) {
        if (quickSelect) {
            var child = null
            var count = 0
            for (var i = 0; i < parentItem.children.length && count < 2; i++) {
                var item = _findMenuItem(parentItem.children[i])
                if (item) {
                    child = item
                    count++
                }
            }
            if (count == 1) {
                _quickSelected = true
                var xPos = width/2
                if ((_pullDown && parentItem.mapToItem(child, xPos, yPos).y <= 0)
                        || (!_pullDown && parentItem.mapToItem(child, xPos, yPos).y >= 0)) {
                    menuItem = child
                    highlightItem.highlight(menuItem, pulleyBase)
                    return menuItem
                }
            } else {
                _quickSelected = false
            }
        } else {
            _quickSelected = false
        }

        return null
    }

    function _highlightMenuItem(parentItem, yPos) {
        var child = _quickSelectMenuItem(parentItem, yPos)
        if (child) {
            return
        }

        var xPos = width/2

        // Only try to highlight if we haven't dragged to the final position
        if (!flickable.dragging || !_atFinalPosition) {
            child = Util.childAt(parentItem, xPos, yPos)
        }
        while (child) {
            if (child && child.hasOwnProperty("__silica_menuitem") && child.enabled && child.visible) {
                menuItem = child
                yPos = parentItem.mapToItem(child, xPos, yPos).y
                highlightItem.highlight(menuItem, pulleyBase, logic.dragDistance <= _contentEnd && !_atFinalPosition)
                break
            }
            parentItem = child
            yPos = parentItem.mapToItem(child, xPos, yPos).y
            child = Util.childAt(parentItem, xPos, yPos)
        }
        if (!child) {
            menuItem = null
            var wasHighlighted = !!highlightItem.highlightedItem
            highlightItem.clearHighlight()
            if (logic.dragDistance <= _contentEnd && wasHighlighted) {
                highlightItem.moveTo(_highlightIndicatorPosition)
            }
        }
    }

    function _hasMenuItems() {
        for (var i = 0; i < _contentColumn.children.length; ++i) {
            if (_findMenuItem(_contentColumn.children[i])) {
                return true
            }
        }

        return false
    }

    function _forEachItem(func) {
        for (var i = 0; i < _contentColumn.children.length; ++i) {
            var item = _findMenuItem(_contentColumn.children[i], true)
            if (item) {
                func(item)
            }
        }
    }

    function _setMenuItemsInverted(inverted) {
        _forEachItem(function (item) { item._invertColors = inverted })
    }

    function hide() {
        if (active && _bounceBackEnabled) {
            delayedBounceTimer.restart()
        }
        menuItem = null
    }

    function cancelBounceBack() {
        _bounceBackEnabled = false
        delayedBounceTimer.stop()
        bounceBackAnimation.stop()
    }

    function close(immediate) {
        if (!active) {
            // can't close what isn't open, and we
            // don't want to reposition unnecessarily
            return
        }

        if (immediate === true) {
            _forceReposition()
        } else {
            flickAnimation.stop()
            if (!flickable.dragging && !bounceBackAnimation.running) {
                _reposition()
            }
        }
    }

    HighlightBar {
        id: highlightItem
        y: {
            if (!active) return _menuIndicatorPosition
            if (highlightedItem || (!flickable.dragging && _atFinalPosition)
                    || logic.dragDistance > _contentEnd) return _highlightedItemPosition
            return _highlightIndicatorPosition
        }

        height: highlightedItem ? highlightedItem.height : _menuItemHeight

        yAnimationDuration: 120
        color: pulleyBase.highlightColor
        audioEnabled: flickable.dragging || quickSelect
        opacityAnimationDuration: _atInitialPosition || _bounceBackRunning ? 400 : 120
        opacity: Theme.highlightBackgroundOpacity * _opacity

        property real _opacity: {
            if (highlightedItem) return 1.0
            if ((!active && !_hinting) || _bounceBackRunning) return busyOpacity
            if (!_hasMenuItems(_contentColumn)) return 1.0 - logic.dragDistance/Theme.paddingMedium
            return Math.max(1.5 - logic.dragDistance/_menuItemHeight,
                            logic.dragDistance <= _contentEnd && !flickAnimation.running ? 0.5 : 0.0)
        }

        property real busyOpacity: 1.0
        Timer {
            id: busyTimer
            running: busy && !active && Qt.application.active
            interval: 500
            repeat: true
            onRunningChanged: highlightItem.busyOpacity = 1.0
            onTriggered: highlightItem.busyOpacity = highlightItem.busyOpacity >= 0.99 ? 0.2 : 1.2
        }

        states: [
            State {
                name: "click"
                when: _doClick && !_quickSelected
            },
            State {
                name: "quickselectclick"
                when: _doClick && _quickSelected
            },
            State {
                name: "enterView"
                PropertyChanges {
                    target: highlightItem
                    opacity: Theme.highlightBackgroundOpacity
                }
            },
            State {
                name: "bounceBack"
                when: _bounceBackRunning && active
                PropertyChanges {
                    target: highlightItem
                    y: _menuIndicatorPosition
                }
            }
        ]
        transitions: [
            Transition {
                to: "click"
                SequentialAnimation {
                    FadeAnimation {
                        target: highlightItem
                        duration: 135
                        to: 0.15
                    }
                    FadeAnimation {
                        target: highlightItem
                        duration: 65
                        to: Theme.highlightBackgroundOpacity
                    }
                    FadeAnimation {
                        target: highlightItem
                        duration: 135
                        to: 0.15
                    }
                    FadeAnimation {
                        target: highlightItem
                        duration: 65
                        to: Theme.highlightBackgroundOpacity
                    }
                    PauseAnimation {
                        duration: 50
                    }
                    ScriptAction {
                        script: {
                            if (active && menuItem) {
                                menuItem.clicked()
                            }
                            hide()
                            _doClick = false
                        }
                    }
                }
            },
            Transition {
                to: "quickselectclick"
                SequentialAnimation {
                    FadeAnimation {
                        target: highlightItem
                        duration: 135
                        to: 0.15
                    }
                    FadeAnimation {
                        target: highlightItem
                        duration: 65
                        to: Theme.highlightBackgroundOpacity
                    }
                    PauseAnimation {
                        duration: 50
                    }
                    ScriptAction {
                        script: {
                            if (active && menuItem) {
                                menuItem.clicked()
                            }
                            hide()
                            _doClick = false
                        }
                    }
                }
            },
            Transition {
                to: "enterView"
                SequentialAnimation {
                    FadeAnimation {
                        target: highlightItem
                        duration: 600
                        to: 0.7
                    }
                    FadeAnimation {
                        target: highlightItem
                        duration: 2500
                        to: Theme.highlightBackgroundOpacity
                    }
                    ScriptAction {
                        script: highlightItem.state = ""
                    }
                }
            },
            Transition {
                to: "bounceBack"
                ScriptAction {
                    script: highlightItem._transientAnimateY = false
                }
                SmoothedAnimation {
                    target: highlightItem
                    property: "y"
                    to: _menuIndicatorPosition
                    duration: 400
                    velocity: -1
                }
            }
        ]
    }

    function _interceptFlick() {
        // Do not permit flicking inside the menu (unless it is a small flick that does not present
        // a danger of accidentally selecting the wrong item, or quickSelect is enabled)
        if (active && !quickSelect && (Math.abs(flickable.verticalVelocity) > 500)) {
            var opening = _pullDown ? flickable.verticalVelocity < 0 : flickable.verticalVelocity > 0
            flickAnimation.to = opening ? _finalPosition : _inactivePosition
            flickAnimation.duration = 300
            flickAnimation.restart()
            menuItem = null
            highlightItem.clearHighlight()
        } else if (!active) {
            logic.monitorFlick()
        }
    }
    function _bounceBack() {
        if (!flickAnimation.running) {
            if (menuItem) {
                _doClick = true
            } else if (!_atFinalPosition) {
                hide()
            }
        }
    }
    function _reposition() {
        if (active) {
            _forceReposition()
        }
    }
    function _forceReposition() {
        if (flickable) {
            _stopAnimations()
            flickable.contentY = _inactivePosition;
        }
    }
    function _stopAnimations() {
        if (active) {
            flickAnimation.stop()
            bounceBackAnimation.stop()
        } else {
            highlightItem.state = ""
            snapAnimation.stop()
        }
    }

    function _updateFlickable() {
        var item = Util.findFlickable(pulleyBase)
        if (item) {
            flickable = item
            parent = item.contentItem
            _addToFlickable(item)
        }
    }

    PulleyMenuLogic {
        id: logic
        flickable: pulleyBase.flickable
        onFinalPositionReached: {
            if (active && _ngfEffect && !menuItem) {
                _ngfEffect.play()
            }
        }

        // void animateFlick(qreal duration, qreal position)
        onAnimateFlick: {
            flickAnimation.duration = duration * 1000
            flickAnimation.to = position
            flickAnimation.restart()
        }
    }

    Connections {
        target: flickable
        ignoreUnknownSignals: true
        onMovementEnded: {
            if (active) {
                if (logic.outOfBounds()) {
                    flickAnimation.to = _finalPosition
                    flickAnimation.duration = Math.min(Math.abs(flickable.contentY - _finalPosition) * 2, 400)
                    flickAnimation.restart()
                    menuItem = null
                    highlightItem.clearHighlight()
                } else {
                    _bounceBack()
                }
            } else if (flickable.height < flickable.contentHeight - _snapThreshold) {
                // If we are close to the menu location, snap to the end
                var dist = flickable.contentY - _inactivePosition
                if (_pullDown && dist > 0 && dist < _snapThreshold
                        || !_pullDown && dist < 0 && dist > -_snapThreshold) {
                    snapAnimation.restart()
                }
            }
        }
        onMovementStarted: _stopAnimations()
        onFlickStarted: _interceptFlick()
        onContentHeightChanged: if (!active) close()
        onModelChanged: _forceReposition()
        onHeaderChanged: _reposition()
        onOriginYChanged: {
            if (bounceBackAnimation.running) {
                bounceBackAnimation.restart()
            }
        }
        onDraggingChanged: {
            if (!flickable.dragging) {
                _activationInhibited = false
            }
        }
    }
    Timer {
        id: delayedBounceTimer
        interval: 10
        onTriggered: bounceBackAnimation.restart()
    }
    NumberAnimation {
        id: flickAnimation
        target: flickable
        property: "contentY"
        easing.type: Easing.OutQuad
        onStopped: {
            if (quickSelect && menuItem && _atFinalPosition) {
                _bounceBack()
            }
        }
    }
    SmoothedAnimation {
        id: bounceBackAnimation
        duration: 400
        velocity: -1
        target: flickable
        property: "contentY"
        to: _inactivePosition
    }
    SmoothedAnimation {
        id: snapAnimation
        duration: 200
        target: flickable
        property: "contentY"
        to: _inactivePosition
    }
    InverseMouseArea {
        anchors.fill: parent
        enabled: active && !_hinting
        stealPress: !flickable.dragging
        onPressedOutside: {
            if (!flickAnimation.running && !flickable.moving) {
                if (highlightItem.state !== "click") {
                    menuItem = null
                    hide()
                }
                cancelTouch()
            }
        }
    }

    Component.onCompleted: {
        // avoid hard dependency to ngf module
        _ngfEffect = Qt.createQmlObject("import org.nemomobile.ngf 1.0; NonGraphicalFeedback { event: 'pulldown_lock' }",
                           highlightItem, 'NonGraphicalFeedback');
    }

    Component.onDestruction: {
        active = false
    }
}
