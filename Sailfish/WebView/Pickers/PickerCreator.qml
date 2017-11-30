/****************************************************************************
**
** Copyright (C) 2014-2016 Jolla Ltd.
** Contact: Vesa-Matti Hartikainen <vesa-matti.hartikainen@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.1
import Sailfish.Pickers 1.0

Item {
    id: pickerCreator
    property int winid
    property QtObject contentItem
    property int filter: _nsIFilePicker_filterAll
    property int mode
    property Item pageStack

    readonly property int _nsIFilePicker_modeOpen: 0
    readonly property int _nsIFilePicker_modeOpenMultiple: 3
    readonly property int _nsIFilePicker_filterAll: 1
    readonly property int _nsIFilePicker_filterImages: 8
    readonly property int _nsIFilePicker_filterAudio: 256
    readonly property int _nsIFilePicker_filterVideo: 512


    function sendResponse(selectedContent) {
        var scheme = "file://"
        var filePath = selectedContent.toString()

        if (filePath.indexOf(scheme) === 0) {
            filePath = filePath.slice(scheme.length, filePath.length)
        }

        contentItem.sendAsyncMessage("filepickerresponse",
                                 {
                                     "winid": winid,
                                     "accepted": filePath ? true : false,
                                                            "items": [filePath]
                                 })
        pickerCreator.destroy()
    }

    function sendResponseList(selectedContent) {
        var scheme = "file://"
        var result = []
        for (var i = 0; selectedContent && i < selectedContent.count; i++) {
            var filePath = selectedContent.get(i).filePath
            if (filePath.indexOf(scheme) === 0) {
                filePath = filePath.slice(scheme.length, filePath.length)
            }
            result.push(filePath)
        }

        contentItem.sendAsyncMessage("filepickerresponse",
                                 {
                                     "winid": winid,
                                     "accepted": result.length > 0,
                                     "items": result
                                 })
        pickerCreator.destroy()
    }

    Component.onCompleted: {
        if (mode == _nsIFilePicker_modeOpenMultiple) {
            switch (filter) {
            case _nsIFilePicker_filterImages:
                pageStack.push(Qt.resolvedUrl("MultiImagePicker.qml"), {"creator": pickerCreator})
                break
            case _nsIFilePicker_filterAudio:
                pageStack.push(Qt.resolvedUrl("MultiMusicPicker.qml"), {"creator": pickerCreator})
                break
            case _nsIFilePicker_filterVideo:
                pageStack.push(Qt.resolvedUrl("MultiVideoPicker.qml"), {"creator": pickerCreator})
                break
            default:
                pageStack.push(Qt.resolvedUrl("MultiContentPicker.qml"), {"creator": pickerCreator})
            }
        } else if (mode == _nsIFilePicker_modeOpen) {
            switch (filter) {
            case _nsIFilePicker_filterImages:
                pageStack.push(Qt.resolvedUrl("ImagePicker.qml"), {"creator": pickerCreator})
                break
            case _nsIFilePicker_filterAudio:
                pageStack.push(Qt.resolvedUrl("MusicPicker.qml"), {"creator": pickerCreator})
                break
            case _nsIFilePicker_filterVideo:
                pageStack.push(Qt.resolvedUrl("VideoPicker.qml"), {"creator": pickerCreator})
                break
            default:
                pageStack.push(Qt.resolvedUrl("ContentPicker.qml"), {"creator": pickerCreator})
            }
        } else {
            console.log("Unsupported file open mode: " + mode)
        }
    }
}
