/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0

Item {
    property bool highlighted
    property real size: Theme.itemSizeExtraLarge

    height: size
    width: size

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.primaryColor, 0.05) }
        }
    }

    IconButton {
        anchors.fill: parent
        icon.source: "image://theme/icon-m-music"
        icon.opacity: 1.0
        enabled: false
        highlighted: parent.highlighted
    }
}
