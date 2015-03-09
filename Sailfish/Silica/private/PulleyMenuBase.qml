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

    property bool _activationInhibited
    property bool _activationPermitted: visible && enabled && _atInitialPosition && !_activationInhibited

    property color highlightColor: Theme.highlightColor
    property color backgroundColor: Theme.highlightBackgroundColor

    property bool _bounceBackEnabled: false
    property bool _bounceBackRunning: bounceBackAnimation.running

    property real _snapThreshold: 80
    property real _snapCalculationThreshold: 240
    property real _snapCalculationVelocity: flickable ? Math.pow(2 * flickable.flickDeceleration * _snapCalculationThreshold, 0.5) : 0

    property bool _inListView: flickable !== null && flickable.hasOwnProperty('highlightRangeMode')
    property bool _changingListView: false
    property Item _menuIndicatorItem
    property Item _page
    property bool _activeAllowed: (!_page || _page.status != PageStatus.Inactive) && Qt.application.active
    property bool _activeDimmer
    property bool _hinting

    property QtObject _ngfEffect

    // Provides content column handle for PulleyMenuLogic -- fetched from c++
    property Item _contentColumn
    // "Type" of PulleyMenu, for PulleyMenuLogic
    property alias _isPullDownMenu: logic.pullDownType

    z: 10000 // we want the menu indicator and its dimmer to appear above content
    x: flickable.contentX
    width: flickable.width ? flickable.width : Screen.width
    height: (active ? _activeHeight : _inactiveHeight) + spacing

    // When the height changes the dimmable rectangle changes
    onHeightChanged: if (active || _activeDimmer || dimmer.opacity > 0) _updateDim()
    onWidthChanged: if (active || _activeDimmer || dimmer.opacity > 0) _updateDim()
    onYChanged: if (active || _activeDimmer || dimmer.opacity > 0) _updateDim()

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
        _updateDim()
        if (_inListView) {
            expandedStateTimer.restart()
        }
    }

    on_ActiveAllowedChanged: {
        if (!_activeAllowed && active) {
            close(true)
        }
    }

    function _findMenuItem(item) {
        if (!item.visible || !item.enabled) {
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
                var xPos = width/2
                if ((_pullDown && parentItem.mapToItem(child, xPos, yPos-topMargin).y < 0)
                        || (!_pullDown && parentItem.mapToItem(child, xPos, yPos).y > 0)) {
                    menuItem = child
                    highlightItem.highlight(menuItem, pulleyBase)
                    return menuItem
                }
            }
        }

        return null
    }

    function _highlightMenuItem(parentItem, yPos) {
        var child = _quickSelectMenuItem(parentItem, yPos)
        if (child) {
            return
        }

        var xPos = width/2
        child = parentItem.childAt(xPos, yPos)
        while (child) {
            if (child && child.hasOwnProperty("__silica_menuitem") && child.enabled) {
                menuItem = child
                highlightItem.highlight(menuItem, pulleyBase)
                break
            }
            parentItem = child
            yPos = parentItem.mapToItem(child, xPos, yPos).y
            child = parentItem.childAt(xPos, yPos)
        }
        if (!child) {
            menuItem = null
            highlightItem.clearHighlight()
        }
    }

    function hide() {
        if (active && _bounceBackEnabled) {
            delayedBounceTimer.restart()
        }
        menuItem = null
        highlightItem.clearHighlight()
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

    Rectangle {
        id: dimmer
        anchors.fill: parent
        anchors.bottomMargin: -_menuIndicatorItem.height/2 + (_isPullDownMenu ? spacing : 0)
        anchors.topMargin: -_menuIndicatorItem.height/2 + (!_isPullDownMenu ? spacing : 0)
        color: __silica_applicationwindow_instance.dimmedRegionColor
        opacity: flickable && flickable._pulleyDimmerActive ? 0.5 : 0.0
        Behavior on opacity { FadeAnimation {} }
        z: -1
    }

    HighlightBar {
        id: highlightItem
        color: pulleyBase.highlightColor
        audioEnabled: flickable.dragging
        opacityAnimationDuration: 75
        visible: active
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
                menuItem.clicked()
                hide()
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
            snapAnimation.stop()
        }
    }
    function _updateDim() {
        if (flickable === null) {
            return
        }
        var enable = active && !bounceBackAnimation.running
        var window = __silica_applicationwindow_instance
        var dimRect
        // 2 * screen height to ensure the whole view is covered even when quickly flicked closed
        var dimHeight = window._screenHeight * 2
        // still update dimmer geometry when deactivating
        if (_pullDown) {
            if (flickable.pushUpMenu && flickable.pushUpMenu.visible) {
                var pum = flickable.pushUpMenu
                dimHeight = pum.y - pum._menuIndicatorItem.height/2 + pum.spacing - y - height - _menuIndicatorItem.height/2 + spacing
            }
            dimHeight = Math.min(dimHeight, window._screenHeight * 2)
            dimRect = Qt.rect(0, height + _menuIndicatorItem.height/2 - spacing, width, dimHeight)
        } else {
            var menuIndicatorHalf = _menuIndicatorItem ? _menuIndicatorItem.height/2 : Theme.paddingLarge
            if (flickable.pullDownMenu && flickable.pullDownMenu.visible) {
                var pdm = flickable.pullDownMenu
                var pdmMenuIndicatorHalf = pdm._menuIndicatorItem ? pdm._menuIndicatorItem.height/2 : Theme.paddingLarge
                dimHeight = y - menuIndicatorHalf + spacing - pdm.y - pdm.height - pdmMenuIndicatorHalf + pdm.spacing
            }
            dimHeight = Math.min(dimHeight, window._screenHeight * 2)
            dimRect = Qt.rect(0, -dimHeight-menuIndicatorHalf + spacing, width, dimHeight)
        }
        _activeDimmer = enable
        window._dimItem(enable, pulleyBase, dimRect, [])
        if (!flickable._pulleyDimmerActive && !enable) {
            window._undimItem(pulleyBase)
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
    Connections {
        target: (active || _activeDimmer || dimmer.opacity > 0) ? _page : null
        ignoreUnknownSignals: true
        onOrientationChanged: pulleyBase._updateDim()
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
        duration: 350
        target: flickable
        property: "contentY"
        to: _inactivePosition
        onRunningChanged: _updateDim()
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
        onPressedOutside: { if (!flickAnimation.running && !flickable.moving) { menuItem = null; cancelTouch(); hide() } }
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
