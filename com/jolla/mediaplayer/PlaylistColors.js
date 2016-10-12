.pragma library

var colors = ["#b35f54", "#b37948", "#bfa058", "#8ca646", "#519c3f", "#2ea3a1", "#458dba", "#506fc7", "#b3609b"]

function nameToColor(name)
{
    var index = parseInt(Qt.md5(name).substring(0, 8), 16) % colors.length
    return colors[index]
}
