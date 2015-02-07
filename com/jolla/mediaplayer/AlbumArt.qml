/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica.theme 1.0

Image {
    id: albumArt

    property bool highlighted
    property real size: Theme.itemSizeExtraLarge

    height: size
    width: size
    sourceSize.width: size
    sourceSize.height: size

    MusicIcon {
        size: parent.size
        highlighted: parent.highlighted
        visible: albumArt.source == ""
    }
}
