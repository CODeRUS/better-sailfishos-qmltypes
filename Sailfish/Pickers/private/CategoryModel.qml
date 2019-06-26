/****************************************************************************
**
** Copyright (C) 2013-2017 Jolla Ltd.
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
                        qsTrId("components_pickers-li-music_category"),

                        //: Downloads category name for list item
                        //% "Downloads"
                        qsTrId("components_pickers-li-downloads_category"),

                        //: File system category name for list item
                        //% "File system"
                        qsTrId("components_pickers-li-file_system_category")

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
            categories = [{subview: "MultiDocumentPickerDialog.qml", acceptDestination: true},
                          {subview: "MultiImagePickerDialog.qml", acceptDestination: true},
                          {subview: "MultiVideoPickerDialog.qml", acceptDestination: true},
                          {subview: "MultiMusicPickerDialog.qml", acceptDestination: true},
                          {subview: "MultiDownloadPickerDialog.qml", acceptDestination: true},
                          {subview: "MultiFilePickerDialog.qml", acceptDestination: false}]
        } else {
            categories = [{subview: "DocumentPickerPage.qml"},
                          {subview: "ImagePickerPage.qml"},
                          {subview: "VideoPickerPage.qml"},
                          {subview: "MusicPickerPage.qml"},
                          {subview: "DownloadPickerPage.qml"},
                          {subview: "FilePickerPage.qml"}
                    ]
        }

        var len = categories.length
        var index = 0
        for (; index < len; ++index) {
              var category = categories[index]
            if (category.subview.indexOf("DocumentPicker") >= 0) {
                category["contentType"] = ContentType.Document
                category["properties"] = { "_clearOnBackstep": false }
                category["iconSource"] = "image://theme/icon-m-file-document"
            } else if (category.subview.indexOf("ImagePicker") >= 0) {
                category["contentType"] = ContentType.Image
                category["properties"] = { "_clearOnBackstep": false }
                category["iconSource"] = "image://theme/icon-m-file-image"
            } else if (category.subview.indexOf("VideoPicker") >= 0) {
                category["contentType"] = ContentType.Video
                category["properties"] = { "_clearOnBackstep": false }
                category["iconSource"] = "image://theme/icon-m-file-video"
            } else if (category.subview.indexOf("MusicPicker") >= 0) {
                category["contentType"] = ContentType.Music
                category["properties"] = { "_clearOnBackstep": false }
                category["iconSource"] = "image://theme/icon-m-file-audio"
            } else if (category.subview.indexOf("DownloadPicker") >= 0) {
                category["contentType"] = ContentType.Download
                category["properties"] = { "_clearOnBackstep": false }
                category["iconSource"] = "image://theme/icon-m-device-download"
            } else if (category.subview.indexOf("FilePicker") >= 0) {
                category["contentType"] = ContentType.File
                category["properties"] = {
                    "showSystemFiles": false,
                    "_clearOnBackstep": false
                }
                category["iconSource"] = "image://theme/icon-m-file-other"
            }

            append(categories[index])
        }
    }
}
