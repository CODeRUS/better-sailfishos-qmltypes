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

var filterStatement = ". FILTER (%1%2) "

var titleCaseSensitiveSearchFilter = "fn:contains(?title, \"%1\")"

var titleSearchFilter = "regex(?title, \"%1\", \"i\")"

var pathSearchFilter = "tracker:uri-is-descendant(\"file://%1\", ?url)"

var idGroupBy = "GROUP BY ?id "

var titleOrderBy = "" +
    "ORDER BY " +
       "ASC(fn:lower-case(?title))"

var lastAccessedOrderBy = "" +
    "ORDER BY " +
       "DESC(nfo:fileLastAccessed(?urn))"


function getFilterStatement(negated, comparison) {
    var negation = negated ? "!" : ""
    return filterStatement.arg(negation).arg(comparison)
}
