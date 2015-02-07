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
import "private"
import "private/Util.js" as Util

ValueButton {
    id: comboBox

    property Item menu

    // Setting currentItem to a non-enabled or non-MenuItem-child object
    // will clear the selection. Is this what we want or should it track
    // the 'previous' currentItem and index and revert to those?

    property int currentIndex   // setting to invalid index clears the selection
    property Item currentItem   // setting to null or invalid item clears the selection

    property bool _updating
    property bool _completed
    property bool _currentIndexSet
    property bool _menuOpen: menu !== null && menu.parent === comboBox
    property Page _menuDialogItem

    height: _menuOpen ? menu.height + contentItem.height : contentItem.height
    value: (currentItem !== null && currentItem.text !== "") ? currentItem.text : ""

    onCurrentIndexChanged: {
        _currentIndexSet = true
        if (_completed && !_updating) {
            _updating = true
            _updateCurrent(currentIndex, null)
            _updating = false
        }
    }

    onCurrentItemChanged: {
        if (_completed && !_updating) {
            _updating = true
            _updateCurrent(-1, currentItem)
            _updating = false
        }
    }

    onClicked: {
        if (!comboBox.menu) {
            return
        }
        var needSeparateDialog = false
        var menuChildrenCount = 0
        for (var i=0; i<menu._contentColumn.children.length; i++) {
            var child = menu._contentColumn.children[i]
            if (child && child.visible && child.hasOwnProperty("__silica_menuitem")) {
                if (++menuChildrenCount > 6) {
                    needSeparateDialog = true
                    break
                }
            }
        }
        if (needSeparateDialog) {
            _menuDialogItem = pageStack.push(menuDialogComponent)
        } else {
            comboBox.menu.show(comboBox)
        }
    }

    Component.onCompleted: {
        if (menu) {
            _loadCurrent()
        }
        _completed = true
    }

    function _clearCurrent() {
        currentIndex = -1
        currentItem = null
        comboBox.menu._setHighlightedItem(null)
    }

    function _resetCurrent() {
        _updating = true
        currentIndex = 0
        _currentIndexSet = false
        currentItem = null
        _updating = false
    }

    function _loadCurrent() {
        if (currentIndex == -1 && currentItem == null) {
            _clearCurrent()
        } else {
            if (currentItem != null) {
                _updateCurrent(-1, currentItem)
            } else {
                _updateCurrent(currentIndex, null)
            }
        }
    }

    function _updateCurrent(newIndex, newItem) {
        if (!menu) {
            return
        }
        if (newIndex < 0 && newItem === null) {
            _clearCurrent()
            return
        }

        var menuItemIndex = -1
        var matched = false
        for (var i=0; i<menu._contentColumn.children.length; i++) {
            var child = menu._contentColumn.children[i]
            if (child && child.hasOwnProperty("__silica_menuitem")) {
                menuItemIndex++
                if (newIndex >= 0 ? newIndex === menuItemIndex : child === newItem) {
                    if (child.enabled) {
                        currentIndex = menuItemIndex
                        currentItem = child
                        if (menu.active) {
                            _highlightCurrent()
                        }
                        matched = true
                    }
                    break
                }
            }
        }
        if (!matched) {
            if (newIndex >= 0 && _currentIndexSet) {
                console.log("ComboBox: specified currentIndex has invalid value", newIndex)
                _clearCurrent()
            } else if (currentItem !== null) {
                console.log("ComboBox: specified currentItem has enabled=false or is not a MenuItem child")
                _clearCurrent()
            }
        }
    }

    function _highlightCurrent() {
        comboBox.menu._setHighlightedItem(currentItem)
    }

    Connections {
        target: comboBox.menu
        onActivated: {
            comboBox.currentIndex = index
        }
    }
    Connections {
        target: comboBox.menu ? comboBox.menu._contentColumn : null
        onChildrenChanged: {
            // delay the reload in case there are more children changes to come
            if (!updateCurrentTimer.running) {
                _updating = true
                updateCurrentTimer.start()
            }
        }
    }

    Timer {
        id: updateCurrentTimer
        interval: 1
        onTriggered: {
            _updating = false
            // ignore if no current index was set
            if (comboBox.currentItem === null && comboBox.currentIndex < 0) {
                return
            }
            var menuItems = comboBox.menu._contentColumn.children
            var foundOldCurrentItem = false
            for (var i=0; i<menuItems.length; i++) {
                if (menuItems[i] === comboBox.currentItem) {
                    foundOldCurrentItem = true
                    break
                }
            }
            // ContextMenu has completely changed its items, so reload the combo box
            if (!foundOldCurrentItem) {
                comboBox._resetCurrent()
            }
            comboBox._loadCurrent()
        }
    }

    Component {
        id: menuDialogComponent

        Page {
            anchors.fill: parent

            Component.onCompleted: {
                menu.height = 1 // XXX hack to allow us to check the MenuItems visibilities
                var menuItems = comboBox.menu.children
                for (var i = 0; i < menuItems.length; i++) {
                    var child = menuItems[i]
                    if (child && child.visible && child.hasOwnProperty("__silica_menuitem")) {
                        items.append( {"item": child } )
                    }
                }
                menu.height = 0
            }

            ListModel {
                id: items
            }

            SilicaListView {
                id: view

                anchors.fill: parent
                model: items

                header: PageHeader {
                    title: comboBox.label
                }

                delegate: BackgroundItem {
                    id: delegateItem

                    onClicked: {
                        model.item.clicked()
                        comboBox.menu.activated(index)
                        pageStack.pop()
                    }

                    Label {
                        x: Theme.paddingLarge
                        anchors.verticalCenter: parent.verticalCenter
                        width: parent.width - x*2
                        wrapMode: Text.Wrap
                        text: model.item.text
                        color: (delegateItem.highlighted || model.item === comboBox.currentItem)
                               ? Theme.highlightColor
                               : Theme.primaryColor
                    }
                }
                VerticalScrollDecorator {}
            }
        }
    }

    states: State {
        when: comboBox.menu && comboBox.menu.active

        StateChangeScript {
            script: {
                if (!comboBox.currentItem) {
                    comboBox._loadCurrent()
                }
                if (comboBox.currentItem) {
                    comboBox._highlightCurrent()
                }
            }
        }
    }
}
