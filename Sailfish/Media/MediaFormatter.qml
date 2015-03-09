import QtQuick 2.0
import Sailfish.Silica 1.0

Formatter {
    function formatArtist(artist) {
        //: Translation for empty artist name metadata in music picker
        //% "Unknown artist"
        return artist ? artist : qsTrId("components_media-li-unkown_artist")
    }

    function formatAlbum(album) {
        //: Translation for empty album title metadata in music picker
        //% "Unknown album"
        return album ? album : qsTrId("components_media-li-unkown_album")
    }

    function formatSong(song) {
        //: Translation for empty song name metadata in music picker
        //% "Unknown song"
        return song ? song : qsTrId("components_media-li-unkown_song")
    }
}
