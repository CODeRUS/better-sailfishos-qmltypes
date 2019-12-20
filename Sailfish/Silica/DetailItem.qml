/****************************************************************************************
**
** Copyright (C) 2014-2015 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC.
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

import QtQuick 2.6
import Sailfish.Silica 1.0

SilicaItem {
    id: detailItem

    width: parent.width
    height: Math.max(labelText.y*2 + labelText.height, valueText.y + valueText.height + Theme.paddingSmall)

    property alias label: labelText.text
    property alias value: valueText.text
    property alias valueFont: valueText.font
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Theme.horizontalPageMargin
    // supported: Qt.AlignHCenter and Qt.AlignLeft
    property int alignment: Qt.AlignHCenter

    // only for edge aligned content
    property bool forceValueBelow
    property alias _valueItem: valueText
    readonly property bool _center: alignment === Qt.AlignHCenter

    Text {
        id: labelText

        y: Theme.paddingSmall
        anchors {
            left: parent.left
            leftMargin: detailItem.leftMargin
            right: _center ? parent.horizontalCenter : parent.right
            rightMargin: _center ? Theme.paddingSmall : detailItem.rightMargin
        }
        horizontalAlignment: _center ? Text.AlignRight : Text.AlignLeft
        color: palette.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeSmall
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
    }

    Text {
        id: valueText

        property bool valueBelow: detailItem.forceValueBelow
                                  || ((labelText.implicitWidth + valueText.implicitWidth)
                                      > (detailItem.width - 2*Theme.horizontalPageMargin - 2*Theme.paddingSmall))
        y: (!_center && valueBelow ? (labelText.y + labelText.height) : 0) + Theme.paddingSmall
        anchors {
            left: _center ? parent.horizontalCenter : parent.left
            leftMargin: _center ? Theme.paddingSmall
                                : (valueBelow ? detailItem.leftMargin
                                              : (labelText.x + labelText.implicitWidth + 2*Theme.paddingSmall))
            right: parent.right
            rightMargin: detailItem.rightMargin
        }
        horizontalAlignment: Text.AlignLeft
        color: detailItem.palette.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        textFormat: Text.PlainText
        wrapMode: Text.Wrap
    }
}
