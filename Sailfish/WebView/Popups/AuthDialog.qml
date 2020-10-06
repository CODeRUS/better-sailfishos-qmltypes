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

UserPrompt {
    id: root

    property string hostname
    property string realm
    property bool passwordOnly
    property bool privateBrowsing

    property var username
    property var password
    property var remember

    property alias usernameValue: username.text
    property alias passwordValue: password.text
    property alias rememberValue: remember.checked

    //: Text on the Accept dialog button that accepts browser's auth request
    //% "Log In"
    acceptText: qsTrId("sailfish_components_webview_popups-he-accept_login")

    Column {
        width: parent.width

        Label {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 2
            //: %1 is server URL, %2 is HTTP auth realm
            //% "The server %1 requires authentication. The server says: %2"
            text: qsTrId("sailfish_components_webview_popups-la-auth_requested").arg(hostname).arg(realm)
            wrapMode: Text.Wrap
            color: Theme.highlightColor
        }

        TextField {
            id: username

            width: parent.width
            focus: root.username && root.username.autofocus || false
            visible: !passwordOnly
            //% "Enter your user name"
            placeholderText: qsTrId("sailfish_components_webview_popups-la-enter_username")
            //% "User name"
            label: qsTrId("sailfish_components_webview_popups-la-user_name")

            text: root.username && root.username.value || ""
            inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
            EnterKey.iconSource: "image://theme/icon-m-enter-next"
            EnterKey.onClicked: password.focus = true
        }

        PasswordField {
            id: password

            width: parent.width
            //% "Enter password"
            placeholderText: qsTrId("sailfish_components_webview_popups-la-enter_password")
            text: root.password && root.password.value || ""

            EnterKey.iconSource: (username.text.length > 0 && text.length > 0) ? "image://theme/icon-m-enter-accept"
                                                                               : "image://theme/icon-m-enter-next"
            EnterKey.onClicked: root.accept()
        }

        TextSwitch {
            id: remember

            // If credentials are already remember removing them via this is not feasibible
            // Better to hide the whole checkbox.
            visible: !privateBrowsing && !(root.remember && root.remember.checked)
            checked: false

            //: Remember entered credentials for later use
            //% "Remember credentials"
            text: qsTrId("sailfish_components_webview_popups-remember_credentials")
        }

        Label {
            x: Theme.paddingLarge
            width: parent.width - Theme.paddingLarge * 2
            visible: privateBrowsing
            wrapMode: Text.Wrap
            color: Theme.highlightColor

            //: Description label for user when private mode active (entered credentials are not saved)
            //% "Credential storage is not available in private browsing mode"
            text: qsTrId("sailfish_components_webview_popups-la-private_browsing_credentials_description")
        }
    }
}
