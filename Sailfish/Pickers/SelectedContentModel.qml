import QtQuick 2.0

ListModel {
    function update(contentItem) {
        var row = _indexInModel(contentItem)
        if (row >= 0) {
            remove(row)
            return false
        }

        append(contentItem)
        return true
    }

    function selected(filePath) {
        for (var row = 0; row < count; row++) {
            if (get(row).filePath === filePath) {
                return true
            }
        }
        return false
    }

    function selectedCount(contentType) {
        var tmpCount = 0
        for (var row = 0; row < count; row++) {
            if (get(row).contentType === contentType) {
                ++tmpCount
            }
        }
        return tmpCount
    }

    function _indexInModel(contentItem) {
        for (var row = 0; row < count; row++) {
            if (get(row).filePath === contentItem.filePath) {
                return row
            }
        }
        return -1
    }
}
