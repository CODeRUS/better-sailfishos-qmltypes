/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

ContentModel {
    contentType: ContentType.Document
    rootType: DocumentGallery.Document
    sortProperties: ["-lastAccessed"]
    properties: [ 'url', 'title', 'lastAccessed', 'filePath', 'fileName', 'fileSize',
        'mimeType', 'selected', 'contentType' ]

    function extension(fileName) {
        var separatorIndex = fileName.lastIndexOf(".")
        if (separatorIndex >= 0 && separatorIndex < fileName.length - 1) {
            return fileName.substr(separatorIndex)
        } else {
            return ""
        }
    }

    function baseName(fileName) {
        var separatorIndex = fileName.lastIndexOf(".")
        if (separatorIndex >= 0) {
            return fileName.substr(0, separatorIndex)
        } else {
            return fileName
        }
    }

    function _title(item) {
        return item.fileName
    }

    function _filter(contentItem) {
        return contentItem.fileName.toLowerCase().indexOf(filter) !== -1 &&
                contentItem.mimeType !== "inode/directory"
    }
}
