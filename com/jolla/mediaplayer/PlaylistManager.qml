// -*- qml -*-

import QtQuick 2.0
import org.nemomobile.grilo 0.1
import com.jolla.mediaplayer 1.0

Item {
    id: root

    property alias addModel: addModel
    property alias viewModel: viewModel
    property alias trackerStore: store

    property int count

    Timer {
        id: timer
        interval: 50
        onTriggered: root.count = viewModel.count
    }

    Connections {
        // Due to JB#21453, we are using a timer to change the count
        // property in a delayed/lazy way so we won't update the UI so
        // often with a lot of count changes instead of a big one.
        target: viewModel
        onCountChanged: timer.restart()
    }

    PlaylistSaver {
        id: saver
    }

    PlaylistModel {
        id: playlistModel
        store: store
    }

    function refresh() {
        addModel.refresh()
        viewModel.refresh()
    }

    function isEditable(uri) {
        return saver.isEditable(uri, playlistsLocation);
    }

    function appendToPlaylist(playlist, media) {
        playlistModel.url = playlist.url
        playlistModel.clear()
        playlistModel.populate()
        playlistModel.append(media.url, media.title, media.author, media.duration)

        var success = saver.save(playlistModel, playlist.title, playlist.url)

        if (success) {
            store.updateEntryCounter(playlist.url, playlistModel.count)

            refresh()
        }

        return success
    }

    function createPlaylist(title, media) {
        var url = saver.create(title, playlistsLocation, media)
        if (url != "") {
            store.addPlaylist(url, title, media ? 1 : 0)

            refresh()

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

            refresh()
        }

        return success
    }

    function clearPlaylist(media) {
        var success = saver.clear(media.url, media.title)
        if (success) {
            store.updateEntryCounter(media.url, 0)

            refresh()
        }

        return success
    }

    function removePlaylist(media) {
        var success = saver.removePlaylist(media.url)
        if (success) {
            // This is a hack, we are filtering on nfo:entryCounter in the queries below
            // Because it would take tracker ~2 seconds to index
            store.updateEntryCounter(media.url, -1)

            refresh()
        }

        return success
    }


    function removeItem(url)
    {
        var playlists = new Array
        var plModels = new Array
        var refreshModels = false

        for (var i=0; i < viewModel.count; ++i) {
            // First iterate through top level playlist items
            var playlist = viewModel.get(i);
            var playlistModel = plComponent.createObject(null)

            // Check if the pl is editable
            if (!isEditable(playlist.url)) {
                continue
            }
            // Remove song instances from all the playlists. Note that the same
            // song can be multiple times in the same playlist and that's why
            // it's removedy by URL not by index.
            if (playlistModel) {
                playlistModel.store = store
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
            refresh()
        }
    }

    Component {
        id: plComponent
        PlaylistModel {}
    }

    TrackerStore {
        id: store
    }

    GriloQueryListModel {
        id: viewModel

        function setDefaultQuery(searchText) {
            query = TrackerHelpers.getPlaylistsQuery(searchText, {})
        }
    }

    GriloQueryListModel {
        id: addModel

        function setDefaultQuery(searchText) {
            query = TrackerHelpers.getPlaylistsQuery(searchText, {"playlistsLocation": playlistsLocation, "editablePlaylistsOnly": true})
        }
    }
}
