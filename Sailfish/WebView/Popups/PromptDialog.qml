/****************************************************************************
**
** Copyright (C) 2013-2016 Jolla Ltd.
** Contact: Dmitry Rozhkov <dmitry.rozhkov@jollamobile.com>
**
****************************************************************************/

/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/. */

import QtQuick 2.0
import Sailfish.Silica 1.0

UserPrompt {
    id: dialog

    property alias text: input.placeholderText
    property alias value: input.text

    canAccept: input.text.length > 0
    //: Text on the Accept dialog button that accepts browser's prompt() messages
    //% "Ok"
    acceptText: qsTrId("sailfish_components_webview_popups-he-accept_prompt")

    TextField {
        id: input

        anchors.centerIn: parent
        width: parent.width
        focus: true
        label: text.length > 0 ? dialog.text : ""
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase
        EnterKey.enabled: text.length > 0
        EnterKey.iconSource: "image://theme/icon-m-enter-accept"
        EnterKey.onClicked: dialog.accept()
    }
}
