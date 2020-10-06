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
import Sailfish.WebView.Popups 1.0 as Popups
import "GeolocationHosts.js" as Geolocation

Timer {
    id: root

    property var pageStack
    property Item parentItem
    property QtObject tabModel: null
    property QtObject contentItem
    readonly property bool active: contextMenu && contextMenu.active || false
    property Item contextMenu

    readonly property var listeners: ["embed:alert", "embed:confirm", "embed:prompt",
        "embed:login", "embed:auth", "embed:permissions", "Content:ContextMenu"]

    property var authDialogContentItem
    property var authDialogData
    property var authDialogWinId

    property bool downloadsEnabled: true

    property Component _contextMenuComponent

    signal aboutToOpenContextMenu(var data)

    function getCheckbox(data) {
        var inputs = data.inputs
        for (var i = 0; inputs && (i < inputs.length); ++i) {
            if (inputs[i].hint === "preventAddionalDialog") {
                return inputs[i]
            }
        }
        return null
    }

    // Returns true if message is handled.
    function message(topic, data) {
        if (!handlesMessage(topic)) {
            return false
        }

        if (!contentItem) {
            console.warn("Picker has no contentItem. Assign / Bind contentItem for each PickerOpener.")
            return false
        }

        if (!pageStack) {
            console.log("PopupOpener has no pageStack. Add missing binding.")
            return false
        }

        var winId = data.winId
        switch (topic) {
        case "embed:alert": {
            var obj = pageStack.animatorPush(Qt.resolvedUrl("AlertDialog.qml"), {
                                                 "text": data.text,
                                                 "checkbox": getCheckbox(data)
                                             })
            obj.pageCompleted.connect(function(dialog) {
                // TODO: also the Async message must be sent when window gets closed
                dialog.done.connect(function() {
                    contentItem.sendAsyncMessage("alertresponse", {
                                                     "winId": winId,
                                                     "checkvalue": dialog.checkboxValue
                                                 })
                })
            })
            break
        }
        case "embed:confirm": {
            var obj = pageStack.animatorPush(Qt.resolvedUrl("ConfirmDialog.qml"), {
                                                 "text": data.text,
                                                 "checkbox": getCheckbox(data)
                                             })
            obj.pageCompleted.connect(function(dialog) {
                // TODO: also the Async message must be sent when window gets closed
                dialog.accepted.connect(function() {
                    contentItem.sendAsyncMessage("confirmresponse",
                                                 {
                                                     "winId": winId,
                                                     "accepted": true,
                                                     "checkvalue": dialog.checkboxValue
                                                 })
                })
                dialog.rejected.connect(function() {
                    contentItem.sendAsyncMessage("confirmresponse",
                                                 {
                                                     "winId": winId,
                                                     "accepted": false,
                                                     "checkvalue": dialog.checkboxValue
                                                 })
                })
            })
            break
        }
        case "embed:prompt": {
            var obj = pageStack.animatorPush(Qt.resolvedUrl("PromptDialog.qml"), {
                                                 "text": data.text,
                                                 "value": data.defaultValue,
                                                 "checkbox": getCheckbox(data)
                                             })
            obj.pageCompleted.connect(function(dialog) {
                // TODO: also the Async message must be sent when window gets closed
                dialog.accepted.connect(function() {
                    contentItem.sendAsyncMessage("promptresponse",
                                                 {
                                                     "winId": winId,
                                                     "accepted": true,
                                                     "promptvalue": dialog.value,
                                                     "checkvalue": dialog.checkboxValue
                                                 })
                })
                dialog.rejected.connect(function() {
                    contentItem.sendAsyncMessage("promptresponse",
                                                 {
                                                     "winId": winId,
                                                     "accepted": false,
                                                     "checkvalue": dialog.checkboxValue
                                                 })
                })
            })
            break
        }
        case "embed:login": {
            var obj = pageStack.animatorPush(Qt.resolvedUrl("PasswordManagerDialog.qml"),
                                    { "contentItem": contentItem, "requestId": data.id,
                                      "notificationType": data.name, "formData": data.formdata })
            break
        }
        case "embed:auth": {
            root.openAuthDialog(contentItem, data, winId)
            break
        }
        case "embed:permissions": {
            if (data.title === "geolocation"
                    && Popups.LocationSettings.locationEnabled) {
                switch (Geolocation.response(data.host)) {
                    case "accepted": {
                        contentItem.sendAsyncMessage("embedui:permissions",
                                                 { "allow": true, "checkedDontAsk": false, "id": data.id })
                        break
                    }
                    case "rejected": {
                        contentItem.sendAsyncMessage("embedui:permissions",
                                                 { "allow": false, "checkedDontAsk": false, "id": data.id })
                        break
                    }
                    default: {
                        var obj = pageStack.animatorPush(Qt.resolvedUrl("LocationDialog.qml"), {"host": data.host })
                        obj.pageCompleted.connect(function(dialog) {
                            dialog.accepted.connect(function() {
                                contentItem.sendAsyncMessage("embedui:permissions",
                                                             { "allow": true, "checkedDontAsk": false, "id": data.id })
                                Geolocation.addResponse(data.host, "accepted")
                            })
                            dialog.rejected.connect(function() {
                                contentItem.sendAsyncMessage("embedui:permissions",
                                                             { "allow": false, "checkedDontAsk": false, "id": data.id })
                                Geolocation.addResponse(data.host, "rejected")
                            })
                        })
                        break
                    }
                }
            } else {
                // Currently we don't support other permission requests.
                sendAsyncMessage("embedui:permissions",
                                 { "allow": false, "checkedDontAsk": false, "id": data.id })
            }
            break
        }
        case "Content:ContextMenu": {
            root._openContextMenu(data)
            break
        }
        }
        // If we end up here, message has been handled.
        return true
    }

    function handlesMessage(topic) {
        return listeners.indexOf(topic) >= 0
    }

    function openAuthDialog(contentItem, data, winId) {
        if (pageStack.busy) {
            root._delayedOpenAuthDialog(contentItem, data, winId)
        } else {
            root._immediateOpenAuthDialog(contentItem, data, winId)
        }
    }

    function _delayedOpenAuthDialog(contentItem, data, winId) {
        authDialogContentItem = contentItem
        authDialogData = data
        authDialogWinId = winId
        start()
    }

    function _immediateOpenAuthDialog(contentItem, data, winId) {
        var inputs = data.inputs
        var username
        var password
        var remember

        for (var i = 0; i < inputs.length; ++i) {
            if (inputs[i].hint === "username") {
                username = inputs[i]
            } else if (inputs[i].hint === "password") {
                password = inputs[i]
            } else if (inputs[i].hint === "remember") {
                remember = inputs[i]
            }
        }

        var passwordOnly = !username
        var obj = pageStack.animatorPush(Qt.resolvedUrl("AuthDialog.qml"),
                                    {"hostname": data.text, "realm": data.title,
                                     "username": username, "password": password,
                                     "remember": remember, "passwordOnly": passwordOnly,
                                     "privateBrowsing": data.privateBrowsing})
        obj.pageCompleted.connect(function(dialog) {
            dialog.accepted.connect(function () {
                contentItem.sendAsyncMessage("authresponse",
                                             { "winId": winId, "accepted": true,
                                                 "username": dialog.usernameValue, "password": dialog.passwordValue,
                                                 "remember": dialog.rememberValue })
            })
            dialog.rejected.connect(function() {
                contentItem.sendAsyncMessage("authresponse",
                                             { "winId": winId, "accepted": false})
            })
        })
    }

    function _openContextMenu(data) {
        root.aboutToOpenContextMenu(data)
        if (data.types.indexOf("image") !== -1 || data.types.indexOf("link") !== -1) {
            var linkHref = data.linkURL
            var imageSrc = data.mediaURL
            var linkTitle = data.linkTitle
            var contentType = data.contentType

            if (contextMenu) {
                contextMenu.linkHref = linkHref
                contextMenu.imageSrc = imageSrc
                contextMenu.linkTitle = linkTitle.trim()
                contextMenu.linkProtocol = data.linkProtocol || ""
                contextMenu.contentType = contentType
                contextMenu.tabModel = root.tabModel
                contextMenu.viewId = contentItem.uniqueID()
                contextMenu.pageStack = root.pageStack
                contextMenu.show()
            } else {
                _contextMenuComponent = Qt.createComponent(Qt.resolvedUrl("ContextMenu.qml"))
                if (_contextMenuComponent.status !== Component.Error) {
                    contextMenu = _contextMenuComponent.createObject(parentItem,
                                                            {
                                                                "linkHref": linkHref,
                                                                "imageSrc": imageSrc,
                                                                "linkTitle": linkTitle && linkTitle.trim() || "",
                                                                "linkProtocol": data.linkProtocol,
                                                                "contentType": contentType,
                                                                "tabModel": root.tabModel,
                                                                "viewId": contentItem.uniqueID(),
                                                                "pageStack": pageStack,
                                                                "downloadsEnabled": root.downloadsEnabled
                                                            })
                    contextMenu.show()
                } else {
                    console.log("Can't load ContextMenu.qml")
                }
            }
        }
    }

    repeat: false
    running: false
    interval: 600 // page transition delay.
    onTriggered: openAuthDialog(authDialogContentItem, authDialogData, authDialogWinId)

    Component.onCompleted: {
        // Warmup location settings.
        Popups.LocationSettings.locationEnabled
        if (contentItem) {
            contentItem.addMessageListeners(listeners)
        } else {
            console.log("PopupOpener has no contentItem. Each created WebView/WebPage",
                        "instance can have own PopupOpener. Add missing binding.")
        }
    }
}
