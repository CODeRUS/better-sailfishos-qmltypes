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

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0
import "Util.js" as Util

MouseArea {
    id: root

    property int tabIndex: -1
    property bool isCurrentTab: _tabView && _tabView.currentIndex >= 0 && _tabView.currentIndex === tabIndex
    property alias title: label.text

    property Item _page
    readonly property bool _portrait: _page && _page.isPortrait
    readonly property Item _tabView: Util.findParentWithProperty(root, '__silica_tab_view')
    readonly property bool _becomingCurrentTab: _tabView && _tabView._nextIndex === tabIndex
    property bool _activatingByClick

    implicitWidth: 2 * label.x + label.width
    implicitHeight: Math.max(_portrait ? Theme.itemSizeLarge : Theme.itemSizeSmall,
                             label.implicitHeight + 2 * (_portrait ? Theme.paddingLarge : Theme.paddingMedium))


    Component.onCompleted: {
        if (!parent.hasOwnProperty("__silica_tab_button_row")) {
            console.warn("TabButton should be always created within TabButtonRow")
        }
        _page = Util.findPage(root)
        parent._registerButton(root)
    }

    Component.onDestruction: parent._deregisterButton(root)

    onClicked: {
        _activatingByClick = true
    }

    Connections {
        target: _tabView
        onMovingChanged: {
            if (!_tabView.moving) {
                _activatingByClick = false
            }
        }
    }

    VariantInterpolator {
        id: colorInterpolator

        from: {
            if (_becomingCurrentTab) {
                return palette.primaryColor
            } else if (isCurrentTab) {
                return palette.highlightColor
            }
            return palette.primaryColor
        }

        to: {
            if (_becomingCurrentTab) {
                return palette.highlightColor
            } else if (isCurrentTab) {
                return palette.primaryColor
            }
            return palette.primaryColor
        }

        progress: {
            if (!_tabView || _activatingByClick) {
                return 0
            }
            // Gradually adjust the button text color when the current tab changes.
            // The progress goes from 0->1 when the slideable is panned, then 1->0 when the
            // slideable is released and animates automatically towards the new index, so to
            // use the progress value for interpolation it must be inversed when the
            // alternate item becomes the current item.
            var exitingCurrentTab = (isCurrentTab && _tabView._nextIndex >= 0 && _tabView._nextIndex !== tabIndex)
            if (tabIndex === _tabView._previousIndex || exitingCurrentTab) {
                return _tabView.slideProgress
            } else if (_becomingCurrentTab) {
                return isCurrentTab ? 1 - _tabView.slideProgress : _tabView.slideProgress
            } else if (isCurrentTab) {
                return _tabView.slideProgress
            } else {
                return 0
            }
        }
    }

    Label {
        id: label

        height: parent.height
        x: Theme.paddingMedium

        color: (pressed && containsMouse) || _activatingByClick
               ? Theme.highlightColor
               : colorInterpolator.value
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: root.parent && root.parent._buttonFontSize ? root.parent._buttonFontSize
                                                                   : Theme.fontSizeLarge
    }
}
