// -*- qml -*-

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

Page {
    id: playQueue

    objectName: "PlayQueuePage"
    FilterModel {
        id: playModel
        sourceModel: AudioPlayer.playModel

        filterRegExp: RegExpHelpers.regExpFromSearchString(playQueueHeader.searchText, true)
    }

    MediaPlayerListView {
        id: view

        model: playModel
        anchors.fill: parent

        PullDownMenu {
            id: playQueueMenu

            visible: view.count > 1
            MenuItem {
                id: menuItemSearch

                //: Search menu entry
                //% "Search"
                text: qsTrId("mediaplayer-me-search")
                onClicked: playQueueHeader.enableSearch()
            }
        }

        ViewPlaceholder {
            //: Placeholder text for an empty search view
            //% "No items found"
            text: qsTrId("mediaplayer-la-empty-search")
            enabled: view.count === 0
        }

        header: SearchPageHeader {
            id: playQueueHeader
            width: parent.width

            //: Title for the play queue page
            //% "Play queue"
            title: qsTrId("mediaplayer-he-play-queue")

            //: Playlist search field placeholder text
            //% "Search song"
            placeholderText: qsTrId("mediaplayer-tf-playlist-search")
        }

        delegate: MediaListDelegate {
            property bool requestRemove

            formatFilter: playQueueHeader.searchText

            menu: menuComponent
            onClicked: AudioPlayer.playIndex(playModel.mapRowToSource(index))
            onMenuOpenChanged: {
                if (!menuOpen && requestRemove) {
                    requestRemove = false
                    AudioPlayer.removeFromQueue(playModel.mapRowToSource(index))
                }
            }
            ListView.onRemove: animateRemoval()
            Component {
                id: menuComponent
                ContextMenu {
                    MenuItem {
                        //: Remove song context menu entry in playqueue page
                        //% "Remove"
                        text: qsTrId("mediaplayer-me-playqueue-page-remove")
                        onClicked: requestRemove = true
                    }
                }
            }
        }
    }
}
