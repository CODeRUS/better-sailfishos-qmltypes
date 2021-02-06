/*
 * Copyright (c) 2013 - 2019 Jolla Pty Ltd.
 * Copyright (c) 2020 Open Mobile Platform LLC.
 *
 * License: Proprietary
*/

import QtQuick 2.5
import Sailfish.Silica 1.0

DockedPanel {
    id: root

    signal deleteClicked()
    signal shareClicked()

    width: parent.width
    height: Theme.itemSizeLarge
    dock: Dock.Bottom

    Image {
        anchors.fill: parent
        fillMode: Image.PreserveAspectFit
        source: "image://theme/graphic-gradient-edge"
    }

    IconButton {
        height: parent.height
        width: parent.width/2
        icon.source: "image://theme/icon-m-delete"

        onClicked: {
            root.deleteClicked()
        }
    }

    IconButton {
        height: parent.height
        x: parent.width/2
        width: parent.width/2
        icon.source: "image://theme/icon-m-share"
        onClicked: {
            root.shareClicked()
        }
    }
}
