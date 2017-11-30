/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Pickers 1.0

ListModel {
    id: categoryModel

    property bool multiPicker

    function category(index) {
        if (category["text"] === undefined) {
            category.text = [
                        //: Documents category name for list item
                        //% "Documents"
                        qsTrId("components_pickers-li-document_category"),

                        //: Images category name for list item
                        //% "Images"
                        qsTrId("components_pickers-li-images_category"),

                        //: Videos category name for list item
                        //% "Videos"
                        qsTrId("components_pickers-li-videos_category"),

                        //: Music category name for list item
                        //% "Music"
                        qsTrId("components_pickers-li-music_category")

//                        //: People category name for list item
//                        //% "People"
//                        qsTrId("components_pickers-li-people_category")
                    ]
        }
        return category.text[index]
    }

    Component.onCompleted: {
        var categories
        if (multiPicker) {
            categories = [{subview: "MultiDocumentPickerDialog.qml", contentType: ContentType.Document},
                          {subview: "MultiImagePickerDialog.qml", contentType: ContentType.Image},
                          {subview: "MultiVideoPickerDialog.qml", contentType: ContentType.Video},
                          {subview: "MultiMusicPickerDialog.qml", contentType: ContentType.Music}]
        } else {
            categories = [{subview: "DocumentPickerPage.qml", contentType: ContentType.Document},
                          {subview: "ImagePickerPage.qml", contentType: ContentType.Image},
                          {subview: "VideoPickerPage.qml", contentType: ContentType.Video},
                          {subview: "MusicPickerPage.qml", contentType: ContentType.Music}]
        }

        var len = categories.length
        var index = 0
        for (; index < len; ++index) {
            append(categories[index])
        }
    }
}
