// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

Page {
    id: page

    property var media

    MediaPlayerListView {
        id: view

        model: GriloTrackerModel {
            id: playlistModel
            query: PlaylistTrackerHelpers.getPlaylistsQuery(playlistsHeader.searchText,
                                                            {"locations": [{"negated": false, "location": playlistsLocation}],
                                                             "editablePlaylistsOnly": true})
        }

        Connections {
            target: playlists
            onUpdated: playlistModel.refresh()
        }

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

        delegate: MediaContainerPlaylistDelegate {
            formatFilter: playlistsHeader.searchText
            title: media.title
            songCount: media.childCount
            color: model.title != "" ? PlaylistColors.nameToColor(model.title)
                                     : "transparent"
            onClicked: {
                // TODO: Notify user?
                if (playlists.appendToPlaylist(media, page.media)) {
                    pageStack.pop()
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
