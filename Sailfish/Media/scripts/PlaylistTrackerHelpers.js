.pragma library
.import "RegExpHelpers.js" as RegExpHelpers
.import "TrackerHelpers.js" as TrackerHelpers


var playlistsSimpleSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "tracker:id(?urn) AS ?id " +
        "?url " +
        "tracker:coalesce(nie:title(?urn), tracker:string-from-filename(nfo:fileName(?urn))) AS ?title " +
        "tracker:coalesce(nfo:entryCounter(?urn), 0) AS ?childcount "

var playlistsSearchSelect = "" +
    "SELECT " +
        "\"grilo#Box\" " +
        "tracker:id(?urn) AS ?id " +
        "?url " +
        "?title " +
        "tracker:coalesce(nfo:entryCounter(?urn), 0) AS ?childcount " +
    "WHERE { " +
        "{ SELECT " +
            "?urn " +
            "?url " +
            "tracker:coalesce(nie:title(?urn), tracker:string-from-filename(nfo:fileName(?urn))) AS ?title "

var playlistsWhere = "" +
    "WHERE { " +
        "?urn a nmm:Playlist " +
            "; nie:url ?url "

var anyPlaylistSearchFilter = "(nfo:entryCounter(?urn) >= 0 || !bound(nfo:entryCounter(?urn)))"

var plsPlaylistSearchFilter = "(nfo:entryCounter(?urn) >= 0 || !bound(nfo:entryCounter(?urn))) && fn:ends-with(?url, \".pls\")"

var playlistsOrderBy = TrackerHelpers.titleOrderBy


function getPlaylistsQuery(aSearchText, opts) {
    var searchPlaylistsQuery
    var locations = "locations" in opts ? opts["locations"] : ""
    var editablePlaylistsOnly = "editablePlaylistsOnly" in opts ? opts["editablePlaylistsOnly"] : false

    if (aSearchText == "") {
        searchPlaylistsQuery = playlistsSimpleSelect +
            playlistsWhere

        searchPlaylistsQuery += TrackerHelpers.getFilterStatement(false , editablePlaylistsOnly ? plsPlaylistSearchFilter: anyPlaylistSearchFilter)

        if (locations != "") {
	    var tmpComparison

	    for (var i = 0; i < locations.length; i++) {
		tmpComparison = TrackerHelpers.pathSearchFilter.arg(TrackerHelpers.escapeSparql(locations[i].location))
		searchPlaylistsQuery += TrackerHelpers.getFilterStatement(locations[i].negated, tmpComparison)
	    }
        }
    } else {
	var tmpComparison

        searchPlaylistsQuery = playlistsSearchSelect +
            playlistsWhere

        searchPlaylistsQuery += TrackerHelpers.getFilterStatement(false , editablePlaylistsOnly ? plsPlaylistSearchFilter: anyPlaylistSearchFilter)

        if (locations != "") {
	    for (var i = 0; i < locations.length; i++) {
		tmpComparison = TrackerHelpers.pathSearchFilter.arg(TrackerHelpers.escapeSparql(locations[i].location))
		searchPlaylistsQuery += TrackerHelpers.getFilterStatement(locations[i].negated, tmpComparison)
	    }
        }

        searchPlaylistsQuery += TrackerHelpers.endWhere +
            TrackerHelpers.endWhere

        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            tmpComparison = TrackerHelpers.titleSearchFilter.arg(TrackerHelpers.escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        } else {
            tmpComparison = TrackerHelpers.titleCaseSensitiveSearchFilter.arg(TrackerHelpers.escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        }

	searchPlaylistsQuery += TrackerHelpers.getFilterStatement(false, tmpComparison)
    }

    searchPlaylistsQuery += TrackerHelpers.endWhere +
        playlistsOrderBy

    return searchPlaylistsQuery
}
