/****************************************************************************
**
** Copyright (c) 2013 - 2016 Jolla Ltd.
** Copyright (c) 2020 Open Mobile Platform LLC.
** Contact: Vesa-Matti Hartikainen <vesa-matti.hartikainen@jolla.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.0
import Sailfish.Silica 1.0

UserPrompt {
    id: dialog

    property string host

    property alias rememberValue: remember.checked

    //: Allow the server to use location
    //% "Allow"
    acceptText: qsTrId("sailfish_components_webview_popups-he-accept_location")

    //: Deny the server to use location
    //% "Deny"
    cancelText: qsTrId("sailfish_components_webview_popups-he-deny_location")

    Column {
        width: parent.width
        spacing: Theme.paddingMedium

        Label {
            x: Theme.horizontalPageMargin
            width: parent.width - x * 2

            //: %1 is the site that wants know user location
            //% "Allow %1 to use your location?"
            text: qsTrId("sailfish_components_webview_popups-la-location_request")
                        .arg(host)

            wrapMode: Text.WordWrap
            color: Theme.highlightColor
        }

        TextSwitch {
            id: remember

            //: Remember decision for this site for later use
            //% "Remember for this site"
            text: qsTrId("sailfish_components_webview_popups-remember_for_site")
        }
    }
}
