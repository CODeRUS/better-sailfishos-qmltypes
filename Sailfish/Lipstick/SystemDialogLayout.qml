/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

FocusScope {
    id: layout

    default property alias _data: content.data

    property real bottomPadding
    property alias contentHeight: content.height

    signal dismiss

    anchors.fill: parent

    MouseArea {
        id: blocker

        objectName: "SystemDialogLayout_blocker"
        // block events passing beneath the layout
        anchors.fill: content
        anchors.bottomMargin: -bottomPadding
    }

    Item {
        id: content
        width: parent.width
    }

    MouseArea {
        width: parent.width
        anchors.top: blocker.bottom
        anchors.bottom: parent.bottom
        onClicked: layout.dismiss()

        Rectangle {
            objectName: "CredentialsForm_dismiss"
            anchors.fill: parent
            color: Theme.highlightDimmerColor
            opacity: 0.4
        }
    }
}
