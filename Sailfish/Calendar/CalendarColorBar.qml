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
    width: Math.round(Theme.pixelRatio * (Screen.sizeCategory <= Screen.Medium ? 1 : 2))
}
