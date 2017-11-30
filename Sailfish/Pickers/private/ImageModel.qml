/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

ContentModel {
    contentType: ContentType.Image
    // Similarly as in gallery

    contentFilter: GalleryStartsWithFilter {
        property: "filePath"
        value: StandardPaths.music
        negated: true
    }
    rootType: DocumentGallery.Image
    sortProperties: ["-lastModified"]
    properties: [ 'url', 'title', 'lastModified', 'filePath', 'fileName', 'fileSize',
        'mimeType', 'width', 'height', 'selected', 'contentType', 'orientation' ]
}
