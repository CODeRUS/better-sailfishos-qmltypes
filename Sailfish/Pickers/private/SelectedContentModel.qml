/****************************************************************************
**
** Copyright (C) 2013-2017 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0

ListModel {
    function update(contentItem) {
        var row = _indexInModel(contentItem)
        if (row >= 0) {
            remove(row)
        } else {
            append(contentItem)
        }
    }

    function selected(filePath) {
        for (var row = 0; row < count; row++) {
            if (get(row).filePath === filePath) {
                return true
            }
        }
        return false
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
