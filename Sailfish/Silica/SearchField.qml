/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jollamobile.com>
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

TextField {
    id: searchField

    property bool canHide
    property bool active: true
    property int transitionDuration: 200

    property bool _initialized

    signal hideClicked()

    implicitWidth: _editor.implicitWidth + Theme.paddingSmall
                   + Theme.itemSizeSmall*2  // width of two icons
    implicitHeight: Math.max(Theme.itemSizeMedium, _editor.height + Theme.paddingMedium + Theme.paddingSmall)  + (labelVisible ? _labelItem.height : 0)

    focusOutBehavior: FocusBehavior.ClearPageFocus
    font {
        pixelSize: Theme.fontSizeLarge
        family: Theme.fontFamilyHeading
    }

    textLeftMargin: Theme.itemSizeSmall + Theme.paddingMedium + Theme.horizontalPageMargin - Theme.paddingLarge
    textRightMargin: text.length == 0 ? Theme.horizontalPageMargin
                                      : Theme.itemSizeSmall + Theme.paddingMedium + Theme.horizontalPageMargin - Theme.paddingLarge
    textTopMargin: height/2 - _editor.implicitHeight/2
    labelVisible: false

    //: Placeholder text of SearchField
    //% "Search"
    placeholderText: qsTrId("components-ph-search")
    onFocusChanged: if (focus) cursorPosition = text.length

    inputMethodHints: Qt.ImhNoPredictiveText
    background: null

    Component.onCompleted: {
        _initialized = true
    }

    Item {
        parent: searchField // avoid TextBase contentItem auto-parenting
        anchors.fill: parent

        IconButton {
            x: searchField.textLeftMargin - width - Theme.paddingSmall
            width: icon.width
            height: parent.height
            icon.source: "image://theme/icon-m-search"
            highlighted: down || searchField._editor.activeFocus

            enabled: searchField.enabled

            onClicked: {
                searchField._editor.forceActiveFocus()
            }
        }

        IconButton {
            id: clearButton
            anchors {
                right: parent.right
                rightMargin: Theme.horizontalPageMargin
            }
            width: icon.width
            height: parent.height
            icon.source: searchField.canHide
                         ? "image://theme/icon-m-input-remove"
                         : (searchField.text.length > 0 ? "image://theme/icon-m-clear" : "")

            enabled: searchField.enabled

            opacity: icon.status === Image.Ready ? 1 : 0
            Behavior on opacity {
                FadeAnimation {}
            }

            onClicked: {
                if (searchField.canHide) {
                    searchField.hideClicked()
                } else {
                    searchField.text = ""
                }
            }
        }
    }

    states: State {
        name: "inactive"
        when: !searchField.active

        PropertyChanges { target: searchField; height: 0; opacity: 0; clip: true }
        PropertyChanges { target: searchField._editor; focus: false }
    }

    transitions: [
        Transition {
            from: ""; to: "inactive"
            enabled: searchField._initialized

            SequentialAnimation {
                NumberAnimation { duration: searchField.transitionDuration; easing.type: Easing.InOutQuad; properties: "opacity,height" }
                PropertyAction { target: searchField; property: "visible"; value: false }
                PropertyAction { target: searchField; property: "text"; value: "" }
            }
        },

        Transition {
            from: "inactive"; to: ""
            enabled: searchField._initialized

            SequentialAnimation {
                PropertyAction { target: searchField; property: "visible"; value: true }
                NumberAnimation { duration: searchField.transitionDuration; easing.type: Easing.InOutQuad; properties: "opacity,height" }
            }
        }
    ]
}
