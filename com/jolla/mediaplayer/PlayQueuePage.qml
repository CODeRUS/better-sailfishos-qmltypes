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
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

MediaPlayerPage {
    id: playQueue

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

            MenuItem {
                id: menuItemSearch

                //: Search menu entry
                //% "Search"
                text: qsTrId("mediaplayer-me-search")
                onClicked: playQueueHeader.enableSearch()
                enabled: view.count > 0 || playQueueHeader.searchText !== ''
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
            //% "Play Queue"
            title: qsTrId("mediaplayer-he-play-queue")

            //: Playlist search field placeholder text
            //% "Search song"
            placeholderText: qsTrId("mediaplayer-tf-playlist-search")
        }

        delegate: MediaListDelegate {
            property bool requestRemove: false

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
