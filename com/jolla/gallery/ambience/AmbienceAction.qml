import QtQml 2.0

QtObject {
    property string section
    property string property
    property string label

    property Component editor
    property Component dialog

    function valueText(ambience) {
        return ambience[property]
    }
    function hasValue(ambience) {
        return ambience[property] != undefined
    }
    function clearValue(ambience) {
        ambience[property] = undefined
    }
    function setDefaultValue(ambience) {
    }
}
