.pragma library

function escapeRegExp(string) {
    // As described at https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions#Using_Special_Characters
    return string ? string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1") : ""
}

function regExpFromSearchString(string, alwaysRegExp) {
    // Emacs search style: only be case sensitive
    // if there are capitals.
    if (string && string == string.toLowerCase()) {
        return alwaysRegExp ? new RegExp(escapeRegExp(string), "i") : string
    } else {
        return new RegExp(escapeRegExp(string))
    }
}
