/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Valerio Valerio <valerio.valerio@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Contacts 1.0

CompressibleItem {
    id: root

    property alias placeholderText: recipientField.placeholderText
    property alias summaryPlaceholderText: recipientField.summaryPlaceholderText
    property alias summary: recipientField.summary
    property alias contactSearchModel: recipientField.contactSearchModel
    property alias empty: recipientField.empty
    property alias showLabel: recipientField.showLabel

    signal lastFieldExited

    function recipientsToString() {
        return recipientField.recipientsToString()
    }

    function setRecipients(recipients) {
        recipientField.setEmailRecipients(recipients)
    }

    function forceActiveFocus() {
        recipientField.forceActiveFocus()
    }

    width: parent.width
    compressible: recipientField.empty
    expandedHeight: recipientField.height

    RecipientField {
        id: recipientField
        visible: !root.compressed
        onLastFieldExited: root.lastFieldExited()
        inputMethodHints: Qt.ImhNoPredictiveText | Qt.ImhNoAutoUppercase | Qt.ImhEmailCharactersOnly
    }
}
