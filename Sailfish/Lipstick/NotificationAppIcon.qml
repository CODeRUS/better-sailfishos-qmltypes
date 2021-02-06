/****************************************************************************
 **
 ** Copyright (C) 2013-2020 Jolla Ltd.
 ** Copyright (C) 2020 Open Mobile Platform LLC.
 **
 ****************************************************************************/

import QtQuick 2.6
import Sailfish.Silica 1.0
import Sailfish.Lipstick 1.0

SilicaItem {
    id: root

    property string iconSource
    property string iconColor
    property bool _colorize: iconSource != "" && iconColor != "" && icon.status != Image.Error

    width: Theme.iconSizeSmall
    height: width

    Rectangle {
        id: colorBackground

        anchors.fill: root
        radius: Theme.dp(2)
        color: root._colorize ? (root.iconColor == "auto" ? "#808080" : root.iconColor)
                              : "transparent"
    }

    HighlightImage {
        id: icon

        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        sourceSize.width: root.width
        width: Math.min(implicitWidth, root.width) // scale only down
        source: iconSource != "" ? Notifications.iconSource(iconSource, palette.primaryColor)
                                 : "image://theme/icon-lock-information"
        color: root._colorize ? Theme.lightPrimaryColor : undefined
    }

    HighlightImage {
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        source: icon.status == Image.Error ? "image://theme/icon-lock-information" : ""
        monochromeWeight: colorWeight
        highlightColor: palette.highlightBackgroundColor
    }

    Rectangle {
        anchors.fill: parent
        radius: colorBackground.radius
        color: root._colorize && root.highlighted
               ? Theme.rgba(palette.highlightBackgroundColor, palette.highlightBackgroundOpacity)
               : "transparent"
    }
}
