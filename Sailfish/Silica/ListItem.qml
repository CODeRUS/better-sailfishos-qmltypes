/****************************************************************************************
**
** Copyright (C) 2014 Jolla Ltd.
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

BackgroundItem {
    id: listItem
    property variant menu
    property bool menuOpen: _menuItem != null && _menuItem._open
    property bool showMenuOnPressAndHold: true

    property Item _menuItem
    property bool _menuItemCreated
    property bool _connectPressAndHold: showMenuOnPressAndHold && menu !== null && menu !== undefined

    // If this item is removed by a RemorseItem, do not restore visibility
    // This binding should be removed when JB#8682 is addressed
    property bool __silica_item_removed
    Binding on opacity {
        when: __silica_item_removed
        value: 0.0
    }

    onMenuOpenChanged: {
        if (ListView.view && ('__silica_contextmenu_instance' in ListView.view)) {
            ListView.view.__silica_contextmenu_instance = menuOpen ? _menuItem : null
        }
    }

    function remorseAction(text, action, timeout) {
        // null parent because a reference is held by RemorseItem until
        // it either triggers or is cancelled.
        var remorse = remorseComponent.createObject(null)
        remorse.execute(contentItem, text, action, timeout)
        return remorse
    }

    function animateRemoval(delegate) {
        if (delegate === undefined) {
            delegate = listItem
        }
        removeComponent.createObject(delegate, { "target": delegate })
    }

    function showMenu(properties) {
        if (menu == null) {
            return null
        }
        if (_menuItem == null) {
            _initMenuItem(properties)
        } else {
            for (var prop in properties) {
                if (prop in _menuItem) {
                    _menuItem[prop] = properties[prop];
                }
            }
        }
        if (_menuItem) {
            _menuItem.show(listItem)
        }
        return _menuItem
    }

    function _initMenuItem(properties) {
        if (_menuItem || (menu == null)) {
            return
        }
        var result
        if (menu.createObject !== undefined) {
            result = menu.createObject(listItem, properties || {})
            _menuItemCreated = true
            result.closed.connect(function() { _menuItem.destroy() })
        } else {
            result = menu
            _menuItemCreated = false
            for (var prop in properties) {
                if (prop in result) {
                    result[prop] = properties[prop];
                }
            }
        }
        _menuItem = result
    }

    function hideMenu() {
        if (_menuItem != null) {
            _menuItem.hide()
        }
    }

    highlighted: down || menuOpen
    height: menuOpen ? _menuItem.height + contentItem.height : contentItem.height
    contentHeight: Theme.itemSizeSmall
    _backgroundColor: Theme.rgba(Theme.highlightBackgroundColor, _showPress && !menuOpen ? Theme.highlightBackgroundOpacity : 0)

    on_ConnectPressAndHoldChanged: {
        if (_connectPressAndHold)
            listItem.pressAndHold.connect(handlePressAndHold)
        else
            listItem.pressAndHold.disconnect(handlePressAndHold)
    }

    function handlePressAndHold() {
        if (down)
            showMenu()
    }

    onMenuChanged: {
        if (menu != null && _menuItem != null && _menuItemCreated) {
            // delete the previously created context menu instance
            _menuItem.destroy()
        }
    }

    Component {
        id: remorseComponent
        RemorseItem { }
    }

    Component {
        id: removeComponent
        RemoveAnimation {
            running: true
        }
    }

    Component.onDestruction: {
        if (_menuItem != null) {
            _menuItem.hide()
            _menuItem._parentDestroyed()
        }

        // This item must not be removed if reused in an ItemPool
        __silica_item_removed = false
    }
}
