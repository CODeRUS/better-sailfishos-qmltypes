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

SharePage {
    id: root

    property string text
    property string type: "text/plain"

    showAddAccount: false
    content: {
        "name": text,
        "data": text,
        "type": type,
        // also some non-standard fields for Twitter/Facebook status sharing:
        "status": text,
        "linkTitle": text
    }
    mimeType: type
}
