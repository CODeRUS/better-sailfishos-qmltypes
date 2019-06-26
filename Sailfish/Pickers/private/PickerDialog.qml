/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: pickerDialog

    property string acceptText
    property ListModel selectedContent: SelectedContentModel {}
    property SelectedContentModel _selectedModel
    property int _animationDuration: 150

    property Component _background
    property bool _clearOnBackstep: true

    readonly property int _selectedCount: _selectedModel ? _selectedModel.count : 0

    allowedOrientations: Orientation.All
    canAccept: _selectedModel && _selectedModel.count > 0 ? true : false
    onDone: {
        if (result == DialogResult.Accepted) {
            var selectedContent = selectedModelComponent.createObject(pickerDialog)
            for (var i = 0; i < _selectedModel.count; ++i) {
                var properties = _selectedModel.get(i)
                selectedContent.append({
                                           "fileName": properties.fileName,
                                           "filePath": properties.filePath,
                                           "url": properties.url,
                                           "title": properties.title,
                                           "mimeType": properties.mimeType,
                                           "contentType": properties.contentType,
                                           "fileSize": properties.fileSize
                                       })
            }
            pickerDialog.selectedContent = selectedContent
        } else if (_clearOnBackstep) {
            _selectedModel.clear()
        }
    }

    Item {
        id: background
        anchors.fill: parent
    }

    Component {
        id: selectedModelComponent

        SelectedContentModel {}
    }

    Component.onCompleted: {
        if (_background) {
            _background.createObject(background)
        }

        if (!_selectedModel) {
            _selectedModel = selectedModelComponent.createObject(pickerDialog)
        }

        if (selectedContent) {
            var count = selectedContent.count
            for (var i = 0; i < count; ++i) {
                var contentItem = selectedContent.get(i)
                _selectedModel.append(contentItem)
            }
        }
    }
}
