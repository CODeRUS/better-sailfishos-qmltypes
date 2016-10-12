.pragma library
.import "RegExpHelpers.js" as RegExpHelpers
.import "TrackerHelpers.js" as TrackerHelpers


var songsSimpleSelect = "" +
    "SELECT " +
        "rdf:type(?urn) " +
        "tracker:id(?urn) AS ?id " +
        "nie:url(?urn) AS ?url " +
        "nfo:duration(?urn) AS ?duration " +
        "tracker:coalesce(nmm:artistName(nmm:performer(?urn)), \"%11\") AS ?author " +
        "tracker:coalesce(nie:title(?urn), tracker:string-from-filename(nfo:fileName(?urn))) AS ?title " +
        "tracker:coalesce(nmm:albumTitle(nmm:musicAlbum(?urn)), \"%12\") AS ?album "

var songsSearchSelect = "" +
    "SELECT " +
        "rdf:type(?urn) " +
        "tracker:id(?urn) AS ?id " +
        "nie:url(?urn) AS ?url " +
        "nfo:duration(?urn) AS ?duration " +
        "tracker:coalesce(nmm:artistName(nmm:performer(?urn)), \"%11\") AS ?author " +
        "?title " +
        "tracker:coalesce(nmm:albumTitle(nmm:musicAlbum(?urn)), \"%12\") AS ?album " +
    "WHERE { " +
        "{ SELECT " +
            "?urn " +
            "tracker:coalesce(nie:title(?urn), tracker:string-from-filename(nfo:fileName(?urn))) AS ?title "

var songsFromArtistSearchSelect = "tracker:coalesce(tracker:id(nmm:performer(?urn)), 0) AS ?performerId "

var songsFromAlbumSearchSelect = "tracker:coalesce(tracker:id(nmm:musicAlbum(?urn)), 0) AS ?albumId "

var songsWhere = "" +
    "WHERE { " +
        "?urn a nmm:MusicPiece " +
            "; nie:isStoredAs ?file " +
        ". ?file tracker:available true "

var songsFromArtistFilter = "(?performerId = %3)"

var songsFromAlbumFilter = "(?albumId = %4)"

var songsOrderBy = "" +
    "ORDER BY " +
        "ASC(fn:lower-case(?author)) " +
        "ASC(fn:lower-case(?album)) " +
        "ASC(nmm:setNumber(nmm:musicAlbumDisc(?urn))) " +
        "ASC(nmm:trackNumber(?urn)) " +
        "ASC(fn:lower-case(?title))"

var songsFromAlbumOrderBy = "" +
    "ORDER BY " +
        "ASC(nmm:setNumber(nmm:musicAlbumDisc(?urn))) " +
        "ASC(nmm:trackNumber(?urn)) " +
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
        "tracker:coalesce(tracker:id(nmm:musicAlbum(?urn)), 0) AS ?id " +
        "tracker:coalesce(nmm:albumTitle(nmm:musicAlbum(?urn)), \"%12\") AS ?title " +
        "IF(COUNT(DISTINCT(tracker:coalesce(nmm:performer(?urn), 0))) > 1, \"%13\", tracker:coalesce(nmm:artistName(nmm:performer(?urn)), \"%11\")) AS ?author " +
        "COUNT(DISTINCT(?urn)) AS ?childcount " +
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
            "tracker:coalesce(tracker:id(nmm:musicAlbum(?urn)), 0) AS ?id " +
            "tracker:coalesce(nmm:albumTitle(nmm:musicAlbum(?urn)), \"%12\") AS ?title " +
            "IF(COUNT(DISTINCT(tracker:coalesce(nmm:performer(?urn), 0))) > 1, \"%13\", tracker:coalesce(nmm:artistName(nmm:performer(?urn)), \"%11\")) AS ?author " +
            "COUNT(DISTINCT(?urn)) AS ?childcount "

var albumsFromArtistSearchSelect = "SUM(IF(tracker:coalesce(tracker:id(nmm:performer(?urn)), 0) = %4, 1, 0)) AS ?filterout "

var albumsWhere = songsWhere

var albumsFromArtistFilter = "(?filterout > 0)"

var albumsOrderBy = "" +
    "ORDER BY " +
        "ASC(fn:lower-case(?author)) " +
        "ASC(fn:lower-case(?title))"

var albumsFromArtistOrderBy = TrackerHelpers.titleOrderBy +
        "ASC(fn:lower-case(?author)) "


// We are "overloading" childcount to hold the total duration. Just
// our container as a container of seconds and then all that would
// start to make sense :P
var artistsSimpleSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "tracker:coalesce(tracker:id(nmm:performer(?urn)), 0) AS ?id " +
        "tracker:coalesce(nmm:artistName(nmm:performer(?urn)), \"%11\") AS ?title " +
        "SUM(nfo:duration(?urn)) AS ?childcount "

var artistsSearchSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "?id " +
        "?title " +
        "SUM(nfo:duration(?urn)) AS ?childcount " +
    "WHERE { " +
        "{ SELECT " +
            "?urn " +
            "tracker:coalesce(tracker:id(nmm:performer(?urn)), 0) AS ?id " +
            "tracker:coalesce(nmm:artistName(nmm:performer(?urn)), \"%11\") AS ?title "

var artistsWhere = songsWhere

var artistsOrderBy = TrackerHelpers.titleOrderBy


