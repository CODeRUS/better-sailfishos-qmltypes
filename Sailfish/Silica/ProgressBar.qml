/****************************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Martin Jones <martin.jones@jollamobile.com>
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

Item {
    id: progressBar

    property real maximumValue: 1.0
    property real minimumValue: 0.0
    property real value: 0.0
    property real progressValue: Math.max(minimumValue, Math.min(maximumValue, value))
    property bool indeterminate
    property string valueText
    property alias label: labelText.text
    property real leftMargin: Math.round(Screen.width/8)
    property real rightMargin: Math.round(Screen.width/8)

    property alias _timer: progressBarTimer
    property real _grooveWidth: Math.max(0, width - leftMargin - rightMargin)
    property real _glassItemPadding: background.height/2
    property Item _valueTextItem
    property bool highlighted

    implicitHeight: contentColumn.y + contentColumn.height + Theme.paddingSmall

    onValueTextChanged: {
        if (valueText && !_valueTextItem) {
            _valueTextItem = valueIndicatorComponent.createObject(valueTextPlaceholder)
        }
    }

    Column {
        id: contentColumn

        y: Theme.paddingSmall
        width: parent.width

        // compensate empty space in GlassItem
        spacing: -Theme.paddingSmall - (Theme.colorScheme === Theme.DarkOnLight ? Theme.paddingLarge : 0)
                 + (indeterminate ? (Theme.colorScheme === Theme.DarkOnLight ? Theme.paddingMedium : Theme.paddingSmall)
                                  : 0)


        Item {
            id: valueTextPlaceholder

            width: parent.width
            height: _valueTextItem && _valueTextItem.visible ? _valueTextItem.height : 0
        }

        GlassItem {
            id: background

            // extra painting margins (Theme.paddingMedium on both sides) are needed,
            // because glass item doesn't visibly paint across the full width of the item
            x: progressBar.leftMargin - _glassItemPadding
            width: progressBar._grooveWidth + 2*_glassItemPadding
            height: (Theme.colorScheme === Theme.LightOnDark ? 2 : (indeterminate ? 3 : 4)) * Theme.paddingLarge

            dimmed: true
            radius: Theme.colorScheme === Theme.LightOnDark ? 0.06 : 0.05
            falloffRadius: Theme.colorScheme === Theme.LightOnDark ? 0.09 : 0.05
            ratio: 0.0
            color: progressBar.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor

            GlassItem {
                id: highlight

                anchors.verticalCenter: background.verticalCenter
                // height added as GlassItem will not display correctly with width < height
                width: indeterminate ? background.width
                                     : (progressValue - minimumValue) / (maximumValue - minimumValue) * (background.width - height) + height
                height: background.height
                visible: indeterminate || value > minimumValue
                dimmed: false
                radius: Theme.colorScheme === Theme.LightOnDark ? 0.05 : 0.04
                falloffRadius: Theme.colorScheme === Theme.LightOnDark ? 0.14 : 0.10
                dashMargin: Theme.paddingLarge*2
                dashLength: Theme.paddingLarge
                ratio: 0.0
                color: progressBar.highlighted ? Theme.highlightColor : Theme.lightPrimaryColor
                backgroundColor: Theme.colorScheme === Theme.DarkOnLight ? Theme.highlightDimmerColor : "transparent"
                dashed: indeterminate

                Timer {
                    id: progressBarTimer

                    property bool isVisible: progressBar.visible && progressBar.opacity > 0.0

                    running: indeterminate && isVisible && Qt.application.active
                    repeat: true
                    interval: 16
                    onTriggered: {
                        highlight.dashOffset = (highlight.dashOffset + 1) % (highlight.dashMargin + highlight.dashLength)
                        if (running) {
                            // try to hit every 3rd frame
                            restart()
                        }
                    }
                }
            }
        }

        Text {
            id: labelText

            visible: text.length
            font.pixelSize: Theme.fontSizeSmall
            font.family: Theme.fontFamily
            color: progressBar.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            textFormat: Text.PlainText
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    Component {
        id: valueIndicatorComponent
        Text {
            color: progressBar.highlighted ? Theme.highlightColor : Theme.primaryColor
            x: Math.min(Math.max(_glassItemPadding, background.x + highlight.width - width/2 - _glassItemPadding),
                        parent.width - width - _glassItemPadding)

            font.pixelSize: Theme.fontSizeLarge
            font.family: Theme.fontFamily
            textFormat: Text.PlainText
            text: progressBar.valueText
            visible: text !== ""
        }
    }
}
