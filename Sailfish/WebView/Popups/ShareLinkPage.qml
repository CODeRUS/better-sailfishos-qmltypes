/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Antti Seppälä <antti.seppala@jollamobile.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.TransferEngine 1.0

SharePage {
    id: page

    property string link
    property string linkTitle

    //: List header for link sharing method list
    //% "Share link"
    header: qsTrId("sailfish_components_webview_popups-he-share_link")
    mimeType: "text/x-url"
    content: {
        "type": "text/x-url",
        "status": page.link,
        "linkTitle": page.linkTitle
    }
    showAddAccount: false
}
