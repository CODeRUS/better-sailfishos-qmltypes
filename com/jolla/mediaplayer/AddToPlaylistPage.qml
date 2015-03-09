// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.theme 1.0
import com.jolla.mediaplayer 1.0

MediaPlayerPage {
    id: page

    property variant media

    Component.onCompleted: audioPlayer.showAddToPlaylistButton = false
    Component.onDestruction: audioPlayer.showAddToPlaylistButton = true

    GriloListView {
        id: view

        model: playlists.addModel
        query: TrackerHelpers.getPlaylistsQuery(playlistsHeader.searchText,
            {"playlistsLocation": playlistsLocation,
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
