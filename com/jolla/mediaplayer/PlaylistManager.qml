// -*- qml -*-

import QtQuick 2.0
import Sailfish.Media 1.0
import com.jolla.mediaplayer 1.0

Item {
    id: root

    property int count

    signal updated()

    onUpdated: playlistListModel.refresh()

    function isEditable(uri) {
        return saver.isEditable(uri, playlistsLocation)
    }

    function appendToPlaylist(playlist, media) {
        playlistModel.url = playlist.url
        playlistModel.clear()
        playlistModel.populate()
        playlistModel.append(media.url, media.title, media.author, media.duration)

        var success = saver.save(playlistModel, playlist.title, playlist.url)

        if (success) {
            store.updateEntryCounter(playlist.url, playlistModel.count)

            root.updated()
        }

        return success
    }

    function createPlaylist(title, media) {
        var url = saver.create(title, playlistsLocation, media)
        if (url != "") {
            store.addPlaylist(url, title, media ? 1 : 0)

            root.updated()

            return true
        }

        return false
    }

    function savePlaylist(media, model) {
        var success = false

        if (model.count == 0) {
            success = saver.clear(media.url, media.title)
        } else {
            success = saver.save(model, media.title, media.url)
        }

        if (success) {
            store.updateEntryCounter(media.url, model.count)

            root.updated()
        }

        return success
    }

    function clearPlaylist(media) {
        var success = saver.clear(media.url, media.title)
        if (success) {
            store.updateEntryCounter(media.url, 0)

            root.updated()
        }

        return success
    }

    function removePlaylist(media) {
        var success = saver.removePlaylist(media.url)
        if (success) {
            // This is a hack, we are filtering on nfo:entryCounter in the queries below
            // Because it would take tracker ~2 seconds to index
            store.updateEntryCounter(media.url, -1)

            root.updated()
        }

        return success
    }


    function removeItem(url)
    {
        var playlists = new Array
        var plModels = new Array
        var refreshModels = false

        for (var i = 0; i < playlistListModel.count; ++i) {
            // First iterate through top level playlist items
            var playlist = playlistListModel.get(i)
            var playlistModel = plComponent.createObject(null)

            // Check if the pl is editable
            if (!isEditable(playlist.url)) {
                continue
            }
            // Remove song instances from all the playlists. Note that the same
            // song can be multiple times in the same playlist and that's why
            // it's removed by URL not by index.
            if (playlistModel) {
                playlistModel.url = playlist.url
                playlistModel.populate()

                if (playlistModel.removeItemByUrl(url) > 0) {

                    refreshModels = playlistModel.count == 0
                                ? saver.clear(playlist.url, playlist.title)
                                : saver.save(playlistModel, playlist.title, playlist.url)

                    if (refreshModels) {
                        store.updateEntryCounter(playlist.url, playlistModel.count)
                    }
                }

                playlistModel.destroy(1000)
            } else {
                console.log("Failed to create playlist model for ", playlist.url)
            }
        }

        // Update models at once. Otherwise there seem to be weird behavior
        if (refreshModels) {
            root.updated()
        }
    }

    function updateAccessTime(url)
    {
        store.updateAccessTime(url)
        root.updated()
    }

    Timer {
        id: timer
        interval: 50
        onTriggered: root.count = playlistListModel.count
    }

    Connections {
        // Due to JB#21453, we are using a timer to change the count
        // property in a delayed/lazy way so we won't update the UI so
        // often with a lot of count changes instead of a big one.
        target: playlistListModel
        onCountChanged: timer.restart()
    }

    PlaylistSaver {
        id: saver
    }

    PlaylistModel {
        id: playlistModel
    }

    Component {
        id: plComponent
        PlaylistModel {}
    }

    TrackerStore {
        id: store
    }

    GriloTrackerModel {
        id: playlistListModel
        query: PlaylistTrackerHelpers.getPlaylistsQuery("", {})
    }
}
