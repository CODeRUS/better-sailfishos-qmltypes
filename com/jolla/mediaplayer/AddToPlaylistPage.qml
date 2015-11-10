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
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

MediaPlayerPage {
    id: page

    property variant media

    Component.onCompleted: dockedPanel.showAddToPlaylistButton = false
    Component.onDestruction: dockedPanel.showAddToPlaylistButton = true

    GriloListView {
        id: view

        model: playlists.addModel
        query: PlaylistTrackerHelpers.getPlaylistsQuery(playlistsHeader.searchText,
            {"locations": [{"negated": false, "location": playlistsLocation}],
             "editablePlaylistsOnly": true})

        Component.onDestruction: playlists.addModel.setDefaultQuery("")

        PullDownMenu {

            MenuItem {
                //: Menu label for adding a new playlist
                //% "New playlist"
                text: qsTrId("mediaplayer-me-new-playlist")
                onClicked: pageStack.push("com.jolla.mediaplayer.NewPlaylistDialog", {media: page.media, pageToPop: pageStack.previousPage()})
            }

            MenuItem {
                id: menuItemSearch

                //: Search menu entry
                //% "Search"
                text: qsTrId("mediaplayer-me-search")
                onClicked: playlistsHeader.enableSearch()
                enabled: view.count > 0 || playlistsHeader.searchText !== ''
            }
        }

        header: SearchPageHeader {
            id: playlistsHeader

            width: parent.width

            //: page header for the Playlists page
            //% "Add to"
            title: qsTrId("mediaplayer-he-add-to-playlist")

            //: Playlists search field placeholder text
            //% "Search playlist"
            placeholderText: qsTrId("mediaplayer-tf-playlists-search")
        }

        delegate: MediaContainerListDelegate {
            height: Theme.itemSizeExtraLarge
            formatFilter: playlistsHeader.searchText
            title: media.title

            //: This is for the playlists page. Shows the number of songs in a playlist.
            //% "%n songs"
            subtitle: qsTrId("mediaplayer-le-number-of-songs", media.childCount)

            onClicked: {
                // TODO: Notify user?
                if (playlists.appendToPlaylist(media, page.media)) {
                    pageStack.pop();
                }
            }
        }

        ViewPlaceholder {
            text: {
                if (playlistsHeader.searchText !== '') {
                    //: Placeholder text for an empty search view
                    //% "No items found"
                    return qsTrId("mediaplayer-la-empty-search")
                } else {
                    //: Placeholder text for an empty playlists view
                    //% "Create a playlist"
                    return qsTrId("mediaplayer-la-create-a-playlist")
                }
            }
            enabled: view.count === 0
        }
    }
}
