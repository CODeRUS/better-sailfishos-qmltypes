/****************************************************************************
**
** Copyright (C) 2015 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    id: root

    property real leftMargin

    anchors {
        left: parent.left
        leftMargin: root.leftMargin
    }
    height: parent.height
    width: Theme.colorScheme == Theme.LightOnDark
           ? Math.round(Theme.pixelRatio * (Screen.sizeCategory <= Screen.Medium ? 1 : 2))
           : Math.round(Theme.paddingSmall * 0.7)
    radius: Theme.colorScheme == Theme.LightOnDark ? 0 : Math.round(width/3)
}
