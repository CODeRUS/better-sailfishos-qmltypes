/*
 * Copyright (C) 2012-2015 Jolla Ltd.
 *
 * The code in this file is distributed under multiple licenses, and as such,
 * may be used under any one of the following licenses:
 *
 *   - GNU General Public License as published by the Free Software Foundation;
 *     either version 2 of the License (see LICENSE.GPLv2 in the root directory
 *     for full terms), or (at your option) any later version.
 *   - GNU Lesser General Public License as published by the Free Software
 *     Foundation; either version 2.1 of the License (see LICENSE.LGPLv21 in the
 *     root directory for full terms), or (at your option) any later version.
 *   - Alternatively, if you have a commercial license agreement with Jolla Ltd,
 *     you may use the code under the terms of that license instead.
 *
 * You can visit <https://sailfishos.org/legal/> for more information
 */

// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import com.jolla.mediaplayer 1.0

Dialog {
    id: dialog

    property variant media
    property Item pageToPop
    property bool hasTitle: playlistName.text.trim().length > 0

    canNavigateForward: hasTitle

    onAccepted: {
        if (playlists.createPlaylist(playlistName.text, dialog.media)) {
            // TODO: Should we provide feedback?
            if (pageToPop) {
                pageStack.pop(pageToPop)
            }
        }
        // TODO: should we dismiss the previous page too?
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        Column {
            id: column

            width: parent.width
            spacing: Theme.paddingLarge
            DialogHeader {}
            AlbumArt {
                x: Theme.horizontalPageMargin
                source: albumArtProvider.albumThumbnail(media.album, media.author)
            }

            TextField {
                id: playlistName
                width: parent.width
                focus: true
                focusOutBehavior: FocusBehavior.KeepFocus

                //: placeholder for the text field in add playlist dialog.
                //% "Playlist name"
                placeholderText: qsTrId("mediaplayer-ph-playlist-name")
                EnterKey.enabled: dialog.hasTitle
                EnterKey.highlighted: dialog.hasTitle
                EnterKey.iconSource: "image://theme/icon-m-enter-accept"
                EnterKey.onClicked: dialog.accept()
            }
        }
    }
}