function getSongsQuery(aSearchText, opts) {
    var searchSongsQuery
    var unknownArtistText = "unknownArtist" in opts ? opts["unknownArtist"] : "Unknown artist"
    var unknownAlbumText = "unknownAlbum" in opts ? opts["unknownAlbum"] : "Unknown album"
    var artistId = "authorId" in opts ? parseInt(opts["authorId"]) : -1
    var albumId = "albumId" in opts ? parseInt(opts["albumId"]) : -1

    if (artistId == -1 && albumId == -1 && aSearchText == "") {
        searchSongsQuery = songsSimpleSelect + songsWhere
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
            TrackerHelpers.endWhere +
            TrackerHelpers.endWhere
    }

    var tmpComparison
    if (albumId < 1 && artistId >= 0) {
        tmpComparison = songsFromArtistFilter.arg(TrackerHelpers.escapeSparql(artistId.toString()))
        searchSongsQuery += TrackerHelpers.getFilterStatement(false, tmpComparison)
    }

    if (aSearchText != "") {
        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            tmpComparison = TrackerHelpers.titleSearchFilter(aSearchText)
        } else {
            tmpComparison = TrackerHelpers.titleCaseSensitiveSearchFilter(aSearchText)
        }

        searchSongsQuery += TrackerHelpers.getFilterStatement(false, tmpComparison)
    }

    if (albumId >= 0) {
        tmpComparison = songsFromAlbumFilter.arg(TrackerHelpers.escapeSparql(albumId.toString()))
        searchSongsQuery += TrackerHelpers.getFilterStatement(false, tmpComparison) +
            TrackerHelpers.endWhere +
            songsFromAlbumOrderBy
    } else {
        searchSongsQuery += TrackerHelpers.endWhere + songsOrderBy
    }

    return searchSongsQuery.arg(TrackerHelpers.escapeSparql(unknownArtistText)).arg(TrackerHelpers.escapeSparql(unknownAlbumText))
}

function getAlbumsQuery(aSearchText, opts) {
    var searchAlbumsQuery
    var unknownArtistText = "unknownArtist" in opts ? opts["unknownArtist"] : "Unknown artist"
    var unknownAlbumText = "unknownAlbum" in opts ? opts["unknownAlbum"] : "Unknown album"
    var multipleArtistsText = "multipleArtists" in opts ? opts["multipleArtists"] : "Multiple artists"
    var artistId = "authorId" in opts ? parseInt(opts["authorId"]) : -1

    if (artistId == -1 && aSearchText == "") {
        searchAlbumsQuery = albumsSimpleSelect + albumsWhere
    } else {
        searchAlbumsQuery = albumsSearchSelect
    }

    if (artistId >= 0) {
        searchAlbumsQuery += albumsFromArtistSearchSelect.arg(TrackerHelpers.escapeSparql(artistId.toString()))
    }

    if (artistId >= 0 || aSearchText != "") {
        searchAlbumsQuery += albumsWhere
    }

    searchAlbumsQuery += TrackerHelpers.endWhere + TrackerHelpers.idGroupBy

    if (artistId >= 0 || aSearchText != "") {
        searchAlbumsQuery += TrackerHelpers.endWhere
    }

    var tmpComparison

    if (aSearchText != "") {
        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            tmpComparison = TrackerHelpers.titleSearchFilter(aSearchText)
        } else {
            tmpComparison = TrackerHelpers.titleCaseSensitiveSearchFilter(aSearchText)
        }

	searchAlbumsQuery += TrackerHelpers.getFilterStatement(false, tmpComparison)
    }

    if (artistId >= 0) {
        tmpComparison = albumsFromArtistFilter
        searchAlbumsQuery += TrackerHelpers.getFilterStatement(false, tmpComparison)
    }

    if (artistId >= 0 || aSearchText != "") {
        searchAlbumsQuery += TrackerHelpers.endWhere
    }

    if (artistId >= 0) {
        searchAlbumsQuery += albumsFromArtistOrderBy
    } else {
        searchAlbumsQuery += albumsOrderBy
    }

    return searchAlbumsQuery.arg(TrackerHelpers.escapeSparql(artistId.toString())).arg(TrackerHelpers.escapeSparql(unknownArtistText)).arg(TrackerHelpers.escapeSparql(unknownAlbumText)).arg(TrackerHelpers.escapeSparql(multipleArtistsText))
}

function getArtistsQuery(aSearchText, opts) {
    var searchArtistsQuery
    var unknownArtistText = "unknownArtist" in opts ? opts["unknownArtist"] : "Unknown artist"

    if (aSearchText == "") {
        searchArtistsQuery = artistsSimpleSelect + artistsWhere
    } else {
        var tmpComparison

        searchArtistsQuery = artistsSearchSelect +
            artistsWhere +
            TrackerHelpers.endWhere +
            TrackerHelpers.endWhere

        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            tmpComparison = TrackerHelpers.titleSearchFilter(aSearchText)
        } else {
            tmpComparison = TrackerHelpers.titleCaseSensitiveSearchFilter(aSearchText)
        }

        searchArtistsQuery += TrackerHelpers.getFilterStatement(false, tmpComparison)
    }

    searchArtistsQuery += TrackerHelpers.endWhere +
        TrackerHelpers.idGroupBy +
        artistsOrderBy

    return searchArtistsQuery.arg(TrackerHelpers.escapeSparql(unknownArtistText))
}
