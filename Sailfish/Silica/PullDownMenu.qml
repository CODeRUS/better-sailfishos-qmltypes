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
import "private"
import "private/Util.js" as Util

PulleyMenuBase {
    id: pullDownMenu

    property real topMargin: Theme.itemSizeSmall
    property real bottomMargin
    default property alias _content: contentColumn.children

    spacing: 0
    y: flickable.originY - height

    _contentColumn: contentColumn
    _isPullDownMenu: true
    _inactiveHeight: 0
    _activeHeight: contentColumn.height + Theme.paddingLarge + topMargin + bottomMargin
    _inactivePosition: Math.round(flickable.originY - (_inactiveHeight + spacing))
    _finalPosition: _inactivePosition - _activeHeight

    property Component background: Rectangle {
        anchors { fill: parent; bottomMargin: parent.spacing }
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(pullDownMenu.backgroundColor, Theme.highlightBackgroundOpacity) }
            GradientStop { position: 0.5; color: Theme.rgba(pullDownMenu.backgroundColor, Theme.highlightBackgroundOpacity) }
            GradientStop { position: 1.0; color: Theme.rgba(pullDownMenu.highlightColor, 2*Theme.highlightBackgroundOpacity) }
        }
    }

    property Component menuIndicator: MenuIndicator {
        color: pullDownMenu.enabled ? pullDownMenu.highlightColor : Theme.primaryColor
        opacity: pullDownMenu.enabled ? 1 : 0.5
        busy: pullDownMenu.busy
        anchors {
            verticalCenter: parent.bottom
            verticalCenterOffset: -parent.spacing
        }
    }

    property Item _pageStack: Util.findPageStack(pullDownMenu)

    onActiveChanged: {
        if (_pageStack) {
            _pageStack._activePullDownMenu = active ? pullDownMenu : null
        }
    }

    Column {
        id: contentColumn

        property int __silica_pulleymenu_content

        property real menuContentY: pullDownMenu.active ? flickable.contentY - (_inactivePosition - _activeHeight) : -1
        onMenuContentYChanged: {
            if (menuContentY >= 0) {
                if (flickable.dragging && !_bounceBackRunning) {
                    _highlightMenuItem(contentColumn, menuContentY - Theme.paddingMedium)
                } else if (quickSelect){
                    _quickSelectMenuItem(contentColumn, menuContentY - Theme.paddingMedium)
                }
            }
        }

        y: pullDownMenu.topMargin
        width: parent.width
        visible: active
    }

    Binding {
        target: flickable
        property: "topMargin"
        value: pullDownMenu.height
    }

    // Create a bottomMargin to fill the remaining space in views
    // with content size < view height.  This allows the view to
    // be positioned above the bottomMargin even when
    // its content is smaller than the available space.
    Binding {
        when: !flickable.pushUpMenu  // If there is a PushUpMenu then it will take care of it.
        target: flickable
        property: "bottomMargin"
        value: Math.max(flickable.height - flickable.contentHeight - (_inactiveHeight + pullDownMenu.spacing), 0)
    }

    // If the content size is less than view height and there is no
    // push up menu, then we must also prevent moving in the wrong direction
    property real _maxDragPosition: Math.min(flickable.height - flickable.contentHeight, _inactivePosition)

    function _addToFlickable(flickableItem) {
        if (flickableItem.pullDownMenu !== undefined) {
            flickableItem.pullDownMenu = pullDownMenu
        } else {
            console.log('Warning: PullDownMenu must be added to an instance of SilicaFlickable.')
        }
    }

    // for testing
    function _menuContentY() {
        return contentColumn.menuContentY
    }

    Component.onCompleted: {
        if (background) {
            background.createObject(pullDownMenu, {"z": -2})
        }
        if (menuIndicator) {
            _menuIndicatorItem = menuIndicator.createObject(pullDownMenu, {"z": -1})
        }
        _updateFlickable()
    }
}
