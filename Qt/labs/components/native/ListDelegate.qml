/****************************************************************************
**
** Copyright (C) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Nokia Corporation (qt-info@nokia.com)
**
** This file is part of the Qt Components project.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**     notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**     notice, this list of conditions and the following disclaimer in
**     the documentation and/or other materials provided with the
**     distribution.
**   * Neither the name of Nokia Corporation and its Subsidiary(-ies) nor
**     the names of its contributors may be used to endorse or promote
**     products derived from this software without specific prior written
**     permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.0
import com.nokia.meego 2.0
import "constants.js" as UI

MouseArea {
    id: listItem

    property int titleSize: UI.LIST_TILE_SIZE
    property int titleWeight: Font.Bold
    property string titleFont: UiConstants.DefaultFontFamily
    property color titleColor: theme.inverted ? UI.LIST_TITLE_COLOR_INVERTED : UI.LIST_TITLE_COLOR
    property color titleColorPressed: theme.inverted ? UI.LIST_TITLE_COLOR_PRESSED_INVERTED : UI.LIST_TITLE_COLOR_PRESSED

    property int subtitleSize: UI.LIST_SUBTILE_SIZE
    property int subtitleWeight: Font.Normal
    property string subtitleFont: UiConstants.DefaultFontFamilyLight
    property color subtitleColor: theme.inverted ? UI.LIST_SUBTITLE_COLOR_INVERTED : UI.LIST_SUBTITLE_COLOR
    property color subtitleColorPressed: theme.inverted ? UI.LIST_SUBTITLE_COLOR_PRESSED_INVERTED : UI.LIST_SUBTITLE_COLOR_PRESSED

    property string iconSource: model.iconSource ? model.iconSource : ""
    property string titleText: model.title
    property string subtitleText: model.subtitle ? model.subtitle : ""

    property string iconId
    property bool iconVisible: false

    height: UI.LIST_ITEM_HEIGHT
    width: parent.width

    BorderImage {
        id: background
        anchors.fill: parent
        // Fill page porders
        anchors.leftMargin: -UI.MARGIN_XLARGE
        anchors.rightMargin: -UI.MARGIN_XLARGE
        visible: listItem.pressed
        source: theme.inverted ? "image://theme/meegotouch-panel-inverted-background-pressed" : "image://theme/meegotouch-panel-background-pressed"
    }

    Row {
        anchors.fill: parent
        spacing: UI.LIST_ITEM_SPACING

        Image {
            anchors.verticalCenter: parent.verticalCenter
            visible: listItem.iconSource ? true : false
            width: UI.LIST_ICON_SIZE
            height: UI.LIST_ICON_SIZE
            source: listItem.iconSource
        }

        Column {
            anchors.verticalCenter: parent.verticalCenter

            Label {
                id: mainText
                text: listItem.titleText
                font.family: listItem.titleFont
                font.weight: listItem.titleWeight
                font.pixelSize: listItem.titleSize
                color: listItem.pressed ? listItem.titleColorPressed : listItem.titleColor
            }

            Label {
                id: subText
                text: listItem.subtitleText
                font.family: listItem.subtitleFont
                font.weight: listItem.subtitleWeight
                font.pixelSize: listItem.subtitleSize
                color: listItem.pressed ? listItem.subtitleColorPressed : listItem.subtitleColor

                visible: text != ""
            }
        }
    }

    Image {
        function handleIconId() {
            var prefix = "icon-m-"
            // check if id starts with prefix and use it as is
            // otherwise append prefix and use the inverted version if required
            if (iconId.indexOf(prefix) !== 0)
                iconId =  prefix.concat(iconId).concat(theme.inverted ?  "-inverse" : "");
            return "image://theme/" + iconId;
        }

        visible: iconVisible
        source: iconId ? handleIconId() : ""
        anchors {
            right: parent.right;
            verticalCenter: parent.verticalCenter;
        }
    }

}
