/****************************************************************************
**
** Copyright (C) 2017 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import QtDocGallery 5.0
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

MultiDocumentPickerDialog {
    _contentModel.contentFilter: GalleryStartsWithFilter {
        property: "filePath"
        value: StandardPaths.download
    }

    //: Placeholder text of downloads search field in content picker
    //% "Search downloads"
    _headerPlaceholderText: qsTrId("components_pickers-ph-search_downloads")

    //: Empty state text if no downloads available. This should be positive and inspiring for the user.
    //% "No downloaded files"
    _emptyPlaceholderText: qsTrId("components_pickers-la-no-downloads-on-device")

    _contentType: ContentType.Download
}
