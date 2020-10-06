/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Dmitry Rozhkov <dmitry.rozhkov@jollamobile.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.WebView.Popups 1.0

Rectangle {
    id: root

    property string linkHref
    property string linkTitle
    property string linkProtocol
    property string imageSrc
    property string contentType
    property PageStack pageStack
    property QtObject tabModel: null

    property int viewId
    readonly property bool active: visible
    readonly property bool landscape: width > height

    property bool downloadsEnabled: true

    readonly property string url: !isJavascriptFunction ? linkHref : ""
    readonly property bool knownPlatformProtocol: isMailto || isTel || isSMS || isGeo
    readonly property bool isJavascriptFunction: linkProtocol === "javascript"

    // Image has source. That can be used to distinguish from other links.
    readonly property bool isImage: !isJavascriptFunction && imageSrc.length > 0

    // All except image elements are considered as links.
    readonly property bool isLink: !isJavascriptFunction && linkHref.length > 0 && imageSrc.length === 0

    // Separate hyper text links from other content types.
    readonly property bool isHyperTextLink: linkProtocol === "http" || linkProtocol === "https" || linkProtocol === "file"

    // Known platfrom content types.
    readonly property bool isMailto: linkProtocol === "mailto"
    readonly property bool isTel: linkProtocol === "tel"
    readonly property bool isSMS: linkProtocol === "sms"
    readonly property bool isGeo: linkProtocol === "geo"
    readonly property bool isNavigable: isLink && !knownPlatformProtocol && !isImage

    visible: opacity > 0.0
    opacity: 0.0

    width: parent.width
    height: parent.height
    gradient: Gradient {
        GradientStop { position: 0.0; color: Theme.highlightDimmerColor }
        GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightDimmerColor, .91) }
    }

    Behavior on opacity { FadeAnimation { duration: 300 } }

    Column {
        width: parent.width
        spacing: Theme.paddingMedium
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge*2

        Label {
            id: title
            anchors.horizontalCenter: parent.horizontalCenter
            visible: root.linkTitle.length > 0
            text: root.linkTitle
            width: root.width - Theme.paddingLarge*2
            elide: Text.ElideRight
            wrapMode: Text.Wrap
            maximumLineCount: 2
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeExtraLarge
            horizontalAlignment: Text.AlignHCenter
            opacity: .6
        }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Theme.highlightColor
            text: root.imageSrc.length > 0 ? root.imageSrc : root.url
            width: root.width - Theme.paddingLarge*2
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: landscape ? 1 : 4
            font.pixelSize: title.visible ? Theme.fontSizeMedium : Theme.fontSizeExtraLarge
            horizontalAlignment: Text.AlignHCenter
            opacity: .6
        }
    }

    Column {
        id: menu

        property Item highlightedItem

        anchors.bottom: parent.bottom
        anchors.bottomMargin: landscape ? Theme.paddingLarge : Theme.itemSizeSmall
        width: parent.width

        MenuItem {
            visible: !isHyperTextLink && !isImage
            text: {
                if (isMailto) {
                    //% "Write email"
                    return qsTrId("sailfish_components_webview_popups-me-write-email")
                } else if (isTel) {
                    //: Call, context of calling via voice call
                    //% "Call"
                    return qsTrId("sailfish_components_webview_popups-me-call")
                } else if (isSMS) {
                    //: Send message (sms)
                    //% "Send message"
                    return qsTrId("sailfish_components_webview_popups-me-send-message")
                } else {
                    //: Open link in current tab
                    //% "Open link"
                    return qsTrId("sailfish_components_webview_popups-me-open_link")
                }
            }

            onClicked: {
                root._hide()
                Qt.openUrlExternally(root.linkHref)
            }
        }

        MenuItem {
            visible: root.isNavigable && !!tabModel
            //: Open link in a new tab from browser context menu
            //% "Open link in a new tab"
            text: qsTrId("sailfish_components_webview_popups-me-open_link_in_new_tab")
            onClicked: {
                root._hide()
                tabModel.newTab(root.linkHref, root.linkTitle)
            }
        }

        MenuItem {
            visible: root.isLink
            //: Share link from browser context menu
            //% "Share"
            text: qsTrId("sailfish_components_webview_popups-me-share_link")
            Component {
                id: shareLinkPage
                ShareLinkPage {}
            }
            onClicked: {
                root._hide()
                if (pageStack != null && pageStack != undefined) {
                    pageStack.animatorPush(shareLinkPage, {"link" : root.linkHref, "linkTitle": root.linkTitle})
                }
            }
        }

        MenuItem {
            visible: !root.isImage
            //: Copy link to clipboard from browser context menu
            //% "Copy to clipboard"
            text: qsTrId("sailfish_components_webview_popups-me-copy_to_clipboard")
            onClicked: {
                root._hide()
                // Copy either url or title
                Clipboard.text = root.url || root.linkTitle
            }
        }

        DownloadMenuItem {
            visible: root.downloadsEnabled && root.isNavigable && downloadFileTargetUrl
            //: This menu item saves link to downloads.
            //% "Save link"
            text: qsTrId("sailfish_components_webview_popups-me-save_link")
            targetDirectory: StandardPaths.download
            linkUrl: root.linkHref
            contentType: root.contentType
            viewId: root.viewId
            onClicked: root._hide()
        }

        MenuItem {
            visible: root.isImage && !!tabModel
            //: Open image in a new tab from browser context menu
            //% "Open image in a new tab"
            text: qsTrId("sailfish_components_webview_popups-me-open_image_in_new_tab")
            onClicked: {
                root._hide()
                tabModel.newTab(root.imageSrc, "")
            }
        }

        DownloadMenuItem {
            visible: root.downloadsEnabled && root.isImage && downloadFileTargetUrl
            //: This menu item saves image to Gallery application
            //% "Save to Gallery"
            text: qsTrId("sailfish_components_webview_popups-me-save_image_to_gallery")
            targetDirectory: StandardPaths.pictures
            linkUrl: root.imageSrc
            contentType: root.contentType
            viewId: root.viewId
            onClicked: root._hide()
        }

        function highlightItem(yPos) {
            var xPos = width/2
            var child = childAt(xPos, yPos)
            if (!child) {
                setHighlightedItem(null)
                return
            }
            var parentItem
            while (child) {
                if (child && child.hasOwnProperty("__silica_menuitem") && child.enabled) {
                    setHighlightedItem(child)
                    break
                }
                parentItem = child
                yPos = parentItem.mapToItem(child, xPos, yPos).y
                child = parentItem.childAt(xPos, yPos)
            }
        }

        function setHighlightedItem(item) {
            if (item === highlightedItem) {
                return
            }
            if (highlightedItem) {
                highlightedItem.down = false
            }
            highlightedItem = item
            if (highlightedItem) {
                highlightedItem.down = true
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        onPressed: menu.highlightItem(mouse.y - menu.y)
        onPositionChanged: menu.highlightItem(mouse.y - menu.y)
        onCanceled:  menu.setHighlightedItem(null)
        onReleased: {
            if (menu.highlightedItem !== null) {
                menu.highlightedItem.down = false
                menu.highlightedItem.clicked()
            } else {
                onClicked: root._hide()
            }
        }
    }

    function show() {
        opacity = 1.0
    }

    function _hide() {
        opacity = 0.0
    }
}
