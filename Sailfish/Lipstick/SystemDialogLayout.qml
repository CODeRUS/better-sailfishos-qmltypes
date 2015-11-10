/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: layout

    default property alias _data: content.data

    property real bottomPadding
    property alias contentHeight: content.height

    signal dismiss

    anchors.fill: parent

    Rectangle {
        id: background
        anchors.fill: content
        anchors.bottomMargin: -bottomPadding
        color: "black"
        opacity: 0.8

        MouseArea {
            // block events passing beneath the layout
            anchors.fill: parent
        }
    }

    Item {
        id: content
        width: parent.width
    }

    MouseArea {
        width: parent.width
        anchors.top: background.bottom
        anchors.bottom: parent.bottom
        onClicked: layout.dismiss()
    }
}
