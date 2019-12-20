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

    property alias contentItem: content
    property alias contentHeight: content.height

    signal dismiss

    anchors.fill: parent

    MouseArea {
        anchors.fill: parent
        onClicked: layout.dismiss()
    }

    MouseArea {
        id: blocker

        objectName: "SystemDialogLayout_blocker"
        // block events passing beneath the layout
        anchors.fill: content
    }

    Item {
        id: content
        width: parent.width
    }
}
