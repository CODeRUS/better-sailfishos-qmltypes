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

QtObject {
    id: contentModel

    property string filter
    property ListModel model: ListModel {}
    property int count: model.count
    property int contentType: ContentType.InvalidType
    property alias rootType: galleryModel.rootType
    property alias properties: galleryModel.properties
    property alias sortProperties: galleryModel.sortProperties
    property alias status: galleryModel.status
    property ListModel selectedModel
    property bool singleSelectionMode
    property alias contentFilter: galleryModel.filter

    // Used only in singleSelectionMode
    property int _selectedIndex: -1

    onFilterChanged: {
        if (singleSelectionMode) {
            _updateSelected(_selectedIndex, false)
            _selectedIndex = -1
        }

        _update()
    }

    function updateSelected(index, selected) {
        if  (singleSelectionMode) {
            if (_selectedIndex !== index) {
                _updateSelected(_selectedIndex, false)
            }
            _updateSelected(index, selected)
            _selectedIndex = selected ? index : -1
        } else {
            _updateSelected(index, selected)
        }
    }

    function get(index) {
        return model.get(index)
    }

    function _title(item) {
        return item.title
    }

    function _updateSelected(index, selected) {
        if (index >= 0 && index < model.count) {
            model.setProperty(index, "selected", selected)
            if (selectedModel) {
                selectedModel.update(model.get(index))
            }
        }
    }

    function _update() {
        var filteredContent = _contentQuery(contentModel._filter)
        var filteredContentLen = filteredContent.length
        var modelCount = model.count
        while (modelCount > filteredContentLen) {
            model.remove(modelCount - 1)
            --modelCount
        }
        for (var index = 0; index < filteredContent.length; index++) {
            if (index < model.count) {
                for (var propIndex in contentModel.properties) {
                    var prop = contentModel.properties[propIndex]
                    var value = filteredContent[index][prop]
                    model.setProperty(index, prop, value)
                }
            } else {
                var row = filteredContent[index]
                model.append(row)
            }
        }
    }

    function _filter(contentItem) {
        return contentItem.fileName.toLowerCase().indexOf(filter) !== -1
    }

    function _contentQuery(filterFunction) {
        var len = _documentGalleryModel.count;
        var filteredContent = [];
        for (var i = 0; i < len; ++i) {
            var contentItem = _documentGalleryModel.get(i)
            if (filterFunction(contentItem)) {
                var selected = false
                if (selectedModel) {
                    selected = selectedModel.selected(contentItem.filePath)
                }

                contentItem["selected"] = selected
                contentItem["contentType"] = contentModel.contentType
                contentItem["title"] = _title(contentItem)
                // ListModel is identifying the QUrl in contentItem as an object and converting
                // to a QVariantMap, converting to a string prevents this.
                contentItem["url"] = "" + contentItem.url
                filteredContent.push(contentItem)
            }
        }
        return filteredContent
    }

    property QtObject _documentGalleryModel: DocumentGalleryModel {
        id: galleryModel

        property bool ready

        autoUpdate: true

        onCountChanged: {
            if (ready) {
                _update()
            }
        }

        Component.onCompleted: {
            _update()
            ready = true
        }
    }
}
