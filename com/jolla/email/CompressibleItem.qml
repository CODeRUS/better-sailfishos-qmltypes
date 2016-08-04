/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Valerio Valerio <valerio.valerio@jolla.com>
**
****************************************************************************/

import QtQuick 2.0

FocusScope {
    id: compressible

    property bool compressible: true
    property real expandedHeight: children[0].implicitHeight
    property real compressionHeight
    readonly property bool compressed: height < 1

    height: expandedHeight - compressionHeight
    width: parent.width
    opacity: compressed ? 0 : Math.pow((height / expandedHeight), 3)
}
