.pragma library
.import "RegExpHelpers.js" as RegExpHelpers

function escapeSparql(string) {
    // As described at http://www.w3.org/TR/rdf-sparql-query/#grammarEscapes
    string.replace(/\t/g, "\\t");
    string.replace(/\n/g, "\\n");
    string.replace(/\r/g, "\\r");
    string.replace(/\b/g, "\\b");
    string.replace(/\f/g, "\\f");
    string.replace(/"/g, "\\\"");
    string.replace(/'/g, "\\'");
    return string.replace(/\\/g, "\\\\");
}

var endWhere = "} "

var titleCaseSensitiveSearchFilter = ". FILTER (fn:contains(?title, \"%1\")) "

var titleSearchFilter = ". FILTER (regex(?title, \"%1\", \"i\")) "

var pathSearchFilter = ". FILTER(tracker:uri-is-descendant(\"file://%2\", ?url)) "

var idGroupBy = "GROUP BY ?id "

var titleOrderBy = "" +
    "ORDER BY " +
       "ASC(fn:lower-case(?title))"


var songsSimpleSelect = "" +
    "SELECT " +
        "rdf:type(?song) " +
        "tracker:id(?song) AS ?id " +
        "nie:url(?song) AS ?url " +
        "nfo:duration(?song) AS ?duration " +
        "tracker:coalesce(nmm:artistName(nmm:performer(?song)), \"%11\") AS ?author " +
        "tracker:coalesce(nie:title(?song), tracker:string-from-filename(nfo:fileName(?song))) AS ?title " +
        "tracker:coalesce(nmm:albumTitle(nmm:musicAlbum(?song)), \"%12\") AS ?album "

var songsSearchSelect = "" +
    "SELECT " +
        "rdf:type(?song) " +
        "tracker:id(?song) AS ?id " +
        "nie:url(?song) AS ?url " +
        "nfo:duration(?song) AS ?duration " +
        "tracker:coalesce(nmm:artistName(nmm:performer(?song)), \"%11\") AS ?author " +
        "?title " +
        "tracker:coalesce(nmm:albumTitle(nmm:musicAlbum(?song)), \"%12\") AS ?album " +
    "WHERE { " +
        "{ SELECT " +
            "?song " +
            "tracker:coalesce(nie:title(?song), tracker:string-from-filename(nfo:fileName(?song))) AS ?title "

var songsFromArtistSearchSelect = "tracker:coalesce(tracker:id(nmm:performer(?song)), 0) AS ?performerId "

var songsFromAlbumSearchSelect = "tracker:coalesce(tracker:id(nmm:musicAlbum(?song)), 0) AS ?albumId "

var songsWhere = "" +
    "WHERE { " +
        "?song a nmm:MusicPiece " +
            "; nie:isStoredAs ?file " +
        ". ?file tracker:available ?tr "

var songsFromArtistFilter = ". FILTER(?performerId = %3) "

var songsFromAlbumFilter = ". FILTER(?albumId = %4) "

var songsOrderBy = "" +
    "ORDER BY " +
        "ASC(fn:lower-case(?author)) " +
        "ASC(fn:lower-case(?album)) " +
        "ASC(nmm:setNumber(nmm:musicAlbumDisc(?song))) " +
        "ASC(nmm:trackNumber(?song)) " +
        "ASC(fn:lower-case(?title))"

var songsFromAlbumOrderBy = "" +
    "ORDER BY " +
        "ASC(nmm:setNumber(nmm:musicAlbumDisc(?song))) " +
        "ASC(nmm:trackNumber(?song)) " +
        "ASC(fn:lower-case(?title))"


// We are resolving several times "nmm:performer" and "nmm:musicAlbum"
// as a property functions in the "SELECT" side instead of using the
// "OPTIONAL" keyword in the "WHERE" part. In terms of performance, it
// is better to use property functions than the "OPTIONAL" keyword, as
// explained at:
// https://wiki.gnome.org/Projects/Tracker/Documentation/SparqlTipsTricks#Use_property_functions
//
// We are using this strategy also in other similar queries.

// We are "overloading" tracker-urn to hold the artists id
var albumsSimpleSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "tracker:coalesce(tracker:id(nmm:musicAlbum(?song)), 0) AS ?id " +
        "tracker:coalesce(nmm:albumTitle(nmm:musicAlbum(?song)), \"%12\") AS ?title " +
        "IF(COUNT(DISTINCT(tracker:coalesce(nmm:performer(?song), 0))) > 1, \"%13\", tracker:coalesce(nmm:artistName(nmm:performer(?song)), \"%11\")) AS ?author " +
        "COUNT(DISTINCT(?song)) AS ?childcount " +
        "\"%3\" AS tracker-urn "

var albumsSearchSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "?id " +
        "?title " +
        "?author " +
        "?childcount " +
        "\"%3\" AS tracker-urn " +
    "WHERE { " +
        "{ SELECT " +
            "tracker:coalesce(tracker:id(nmm:musicAlbum(?song)), 0) AS ?id " +
            "tracker:coalesce(nmm:albumTitle(nmm:musicAlbum(?song)), \"%12\") AS ?title " +
            "IF(COUNT(DISTINCT(tracker:coalesce(nmm:performer(?song), 0))) > 1, \"%13\", tracker:coalesce(nmm:artistName(nmm:performer(?song)), \"%11\")) AS ?author " +
            "COUNT(DISTINCT(?song)) AS ?childcount "

var albumsFromArtistSearchSelect = "SUM(IF(tracker:coalesce(tracker:id(nmm:performer(?song)), 0) = %4, 1, 0)) AS ?filterout "

var albumsWhere = songsWhere

var albumsFromArtistFilter = ". FILTER(?filterout > 0) "

var albumsOrderBy = "" +
    "ORDER BY " +
        "ASC(fn:lower-case(?author)) " +
        "ASC(fn:lower-case(?title))"

var albumsFromArtistOrderBy = titleOrderBy +
        "ASC(fn:lower-case(?author)) "


// We are "overloading" childcount to hold the total duration. Just
// our container as a container of seconds and then all that would
// start to make sense :P
var artistsSimpleSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "tracker:coalesce(tracker:id(nmm:performer(?song)), 0) AS ?id " +
        "tracker:coalesce(nmm:artistName(nmm:performer(?song)), \"%11\") AS ?title " +
        "SUM(nfo:duration(?song)) AS ?childcount "

var artistsSearchSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "?id " +
        "?title " +
        "SUM(nfo:duration(?song)) AS ?childcount " +
    "WHERE { " +
        "{ SELECT " +
            "?song " +
            "tracker:coalesce(tracker:id(nmm:performer(?song)), 0) AS ?id " +
            "tracker:coalesce(nmm:artistName(nmm:performer(?song)), \"%11\") AS ?title "

var artistsWhere = songsWhere

var artistsOrderBy = titleOrderBy


var playlistsSimpleSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "tracker:id(?playlist) AS ?id " +
        "?url " +
        "tracker:coalesce(nie:title(?playlist), tracker:string-from-filename(nfo:fileName(?playlist))) AS ?title " +
        "tracker:coalesce(nfo:entryCounter(?playlist), 0) AS ?childcount "

var playlistsSearchSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "tracker:id(?playlist) AS ?id " +
        "?url " +
        "?title " +
        "tracker:coalesce(nfo:entryCounter(?playlist), 0) AS ?childcount " +
    "WHERE { " +
        "{ SELECT " +
            "?playlist " +
            "?url " +
            "tracker:coalesce(nie:title(?playlist), tracker:string-from-filename(nfo:fileName(?playlist))) AS ?title "

var playlistsWhere = "" +
    "WHERE { " +
        "?playlist a nmm:Playlist ; " +
            "nie:url ?url "

var anyPlaylistSearchFilter = ". FILTER((nfo:entryCounter(?playlist) >= 0 || !bound(nfo:entryCounter(?playlist)))) "

var plsPlaylistSearchFilter = ". FILTER((nfo:entryCounter(?playlist) >= 0 || !bound(nfo:entryCounter(?playlist))) && fn:ends-with(?url, \".pls\")) "

var playlistsOrderBy = "" +
    "ORDER BY " +
       "ASC(fn:lower-case(?title))"


function getSongsQuery(aSearchText, opts) {
    var searchSongsQuery
    var unknownArtistText = "unknownArtist" in opts ? opts["unknownArtist"] : "Unknown artist"
    var unknownAlbumText = "unknownAlbum" in opts ? opts["unknownAlbum"] : "Unknown album"
    var artistId = "authorId" in opts ? parseInt(opts["authorId"]) : -1
    var albumId = "albumId" in opts ? parseInt(opts["albumId"]) : -1

    if (artistId == -1 && albumId == -1 && aSearchText == "") {
        searchSongsQuery = songsSimpleSelect +
            songsWhere
    } else {
        searchSongsQuery = songsSearchSelect

        // Only filter by artist when unknown album or not filtering
        // by album
        if (albumId < 1 && artistId >= 0) {
            searchSongsQuery += songsFromArtistSearchSelect
        }

        if (albumId >= 0) {
            searchSongsQuery += songsFromAlbumSearchSelect
        }

        searchSongsQuery += songsWhere +
            endWhere +
            endWhere
    }

    if (albumId < 1 && artistId >= 0) {
        searchSongsQuery += songsFromArtistFilter.arg(escapeSparql(artistId.toString()))
    }

    if (aSearchText != "") {
        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            searchSongsQuery += titleSearchFilter.arg(escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        } else {
            searchSongsQuery += titleCaseSensitiveSearchFilter.arg(escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        }
    }

    if (albumId >= 0) {
        searchSongsQuery += songsFromAlbumFilter.arg(escapeSparql(albumId.toString())) +
            endWhere +
            songsFromAlbumOrderBy
    } else {
        searchSongsQuery += endWhere +
            songsOrderBy
    }

    return searchSongsQuery.arg(escapeSparql(unknownArtistText)).arg(escapeSparql(unknownAlbumText))
}

function getAlbumsQuery(aSearchText, opts) {
    var searchAlbumsQuery
    var unknownArtistText = "unknownArtist" in opts ? opts["unknownArtist"] : "Unknown artist"
    var unknownAlbumText = "unknownAlbum" in opts ? opts["unknownAlbum"] : "Unknown album"
    var multipleArtistsText = "multipleArtists" in opts ? opts["multipleArtists"] : "Multiple artists"
    var artistId = "authorId" in opts ? parseInt(opts["authorId"]) : -1

    if (artistId == -1 && aSearchText == "") {
        searchAlbumsQuery = albumsSimpleSelect +
            albumsWhere
    } else {
        searchAlbumsQuery = albumsSearchSelect
    }

    if (artistId >= 0) {
        searchAlbumsQuery += albumsFromArtistSearchSelect.arg(escapeSparql(artistId.toString()))
    }

    if (artistId >= 0 || aSearchText != "") {
        searchAlbumsQuery += albumsWhere
    }

    searchAlbumsQuery += endWhere +
        idGroupBy

    if (artistId >= 0 || aSearchText != "") {
        searchAlbumsQuery += endWhere
    }

    if (aSearchText != "") {
        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            searchAlbumsQuery += titleSearchFilter.arg(escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        } else {
            searchAlbumsQuery += titleCaseSensitiveSearchFilter.arg(escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        }
    }

    if (artistId >= 0) {
        searchAlbumsQuery += albumsFromArtistFilter
    }

    if (artistId >= 0 || aSearchText != "") {
        searchAlbumsQuery += endWhere
    }

    if (artistId >= 0) {
        searchAlbumsQuery += albumsFromArtistOrderBy
    } else {
        searchAlbumsQuery += albumsOrderBy
    }

    return searchAlbumsQuery.arg(escapeSparql(artistId.toString())).arg(escapeSparql(unknownArtistText)).arg(escapeSparql(unknownAlbumText)).arg(escapeSparql(multipleArtistsText))
}

function getArtistsQuery(aSearchText, opts) {
    var searchArtistsQuery
    var unknownArtistText = "unknownArtist" in opts ? opts["unknownArtist"] : "Unknown artist"

    if (aSearchText == "") {
        searchArtistsQuery = artistsSimpleSelect +
            artistsWhere
    } else {
        searchArtistsQuery = artistsSearchSelect +
            artistsWhere +
            endWhere +
            endWhere

        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            searchArtistsQuery += titleSearchFilter.arg(escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        } else {
            searchArtistsQuery += titleCaseSensitiveSearchFilter.arg(escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        }
    }

    searchArtistsQuery += endWhere +
        idGroupBy +
        artistsOrderBy

    return searchArtistsQuery.arg(escapeSparql(unknownArtistText))
}

function getPlaylistsQuery(aSearchText, opts) {
    var searchPlaylistsQuery
    var playlistsLocation = "playlistsLocation" in opts ? opts["playlistsLocation"] : ""
    var editablePlaylistsOnly = "editablePlaylistsOnly" in opts ? opts["editablePlaylistsOnly"] : false

    if (aSearchText == "") {
        searchPlaylistsQuery = playlistsSimpleSelect +
            playlistsWhere

        searchPlaylistsQuery += editablePlaylistsOnly? plsPlaylistSearchFilter: anyPlaylistSearchFilter

        if (playlistsLocation != "") {
            searchPlaylistsQuery += pathSearchFilter.arg(escapeSparql(playlistsLocation))
        }
    } else {
        searchPlaylistsQuery = playlistsSearchSelect +
            playlistsWhere

        searchPlaylistsQuery += editablePlaylistsOnly? plsPlaylistSearchFilter: anyPlaylistSearchFilter

        if (playlistsLocation != "") {
            searchPlaylistsQuery += pathSearchFilter.arg(escapeSparql(playlistsLocation))
        }

        searchPlaylistsQuery += endWhere +
            endWhere

        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            searchPlaylistsQuery += titleSearchFilter.arg(escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        } else {
            searchPlaylistsQuery += titleCaseSensitiveSearchFilter.arg(escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        }
    }

    searchPlaylistsQuery += endWhere +
        playlistsOrderBy

    return searchPlaylistsQuery
}
