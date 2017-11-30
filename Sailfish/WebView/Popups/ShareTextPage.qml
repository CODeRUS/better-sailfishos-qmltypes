/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Raine Makelainen <raine.makelainen@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

Page {
    id: root

    property string text
    property string type: "text/plain"
    property string icon: "icon-launcher-browser"

    ShareMethodList {
        id: shareMethodList

        anchors.fill: parent
        header: PageHeader {
            //: List header for sharing method list (generic)
            //% "Share"
            title: qsTrId("sailfish_components_webview_popups-he-share")
        }
        content: {
            "name": text,
            "data": text,
            "type": type,
            "icon": icon,
            // also some non-standard fields for Twitter/Facebook status sharing:
            "status" : text,
            "linkTitle" : text
        }
        filter: type

        ViewPlaceholder {
            enabled: shareMethodList.count == 0 && shareMethodList.model.ready
            //: Empty state for share method selection page
            //% "No sharing accounts available. You can add accounts in settings"
            text: qsTrId("sailfish_components_webview_popups-no-share-methods")
        }
    }
}
