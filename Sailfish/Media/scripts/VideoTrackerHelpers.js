.pragma library
.import "RegExpHelpers.js" as RegExpHelpers
.import "TrackerHelpers.js" as TrackerHelpers


var videosSimpleSelect = "" +
    "SELECT " +
        "rdf:type(?urn) " +
        "tracker:id(?urn) AS ?id " +
        "?url " +
        "tracker:coalesce(nie:title(?urn), tracker:string-from-filename(nfo:fileName(?urn))) AS ?title " +
        "nie:mimeType(?urn) AS ?mime_type_file " +
        "nfo:duration(?urn) AS ?duration " +
        "nfo:orientation(?urn) AS ?orientation " +
        "nfo:fileLastModified(?urn) AS ?modification_date_file "

var videosSearchSelect = "" +
    "SELECT " +
        "rdf:type(?urn) " +
        "tracker:id(?urn) AS ?id " +
        "?url " +
        "?title " +
        "nie:mimeType(?urn) AS ?mime_type_file " +
        "nfo:duration(?urn) AS ?duration " +
        "nfo:orientation(?urn) AS ?orientation " +
        "nfo:fileLastModified(?urn) AS ?modification_date_file " +
    "WHERE { " +
        "{ SELECT " +
            "?urn " +
            "?url " +
            "tracker:coalesce(nie:title(?urn), tracker:string-from-filename(nfo:fileName(?urn))) AS ?title "

var videosWhere = "" +
    "WHERE { " +
        "?urn a nmm:Video " +
            "; nie:isStoredAs ?file " +
            "; nie:url ?url " +
        ". ?file tracker:available true "

var videosOrderBy = TrackerHelpers.lastAccessedOrderBy


function getVideosQuery(aSearchText, opts) {
    var searchVideosQuery
    var locations = "locations" in opts ? opts["locations"] : ""

    if (aSearchText == "") {
        searchVideosQuery = videosSimpleSelect +
            videosWhere

        if (locations != "") {
	    var tmpComparison

	    for (var i = 0; i < locations.length; i++) {
		tmpComparison = TrackerHelpers.pathSearchFilter.arg(TrackerHelpers.escapeSparql(locations[i].location))
		searchVideosQuery += TrackerHelpers.getFilterStatement(locations[i].negated, tmpComparison)
	    }
        }
    } else {
	var tmpComparison

        searchVideosQuery = videosSearchSelect +
            videosWhere

        if (locations != "") {
	    for (var i = 0; i < locations.length; i++) {
		tmpComparison = TrackerHelpers.pathSearchFilter.arg(TrackerHelpers.escapeSparql(locations[i].location))
		searchVideosQuery += TrackerHelpers.getFilterStatement(locations[i].negated, tmpComparison)
	    }
        }

        searchVideosQuery += TrackerHelpers.endWhere +
            TrackerHelpers.endWhere

        // Emacs search style: only be case sensitive
        // if there are capitals.
        if (aSearchText == aSearchText.toLowerCase()) {
            tmpComparison = TrackerHelpers.titleSearchFilter.arg(TrackerHelpers.escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        } else {
            tmpComparison = TrackerHelpers.titleCaseSensitiveSearchFilter.arg(TrackerHelpers.escapeSparql(RegExpHelpers.escapeRegExp(aSearchText)))
        }

	searchVideosQuery += TrackerHelpers.getFilterStatement(false, tmpComparison)
    }

    searchVideosQuery += TrackerHelpers.endWhere +
        videosOrderBy

    return searchVideosQuery
}
