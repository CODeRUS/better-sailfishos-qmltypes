/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.2

QtObject {
    property var pageStack
    property QtObject contentItem
    readonly property var listeners: ["embed:filepicker", "embed:selectasync"]

    // Defer compilation of picker components
    readonly property string _multiSelectComponentUrl: Qt.resolvedUrl("MultiSelectDialog.qml")
    readonly property string _singleSelectComponentUrl: Qt.resolvedUrl("SingleSelectPage.qml")
    readonly property string _filePickerComponentUrl: Qt.resolvedUrl("PickerCreator.qml")
    property Component _filePickerComponent

    // Returns true if message is handled.
    function message(topic, data) {
        if (!handlesMessage(topic)) {
            return false
        }

        if (!contentItem) {
            console.warn("PickerOpener has no contentItem. Assign / Bind contentItem for each PickerOpener.")
            return false
        }

        if (!pageStack) {
            console.log("PickerOpener has no pageStack. Add missing binding.")
            return false
        }

        var winId = data.winId
        switch (topic) {
        case "embed:selectasync": {
            pageStack.animatorPush(data.multiple ? _multiSelectComponentUrl : _singleSelectComponentUrl,
                                           { "options": data.options, "contentItem": contentItem })
            break
        }
        case "embed:filepicker": {
            if (!_filePickerComponent) {
                _filePickerComponent = Qt.createComponent(_filePickerComponentUrl)
            }

            if (_filePickerComponent.status === Component.Ready) {
                _filePickerComponent.createObject(pageStack, {
                                                      "pageStack": pageStack,
                                                      "winId": winId,
                                                      "contentItem": contentItem,
                                                      "mimeType": data.mimeType,
                                                      "mode": data.mode})
            } else if (_filePickerComponent.status === Component.Error) {
                // Component development time issue, component creation should newer fail.
                console.warn("PickerOpener failed to create PickerOpener: ", _filePickerComponent.errorString())
            }
            break
        }
        }
        // If we end up here, message has been handled.
        return true
    }

    function handlesMessage(topic) {
        return listeners.indexOf(topic) >= 0
    }

    Component.onCompleted: {
        if (contentItem) {
            contentItem.addMessageListeners(listeners)
        } else {
            console.log("PickerOpener has no contentItem. Each created WebView/WebPage",
                        "instance can have own PickerOpener. Add missing binding.")
        }
    }
}
