/****************************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
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

/*
If this is made into public API, consider removing this type entirely and embedding the
auto-open/close functionality into ExpandingSection, because:
a) We don't have a "group" container type requirement elsewhere e.g. for list items with menus
b) It makes it look a section group can't have non-section items, and that expanding sections
   have to be more or less consecutive items within a page
*/
Column {
    id: root

    property int currentIndex: -1
    readonly property Item currentSection: _currentSection

    // don't use default of horizontalPageMargin, as arrow icons should be closer to the edge of the screen
    property real leftMargin: Theme.paddingMedium
    property real rightMargin: Theme.paddingMedium

    property int animationDuration: _initialized ? 200 : 0
    property bool animateToExpandedSection: true

    property bool _updating
    property bool _initialized
    property bool _retriedInitialize
    property Item _currentSection
    property Item _flickable
    property int __silica_expandingsectiongroup

    function indexOfSection(section) {
        var sectionIdx = 0
        for (var i=0; i<children.length; i++) {
            var child = _findSection(children[i])
            if (child) {
                if (child === section) {
                    return sectionIdx
                }
                ++sectionIdx
            }
        }
        return -1
    }

    function _findSection(item) {
        if (!item) {
            return null
        }
        if (item.hasOwnProperty("__silica_expandingsection")) {
            return item
        }
        for (var i=0; i<item.children.length; ++i) {
            var child = _findSection(item.children[i])
            if (child) {
                return child
            }
        }
        return null
    }

    function _updateActiveSection() {
        if (_updating) {
            return
        }
        _updating = true
        var newCurrentSection = null
        var sectionIdx = 0
        for (var i=0; i<children.length; i++) {
            var section = _findSection(children[i])
            if (section) {
                section.expanded = (sectionIdx == currentIndex)
                if (section.expanded) {
                    newCurrentSection = section
                }
                ++sectionIdx
            }
        }
        if (!_initialized && !newCurrentSection) {
            // couldn't find a current section on initialization; maybe the sections are e.g. in
            // a Repeater that has not laid out its children yet
            _currentSection = null
            if (!_retriedInitialize) {
                _retriedInitialize = true
                delayedInitialize.start()
            }
        } else {
            if (newCurrentSection && animateToExpandedSection) {
                _updateFlickableContentY(_currentSection, newCurrentSection)
            }
            _currentSection = newCurrentSection
            _initialized = true
        }
        _updating = false
    }

    function _updateFlickableContentY(oldSection, newSection) {
        if (!_flickable) {
            _flickable = Util.findFlickable(root)
        }
        if (!_flickable) {
            return
        }
        var sectionEndY = newSection.mapToItem(_flickable.contentItem, 0, newSection.content.y).y + newSection.buttonHeight + newSection.content.height
        if (sectionEndY > _flickable.contentY + _flickable.height) {
            var maxContentY = _flickable.contentHeight + newSection.content.height - _flickable.height - (oldSection ? oldSection.content.height : 0)
            var newContentY = Math.max(Math.min(sectionEndY - _flickable.height, maxContentY), 0)
            contentYAnimation.to = newContentY
            contentYAnimation.start()
        }
    }

    function _initializeActiveSection() {
        if (!_initialized && currentIndex >= 0 && currentIndex < children.length) {
            _updateActiveSection()
        }
    }

    width: parent ? parent.width : Screen.width

    onChildrenChanged: {
        // If _currentSection has disappeared and is no longer in this group, ensure the current index is reset
        if (_currentSection && indexOfSection(_currentSection) < 0) {
            _initialized = false
        }
        if (!_initialized) {
            _retriedInitialize = false
            _initializeActiveSection()
        }
    }

    onCurrentIndexChanged: {
        if (children.length > 0) {
            _updateActiveSection()
        }
    }

    Timer {
        id: delayedInitialize
        interval: 0
        onTriggered: {
            _initializeActiveSection()
        }
    }

    NumberAnimation {
        id: contentYAnimation
        target: _flickable
        property: "contentY"
        duration: root.animationDuration
    }
}
