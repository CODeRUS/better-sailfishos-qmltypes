/****************************************************************************************
**
** Copyright (C) 2019 Jolla Ltd.
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

import QtQuick 2.4
import QtQml.Models 2.2
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "Util.js" as Util

SilicaControl {
    id: root

    property alias model: delegateModel.model
    property int currentIndex
    property alias header: headerLoader.sourceComponent
    property alias headerItem: headerLoader.item
    property real headerHeight: headerItem ? headerItem.height : 0
    property alias moving: slideable.moving
    property alias panning: slideable.panning
    readonly property int count: delegateModel.items.count
    property real yOffset: slideable.currentItem && slideable.currentItem.hasOwnProperty("__silica_tab_container") ? slideable.currentItem.yOffset : 0
    readonly property alias slideProgress: slideable.progress
    property bool _initialized

    property Item _page: Util.findPage(root)
    property int _nextIndex: -1
    property int _previousIndex: -1

    readonly property int _currentItemIndex: slideable.currentItem
                ? slideable.currentItem.DelegateModel.itemsIndex
                : -1

    property int __silica_tab_view

    Component.onCompleted: {
        _initialized = true

        if (!slideable.currentItem) {
            moveTo(currentIndex, TabViewAction.Immediate)
        }
    }

    function moveTo(index, operationType) {
        if (!_initialized) {
            currentIndex = index
        } else if (index >= 0 && index < count) {
            var item = _ensureItem(index)

            if (item) {
                slideable.setCurrentItem(
                            item,
                            operationType !== TabViewAction.Immediate,
                            _currentItemIndex > index ? Slide.Forward : Slide.Backward)
            }
        }
    }

    function _ensureItem(index) {
        var item = delegateModel.items.create(index)
        if (item) {
            slideable.cache(item)

            item.Slide._view = slideable
        }
        return item
    }

    onCurrentIndexChanged: {
        if (_initialized && currentIndex != _currentItemIndex) {
            moveTo(currentIndex, TabViewAction.Animated)
        }
    }

    on_CurrentItemIndexChanged: {
        if (_initialized && currentIndex != _currentItemIndex) {
            _previousIndex = currentIndex
            currentIndex = _currentItemIndex
        }
    }

    Item {
        z: 1
        width: parent.width
        height: headerLoader.height
        Loader {
            id: headerLoader

            width: parent.width
            y: Math.max(0, -root.yOffset)

            Wallpaper {
                anchors.fill: parent
                visible: root.yOffset >= 0
                anchors.topMargin: Math.max(0, Theme.paddingLarge - root.yOffset)
                anchors.rightMargin: root.moving ? 0 : Theme.paddingMedium
                windowRotation: _page ? _page.rotation : 0
            }
        }
    }

    Slideable {
        id: slideable
        y: headerLoader.height
        width: parent.width
        height: parent.height - y

        // Offload any tab that has been inactive for more than 5 minutes (5*60*1000)
        cacheSize: 0
        cacheExpiry: 300000

        focus: true

        onCreateAdjacentItem: {
            var index = item.DelegateModel.itemsIndex
            var adjacentItem
            if (direction === Slide.Forward) {
                if ((adjacentItem = root._ensureItem(index === delegateModel.items.count - 1 ? 0 : index + 1))) {
                    adjacentItem.Slide.backward = item
                    item.Slide.forward = adjacentItem
                }
            } else if (direction === Slide.Backward) {
                if ((adjacentItem = root._ensureItem(index === 0 ? delegateModel.items.count - 1 : index - 1))) {
                    adjacentItem.Slide.forward = item
                    item.Slide.backward = adjacentItem
                }
            }
        }
    }

    DelegateModel {
        id: delegateModel

        items.onChanged: {
            var insertIndex = 0
            for (var persistentIndex = 0;
                    persistentIndex < persistedItems.count && insertIndex < inserted.length;
                    ++persistentIndex) {
                var item = persistedItems.create(persistentIndex)   // This doesn't actually create an item because it's iterating a list of already created items.
                var modelIndex = item.DelegateModel.itemsIndex
                do {
                    var insert = inserted[insertIndex]

                    if (insert.index - 1 === modelIndex) {
                        // A new item was inserted in front of a cached item.
                        item.Slide.forward = null
                        break
                    } else if (insert.index + insert.count === modelIndex) {
                        // A new item was inserted behind a cached item.
                        item.Slide.backward = null
                        break
                    } else if (insert.index < modelIndex) {
                        ++insertIndex
                    } else {
                        break
                    }
                } while (insertIndex < inserted.length)
            }
        }

        delegate: FocusScope {
            // tab container
            id: delegate

            readonly property bool isCurrentItem: Slide.isCurrent
            property real yOffset
            property bool hasPulley

            readonly property bool _isNextTab: delegate === slideable.alternateItem
                    && (Slide.forward === slideable.currentItem || Slide.backward === slideable.currentItem)

            on_IsNextTabChanged: {
                if (_isNextTab) {
                    _nextIndex = model.index
                } else if (_nextIndex == model.index) {
                    _nextIndex = -1
                }
            }

            parent: slideable.contentItem
            width: slideable.width
            height: slideable.height
            clip: !isCurrentItem || !hasPulley
            visible: Slide.isExposed

            property int __silica_tab_container

            Component.onCompleted: {
                slideable.cache(delegate)

                DelegateModel.inPersistedItems = Qt.binding(function() {
                    return Slide.keepAlive || Slide.inCache
                })

                if (root.currentIndex === index && root._currentItemIndex === -1) {
                    slideable.setCurrentItem(delegate, false)
                }
            }

            Slide.isFirst: false
            Slide.isLast: false
            Slide.keepAlive: tabLoader.status === Loader.Loading
                    || (tabLoader.item && !tabLoader.item.allowDeletion)

            Loader {
                id: tabLoader

                sourceComponent: modelData
                opacity: !!item ? 1.0 : 0.0
                Behavior on opacity { FadeAnimation {}}
                asynchronous: true
                anchors {
                    fill: parent
                    topMargin: hasPulley ? -root.headerHeight : 0
                }
            }

            BusyIndicator {
                property bool loading: Qt.application.active && isCurrentItem && tabLoader.status !== Loader.Ready
                running: !delayBusy.running && loading

                y: Screen.height/3 - height/2 - headerLoader.height
                anchors.horizontalCenter: parent.horizontalCenter
                size: BusyIndicatorSize.Large

                Timer {
                    id: delayBusy
                    interval: 800
                    running: parent.loading
                }
            }
        }
    }
}
