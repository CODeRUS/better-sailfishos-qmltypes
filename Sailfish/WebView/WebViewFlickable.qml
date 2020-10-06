/****************************************************************************
**
** Copyright (c) 2016 - 2020 Jolla Ltd.
** Copyright (c) 2020 Open Mobile Platform LLC.
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.1
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as SilicaPrivate
import Sailfish.WebView 1.0

SilicaFlickable {
    id: viewFlickable

    property alias webView: webView

    property alias header: headerLoader.sourceComponent
    property alias headerItem: headerLoader.item

    contentWidth: width
    contentHeight: height

    quickScrollEnabled: false
    pressDelay: 0

    interactive: !webView.textSelectionActive

    WebView {
        id: webView

        y: headerLoader.implicitHeight
        _indicatorVerticalOffset: -y
        width: viewFlickable.width
        height: viewFlickable.contentHeight - headerLoader.implicitHeight

        viewportHeight: Math.max(viewFlickable.contentHeight, (webViewPage
                ? ((webViewPage.orientation & Orientation.PortraitMask) ? Screen.height : Screen.width)
                : viewFlickable.height)) - headerLoader.implicitHeight
    }

    Loader {
        id: headerLoader
        width: viewFlickable.width
    }
}
