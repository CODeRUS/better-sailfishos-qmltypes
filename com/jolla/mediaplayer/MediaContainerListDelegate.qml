/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

ListItem {
    id: item

    property alias icon: albumArt.source
    property string title
    property alias titleFont: titleLabel.font
    property alias subtitle: subtitleLabel.text
    property alias subtitleFont: subtitleLabel.font
    property var formatFilter
    property alias albumArtSize: albumArt.size

    contentHeight: albumArt.size

    AlbumArt {
        id: albumArt
        highlighted: item.highlighted
    }

    Column {
        id: column

        anchors {
            left: albumArt.right
            leftMargin: Theme.paddingLarge
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: albumArt.verticalCenter
        }

        Label {
            id: titleLabel
            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeMedium
            text: Theme.highlightText(item.title, RegExpHelpers.regExpFromSearchString(formatFilter, false), Theme.highlightColor)
            textFormat: Text.StyledText
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
            maximumLineCount: 1
        }

        Label {
            id: subtitleLabel
            width: parent.width
            font.family: Theme.fontFamilyHeading
            font.pixelSize: Theme.fontSizeSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            truncationMode: TruncationMode.Fade
            maximumLineCount: 1
        }
    }
}
