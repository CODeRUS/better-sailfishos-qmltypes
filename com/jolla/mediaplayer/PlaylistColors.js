.pragma library

var colors =          ["#b3b35f54", "#b3b37948", "#b3bfa058", "#b38ca646", "#b3519c3f", "#b32ea3a1", "#b3458dba", "#b3506fc7", "#b3b3609b"]
var highlightColors = ["#b35f54",   "#b37948",   "#bfa058",   "#8ca646",   "#519c3f",   "#2ea3a1",   "#458dba",   "#506fc7",   "#b3609b"]

function nameToColor(name)
{
    var index = parseInt(Qt.md5(name).substring(0, 8), 16) % colors.length
    return colors[index]
}

function nameToHighlightColor(name)
{
    var index = parseInt(Qt.md5(name).substring(0, 8), 16) % highlightColors.length
    return highlightColors[index]
}
