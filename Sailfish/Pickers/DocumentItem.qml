/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

ListItem {
    id: backgroundItem

    property alias baseName: baseName.text
    property alias extension: extension.text
    property bool selected

    contentHeight: Math.max(implicitHeight, baseName.height + 2 * Theme.paddingLarge)
    highlighted: down || menuOpen || selected
    _showPress: false

    HighlightItem {
        anchors.fill: parent
        highlightOpacity: Theme.highlightBackgroundOpacity
        active: highlighted
    }

    Label {
        id: baseName
        textFormat: Text.StyledText
        horizontalAlignment: Text.AlignRight
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        wrapMode: Text.Wrap
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left; leftMargin: Theme.paddingMedium
            right: extension.left
        }
        maximumLineCount: 4
    }

    Label {
        id: extension
        textFormat: Text.StyledText
        truncationMode: TruncationMode.Fade
        width: Theme.itemSizeSmall // Same width as SearchField's icon
        color: highlighted ? Theme.highlightColor : Theme.primaryColor
        opacity: 0.4
        anchors {
            bottom: baseName.bottom
            right: parent.right
        }
    }
}
