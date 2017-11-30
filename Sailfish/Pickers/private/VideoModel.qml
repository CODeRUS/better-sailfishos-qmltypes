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
    contentType: ContentType.Video
    rootType: DocumentGallery.Video
    sortProperties: ["-lastModified"]
    properties: [ 'url', 'title', 'lastModified', 'filePath', 'fileName', 'fileSize',
        'mimeType', 'duration', 'selected', 'contentType' ]
}
