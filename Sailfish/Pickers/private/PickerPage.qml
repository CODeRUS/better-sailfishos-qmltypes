/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Page {
    // Use var so that we can distinguish empty and undefined title.
    property string title
    property url selectedContent
    property var selectedContentProperties

    // Internal / private property. Might turn to unsupported in future.
    property bool popOnSelection: true

    // The last page from application
    property Item _lastAppPage
    property int _animationDuration: 150

    property Component _background

    function _customSelectionHandler(model, index, selected) {
        _handleSelection(model, index, selected)
    }

    function _handleSelection(model, index, selected) {
        model.updateSelected(index, selected)
        _handleSelectionProperties(model.get(index))
    }

    function _handleSelectionProperties(properties) {
        _updateSelectedContent(properties, properties.url)
        if (popOnSelection) {
            _navigation = PageNavigation.Forward
            if (_lastAppPage) {
                pageStack.pop(_lastAppPage)
            } else {
                pageStack.pop()
            }
        }
    }

    function _updateSelectedContent(properties, url) {
        selectedContentProperties = {
            "fileName": properties.fileName,
            "filePath": properties.filePath,
            "url": properties.url,
            "title": properties.title,
            "mimeType": properties.mimeType,
            "contentType": properties.contentType,
            "fileSize": properties.fileSize
        }
        selectedContent = url
    }

    Item {
        id: background
        anchors.fill: parent
    }

    Component.onCompleted: {
        if (_background) {
            _background.createObject(background)
        }
    }
}
