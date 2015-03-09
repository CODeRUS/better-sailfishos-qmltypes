import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

ContentModel {
    contentType: ContentType.Music
    // Just make sure that at least mp4s are not treated as a music. Tracker may include them
    // into the returned query result.
    contentFilter: GalleryEndsWithFilter { property: "fileName"; value: ".mp4"; negated: true }

    rootType: DocumentGallery.Audio

    sortProperties: ["+title"]
    properties: [ 'url', 'title', 'lastAccessed', 'filePath', 'fileName', 'fileSize',
        'mimeType', 'duration', 'artist', 'albumTitle', 'genre', 'selected', 'contentType' ]

    function _filter(contentItem) {

        var matchTitle = false
        var matchAlbumTitle = false
        var matchArtist = false
        if (contentItem.title) {
            matchTitle = contentItem.title.toLowerCase().indexOf(filter) !== -1
        }

        if (contentItem.albumTitle) {
            matchAlbumTitle = contentItem.albumTitle.toLowerCase().indexOf(filter) !== -1
        }

        if (contentItem.artist) {
            matchArtist = contentItem.artist.toLowerCase().indexOf(filter) !== -1
        }

        return matchTitle || matchAlbumTitle || matchArtist
    }
}
