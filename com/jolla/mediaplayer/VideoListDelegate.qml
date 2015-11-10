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

BackgroundItem {
    id: delegate

    property bool _highlight: delegate.ListView.isCurrentItem || delegate.down

    property int duration
    property int position
    property alias title: titleLabel.text
    property alias thumbnail: thumbnailContainer.children

    height: Theme.itemSizeExtraLarge

    Item {
        id: thumbnailContainer
        width: Theme.itemSizeExtraLarge
        height: Theme.itemSizeExtraLarge
    }

    Rectangle {
        anchors.fill: thumbnailContainer
        opacity: 0.5
        color: _highlight ? Theme.highlightDimmerColor : "black"
    }

    Label {
        id: durationLabel
        width: thumbnailContainer.width
        text: Format.formatDuration(delegate.duration, delegate.duration >= 3600
                    ? Format.LongDuration
                    : Format.ShortDuration);
        anchors {
            left: thumbnailContainer.left
            top: parent.top
            right: thumbnailContainer.right
            margins: Theme.paddingSmall
        }
        horizontalAlignment: Text.AlignRight
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeMedium
        color: _highlight
               ? (position === 0 ? Theme.highlightColor : Theme.highlightDimmerColor)
               : (position === 0 ? Theme.primaryColor : Theme.secondaryColor)
    }

    Label {
        id: positionLabel
        width: thumbnailContainer.width
        text: Format.formatDuration(delegate.position, delegate.position >= 3600
                                    ? Format.LongDuration
                                    : Format.ShortDuration);
        anchors {
            left: thumbnailContainer.left
            top: durationLabel.bottom
            right: thumbnailContainer.right
            margins: Theme.paddingSmall
        }
        visible: position !== 0
        horizontalAlignment: Text.AlignRight
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeMedium
        color: _highlight ? Theme.highlightColor : Theme.primaryColor
    }

    Label {
        id: titleLabel
        anchors {
            left: thumbnailContainer.right
            right: parent.right
            top: parent.top
            bottom: thumbnailContainer.bottom
            leftMargin: Theme.paddingMedium
            topMargin: Theme.paddingSmall
        }
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeMedium
        wrapMode: Text.Wrap
        elide: Text.ElideRight
        color: _highlight ? Theme.highlightColor : Theme.primaryColor
        maximumLineCount: 1
    }
}
