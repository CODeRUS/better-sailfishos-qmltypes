/****************************************************************************************
**
** Copyright (C) 2020 Open Mobile Platform LLC.
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
import Nemo.Configuration 1.0
import "Util.js" as Util

Item {
    id: root

    property alias model: _tabButtons.model
    property bool _oversize: flickable.contentWidth > flickable.width
    property bool _contentOnRight: flickable.contentX >= (flickable.contentWidth - flickable.width)
    property bool _isFooter: tabRow._tabView.hasFooter
    readonly property bool _vanillaStyle: tabBarStyle.value === "vanilla"

    state: _isFooter ? "footer" : "header"
    height: flickable.height

    Flickable {
        id: flickable

        width: parent.width
        height: tabRow.height

        interactive: tabRow.flickable
        contentWidth: tabRow.contentWidth
        boundsBehavior: Flickable.StopAtBounds

        Behavior on contentX {
            id: contentXBehavior

            SmoothedAnimation {
                duration: 250
                velocity: Theme.pixelRatio * 500
                easing.type: Easing.InOutQuad
            }
        }

        TabButtonRow {
            id: tabRow

            property real extraMargin: root._oversize ? 0.0 : (root.width - tabRow.contentWidth) * 0.5

            Repeater {
                id: _tabButtons

                TabButton {
                    id: tabButton

                    extraMargin: (contentState === "first" || contentState === "last") ? tabRow.extraMargin : 0.0

                    onClicked: {
                        tabRow._tabView.moveTo(model.index)
                    }

                    onIsCurrentTabChanged: {
                        if (isCurrentTab) {
                            tabFooter.state = "undefined"
                            // Set a new active button as a reparenting target
                            tabFooter.nextParent = tabButton
                            tabFooter.state = root._vanillaStyle ? "reparented_vanilla" : "reparented"
                        }
                    }

                    contentState: {
                        if (tabIndex === 0) {
                            return "first"
                        } else if (tabIndex === tabRow._buttons.length - 1) {
                            return "last"
                        } else {
                            return "between"
                        }
                    }

                    title: model.title ? model.title : ""
                    icon.source: model.iconSource ? model.iconSource : ""
                    tabIndex: model.index
                    count: model.count ? model.count : 0
                }
            }

            onUpdatePosition: {
                contentXBehavior.enabled = animated
                flickable.contentX = root._oversize ? -pos : 0
            }
        }

        Item {
            id: transitionLine

            anchors {
                bottom: root._isFooter ? undefined : tabRow.bottom
                top: root._isFooter ? tabRow.top : undefined
            }
            height: Theme._lineWidth
            width: parent.width
        }
    }

    Rectangle {
        id: tabFooter

        property Item nextParent
        property bool animationDisabled

        width: nextParent.width
        height: Theme._lineWidth
        color: Theme.highlightColor

        anchors {
            bottom: root._isFooter ? undefined : parent.bottom
            top: root._isFooter ? parent.top : undefined
        }

        states: [
            State {
                name: "reparented"
                ParentChange {
                    target: tabFooter
                    parent: tabFooter.nextParent
                    x: 0
                }
                PropertyChanges {
                    target: tabFooter
                    width: tabFooter.nextParent.width
                }
            },
            State {
                name: "reparented_vanilla"

                ParentChange {
                    target: tabFooter
                    parent: tabFooter.nextParent
                    x: tabFooter.nextParent.contentItem.x
                }
                PropertyChanges {
                    target: tabFooter
                    width: tabFooter.nextParent.contentItem.width
                    anchors.margins: -Theme.paddingMedium
                }
                AnchorChanges {
                    target: tabFooter
                    anchors {
                        bottom: root._isFooter ? undefined : tabFooter.nextParent.contentItem.bottom
                        top: root._isFooter ? tabFooter.nextParent.contentItem.top : undefined
                    }
                }
            }
        ]

        transitions: Transition {
            ParentAnimation {
                NumberAnimation {
                    properties: "x, width"
                    duration: tabFooter.animationDisabled ? 0 : 250
                    easing.type: Easing.InOutQuad
                }
                via: transitionLine
            }
        }

        Behavior on width {
            PropertyAnimation {
                duration: tabFooter.animationDisabled ? 0 : 200
                easing.type: Easing.InOutQuad
            }
        }

        Timer {
            // turn animation on in a half sec
            running: true
            interval: 500
            onTriggered: tabFooter.animationDisabled = false
        }
    }

    Component.onCompleted: {
        // disable animation for a half sec to avoid slight movement during initialization
        tabFooter.animationDisabled = true
        if (tabRow._tabView.currentIndex >= 0 && tabRow._tabView.currentIndex < tabRow._buttons.length) {
            tabFooter.parent = tabRow._buttons[tabRow._tabView.currentIndex]
        }
    }

    OpacityRampEffect {
        id: leftRamp

        sourceItem: flickable
        enabled: root._oversize && flickable.contentX > 0

        direction: OpacityRamp.RightToLeft

        slope: Math.max(
                   1 + 6 * root.width / Screen.width,
                   root.width / Math.max(1, flickable.contentX))
        offset: 1 - 1 / slope
    }

    OpacityRampEffect {
        sourceItem: leftRamp.enabled ? leftRamp : flickable
        enabled: root._oversize && flickable.contentX < flickable.contentWidth - flickable.width

        direction: OpacityRamp.LeftToRight

        slope: Math.max(
                   1 + 6 * root.width / Screen.width,
                   root.width / Math.max(1, flickable.contentWidth - flickable.width - flickable.contentX))
        offset: 1 - 1 / slope
    }

    Rectangle {
        id: horizontalLine

        visible: !root._vanillaStyle
        color: Theme.rgba(Theme.highlightColor, Theme.opacityLow)
        height: Theme._lineWidth
        anchors.left: parent.left
        anchors.right: parent.right
    }

    states: [
        State {
            name: "header"
            AnchorChanges {
                target: horizontalLine
                anchors.bottom: root.bottom
                anchors.top: undefined
            }
        },
        State {
            name: "footer"
            AnchorChanges {
                target: horizontalLine
                anchors.bottom: undefined
                anchors.top: root.top
            }
        }
    ]

    ConfigurationValue {
        id: tabBarStyle
        key: '/desktop/sailfish/silica/tab_bar_style'
        defaultValue: "vanilla"
    }
}
