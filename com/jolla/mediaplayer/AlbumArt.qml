/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Image {
    id: albumArt

    property bool highlighted

    height: Theme.itemSizeExtraLarge
    width: Theme.itemSizeExtraLarge
    sourceSize.width: Theme.itemSizeExtraLarge
    sourceSize.height: Theme.itemSizeExtraLarge

    Rectangle {
        anchors.fill: parent
        visible: albumArt.source == ""
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.primaryColor, 0.05) }
        }

        Image {
            source: "image://theme/icon-m-media-albums" + (albumArt.highlighted ? ("?" + Theme.highlightColor)
                                                                                : "")
            anchors.centerIn: parent
        }
    }
}
