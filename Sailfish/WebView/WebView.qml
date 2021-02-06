/****************************************************************************
**
** Copyright (c) 2016 - 2020 Jolla Ltd.
** Copyright (c) 2019 - 2020 Open Mobile Platform LLC.
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as SilicaPrivate
import Sailfish.WebView 1.0
import Sailfish.WebView.Controls 1.0
import Sailfish.WebView.Popups 1.0
import Sailfish.WebView.Pickers 1.0

RawWebView {
    id: webview

    property WebViewPage webViewPage: _findParentWithProperty(webview, '__sailfish_webviewpage')
    property bool canShowSelectionMarkers: true
    property real _indicatorVerticalOffset

    readonly property bool textSelectionActive: textSelectionController && textSelectionController.active
    property Item textSelectionController: null
    readonly property int _pageOrientation: webViewPage ? webViewPage.orientation : Orientation.None

    signal linkClicked(string url)

    function _findParentWithProperty(item, propertyName) {
        var parentItem = item.parent
        while (parentItem) {
            if (parentItem.hasOwnProperty(propertyName)) {
                return parentItem
            }
            parentItem = parentItem.parent
        }
        return null
    }

    function _hasWebViewPage() {
        return (webview.webViewPage != null && webview.webViewPage != undefined)
    }

    function clearSelection() {
        if (textSelectionActive) {
            textSelectionController.clearSelection()
        }
    }

    active: !webViewPage
            || webViewPage.status === PageStatus.Active
            || webViewPage.status === PageStatus.Deactivating
    _acceptTouchEvents: !textSelectionActive

    viewportHeight: webViewPage
            ? ((webViewPage.orientation & Orientation.PortraitMask) ? Screen.height : Screen.width)
            : undefined

    orientation: {
        switch (_pageOrientation) {
        case Orientation.Portrait:
            return Qt.PortraitOrientation
        case Orientation.Landscape:
            return Qt.LandscapeOrientation
        case Orientation.PortraitInverted:
            return Qt.InvertedPortraitOrientation
        case Orientation.LandscapeInverted:
            return Qt.InvertedLandscapeOrientation
        default:
            return Qt.PrimaryOrientation
        }
    }

    onOrientationChanged: {
        if (visible) {
            orientationDelayOverlay.opacity = 1
        }
    }

    onContentOrientationChanged: {
        orientationFadeOut.restart()
    }

    onRecvAsyncMessage: {
        if (pickerOpener.message(message, data) || popupOpener.message(message, data)) {
            return
        }

        switch(message) {
            case "embed:linkclicked": {
                webview.linkClicked(data.uri)
                break
            }
            case "Content:SelectionRange": {
                if (textSelectionController === null) {
                    textSelectionController = textSelectionControllerComponent.createObject(
                                webview, {"contentItem" : webview})
                }
                textSelectionController.selectionRangeUpdated(data)
                break
            }
            case "Content:SelectionSwap": {
                if (textSelectionController) {
                    textSelectionController.swap()
                }

                break
            }
            default: {
                break
            }
        }
    }
    onRecvSyncMessage: {
        // sender expects that this handler will update `response` argument
        switch (message) {
        case "Content:SelectionCopied": {
            if (data.succeeded && textSelectionController) {
                textSelectionController.showNotification()
            }
            response.message = {"": ""}
            break
        }
        }
    }

    Component {
        id: textSelectionControllerComponent

        TextSelectionController {
            opacity: canShowSelectionMarkers ? 1.0 : 0.0
            contentWidth: Math.max(webview.contentWidth, webview.width)
            contentHeight: Math.max(webview.contentHeight, webview.height)
            anchors {
                fill: parent
            }

            Behavior on opacity { FadeAnimator {} }
        }
    }

    PickerOpener {
        id: pickerOpener

        property QtObject pageStackOwner: webview._findParentWithProperty(webview, "pageStack")

        pageStack: pageStackOwner ? pageStackOwner.pageStack : undefined
        contentItem: webview
    }

    PopupOpener {
        id: popupOpener

        pageStack: pickerOpener.pageStack
        parentItem: webview.webViewPage || webview
        contentItem: webview
        downloadsEnabled: false

        onAboutToOpenContextMenu: {
            if (Qt.inputMethod.visible) {
                webview.parent.focus = true
            }

            if (data.types.indexOf("content-text") !== -1) {
                // we want to select some content text
                webview.sendAsyncMessage("Browser:SelectionStart", {"xPos": data.xPos, "yPos": data.yPos})
            }
        }
    }

    Rectangle {
        id: orientationDelayOverlay

        width: webview.width
        height: webview.height

        opacity: 0
        color: webview.bgcolor

        NumberAnimation on opacity {
            id: orientationFadeOut

            running: false
            duration: 200
            easing.type: Easing.InOutQuad

            to: 0
        }
    }

    Timer {
        id: orientationDelayFailsafe
        running: !orientationFadeOut.running && orientationDelayOverlay.opacity === 1
        onTriggered: {
            orientationFadeOut.start()
        }
        interval: 1000
    }

    BusyIndicator {
        id: busySpinner
        x: (webview.viewportWidth - width) / 2
        y: webview._indicatorVerticalOffset
           + ((webview.viewportHeight - webview._indicatorVerticalOffset - height) / 2)
        running: true
        visible: webview.loading
        size: BusyIndicatorSize.Large
    }

    SilicaPrivate.VirtualKeyboardObserver {
        id: virtualKeyboardObserver

        readonly property QtObject appWindow: webview._findParentWithProperty(webview, "__silica_applicationwindow_instance")

        active: webview.enabled
        transpose: appWindow ? appWindow._transpose : false
        onImSizeChanged: {
            if (imSize > 0 && opened) {
                webview.virtualKeyboardMargin = virtualKeyboardObserver.imSize
            }
        }

        orientation: webview._pageOrientation

        onOpenedChanged: {
            if (opened) {
                webview.virtualKeyboardMargin = virtualKeyboardObserver.panelSize
            }
        }
        onClosedChanged: {
            if (closed) {
                webview.virtualKeyboardMargin = 0
            }
        }
    }

    Component.onCompleted: {
        webview.loadFrameScript("chrome://embedlite/content/embedhelper.js")
        webview.addMessageListener("embed:linkclicked")
        webview.addMessageListener("Content:ContextMenu")
        webview.addMessageListener("Content:SelectionRange")
        webview.addMessageListener("Content:SelectionCopied")
        webview.addMessageListener("Content:SelectionSwap")
    }
}
