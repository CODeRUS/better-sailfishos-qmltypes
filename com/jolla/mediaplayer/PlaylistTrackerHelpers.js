.pragma library
.import "RegExpHelpers.js" as RegExpHelpers
.import "TrackerHelpers.js" as TrackerHelpers


var playlistsSimpleSelect = "" +
    "SELECT " +
        "\"grilo#Container\" " +
        "tracker:id(?urn) AS ?id " +
        "?url " +
        "tracker:coalesce(nie:title(?urn), tracker:string-from-filename(nfo:fileName(?urn))) AS ?title " +
        "tracker:coalesce(nfo:entryCounter(?urn), 0) AS ?childcount "

var playlistsSearchSelect = "" +
    "SELECT " +
        "\"grilo#Container\" " +
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

var playlistsOrderByTitle = TrackerHelpers.titleOrderBy

var playlistOrderByUsage = "ORDER BY DESC(nie:contentAccessed(?urn))"

function getPlaylistsQuery(aSearchText, opts) {
    var searchPlaylistsQuery
    var locations = "locations" in opts ? opts["locations"] : ""
    var editablePlaylistsOnly = "editablePlaylistsOnly" in opts ? opts["editablePlaylistsOnly"] : false
    var sortByUsage = "sortByUsage" in opts ? opts["sortByUsage"] : false
    var tmpComparison
    var i

    if (aSearchText == "") {
        searchPlaylistsQuery = playlistsSimpleSelect + playlistsWhere
        searchPlaylistsQuery += TrackerHelpers.getFilterStatement(false , editablePlaylistsOnly ? plsPlaylistSearchFilter: anyPlaylistSearchFilter)

        if (locations != "") {

            for (i = 0; i < locations.length; i++) {
                tmpComparison = TrackerHelpers.pathSearchFilter(locations[i].location)
                searchPlaylistsQuery += TrackerHelpers.getFilterStatement(locations[i].negated, tmpComparison)
            }
        }
    } else {
        searchPlaylistsQuery = playlistsSearchSelect + playlistsWhere
        searchPlaylistsQuery += TrackerHelpers.getFilterStatement(false , editablePlaylistsOnly ? plsPlaylistSearchFilter: anyPlaylistSearchFilter)

        if (locations != "") {
            for (i = 0; i < locations.length; i++) {
                tmpComparison = TrackerHelpers.pathSearchFilter(locations[i].location)
                searchPlaylistsQuery += TrackerHelpers.getFilterStatement(locations[i].negated, tmpComparison)
            }
        }

        searchPlaylistsQuery += TrackerHelpers.endWhere + TrackerHelpers.endWhere

        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            tmpComparison = TrackerHelpers.titleSearchFilter(aSearchText)
        } else {
            tmpComparison = TrackerHelpers.titleCaseSensitiveSearchFilter(aSearchText)
        }

        searchPlaylistsQuery += TrackerHelpers.getFilterStatement(false, tmpComparison)
    }

    searchPlaylistsQuery += TrackerHelpers.endWhere + (sortByUsage ? playlistOrderByUsage : playlistsOrderByTitle)

    return searchPlaylistsQuery
}
