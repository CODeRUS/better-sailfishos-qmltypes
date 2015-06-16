/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

BackgroundItem {
    id: backgroundItem

    property alias text: label.text
    property alias sectionLabel: section.text
    property bool selected

    _showPress: false

    HighlightItem {
        anchors.fill: parent
        highlightOpacity: Theme.highlightBackgroundOpacity
        active: highlighted
    }

    Label {
        id: label

        color: selected || highlighted ? Theme.highlightColor : Theme.primaryColor
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            right: section.left
            rightMargin: Theme.paddingSmall
        }
    }

    Label {
        id: section

        visible: selected
        color: selected || highlighted ? Theme.highlightColor : Theme.primaryColor
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
        }
    }
}
