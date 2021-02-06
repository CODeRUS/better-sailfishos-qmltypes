/****************************************************************************************
**
** Copyright (C) 2019 - 2020 Open Mobile Platform LLC.
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
import Sailfish.Silica.private 1.0
import "Util.js" as Util

MouseArea {
    id: root

    property int tabIndex: -1
    property bool isCurrentTab: _tabView && _tabView.currentIndex >= 0 && _tabView.currentIndex === tabIndex

    property string title
    property alias icon: highlightImage
    property int count

    property Item _page
    readonly property bool _portrait: _page && _page.isPortrait
    readonly property Item _tabView: Util.findParentWithProperty(root, '__silica_tab_view')
    readonly property bool _becomingCurrentTab: _tabView && _tabView._nextIndex === tabIndex
    property bool _activatingByClick
    property alias contentItem: contentColumn
    property alias contentState: contentColumn.state
    property real extraMargin
    // contentWidth is used to calculate TabButtonRow width except of extraMargin
    property real contentWidth: 2 * Theme.paddingLarge + contentColumn.implicitWidth
                                + (bubble.active && highlightImage.width === 0 ? bubble.width : 0)
    implicitWidth: contentWidth + extraMargin

    implicitHeight: Math.max(_portrait ? Theme.itemSizeLarge : Theme.itemSizeSmall,
                             contentColumn.implicitHeight + 2 * (_portrait ? Theme.paddingLarge : Theme.paddingMedium))

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

    Column {
        id: contentColumn

        anchors.verticalCenter: parent.verticalCenter
        anchors.horizontalCenterOffset: bubble.active && highlightImage.width === 0 ? -bubble.width*0.5 : 0

        HighlightImage {
            id: highlightImage

            anchors.horizontalCenter: parent.horizontalCenter
            highlighted: (pressed && containsMouse)
                         || _activatingByClick || root.isCurrentTab
        }

        Loader {
            active: root.title
            visible: active
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: Component {
                Label {
                    text: root.title
                    color: (pressed && containsMouse)
                           || _activatingByClick ? Theme.highlightColor : colorInterpolator.value
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: {
                        if (highlightImage.height > 0) {
                            return Theme.fontSizeTiny
                        } else if (root.parent && root.parent._buttonFontSize) {
                            return root.parent._buttonFontSize
                        } else {
                            return Theme.fontSizeLarge
                        }
                    }
                }
            }
        }

        state: "between"

        states: [
            State {
                name: "first"
                AnchorChanges {
                    target: contentColumn
                    anchors {
                        horizontalCenter: undefined
                        left: undefined
                        right: parent.right
                    }
                }
                PropertyChanges {
                    target: contentColumn
                    anchors.rightMargin: Theme.paddingMedium
                }
            },
            State {
                name: "between"
                AnchorChanges {
                    target: contentColumn
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                    }
                }
            },
            State {
                name: "last"
                AnchorChanges {
                    target: contentColumn
                    anchors {
                        horizontalCenter: undefined
                        right: undefined
                        left: parent.left
                    }
                }
                PropertyChanges {
                    target: contentColumn
                    anchors.leftMargin: Theme.paddingMedium
                }
            }
        ]
    }

    Loader {
        id: bubble

        y: Theme.paddingLarge
        active: root.count
        asynchronous: true
        opacity: (pressed && containsMouse) || _activatingByClick ? 0.8 : 1.0
        anchors {
            left: contentColumn.right
            leftMargin: Theme.dp(4)
        }
        sourceComponent: Component {
            Rectangle {
                color: Theme.highlightBackgroundColor
                width: bubbleLabel.text ? Math.max(bubbleLabel.implicitWidth + Theme.paddingSmall*2, height) : Theme.paddingMedium + Theme.paddingSmall
                height: bubbleLabel.text ? bubbleLabel.implicitHeight : Theme.paddingMedium + Theme.paddingSmall
                radius: Theme.dp(2)

                Label {
                    id: bubbleLabel

                    text: {
                        if (root.count < 0) {
                            return ""
                        } else if (root.count > 99) {
                            return "99+"
                        } else {
                            return root.count
                        }
                    }

                    anchors.centerIn: parent
                    font.pixelSize: Theme.fontSizeTiny
                    font.bold: true
                }
            }
        }
        states: State {
            when: highlightImage.width > 0
            name: "withicon"
            AnchorChanges {
                target: bubble
                anchors {
                    horizontalCenter: contentColumn.horizontalCenter
                    verticalCenter: undefined
                    left: undefined
                }
            }
            PropertyChanges {
                target: bubble
                anchors {
                    horizontalCenterOffset: highlightImage.width * 0.5
                    leftMargin: 0
                }
            }
        }
    }
}
