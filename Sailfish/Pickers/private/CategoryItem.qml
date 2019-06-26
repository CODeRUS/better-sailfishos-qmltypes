/****************************************************************************
**
** Copyright (C) 2017 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.6
import Sailfish.Silica 1.0

BackgroundItem {
    property alias text: label.text
    property string iconSource

    width: ListView.view.width
    height: Theme.itemSizeMedium

    Row {
        anchors.fill: parent
        spacing: Theme.paddingLarge
        Rectangle {
            width: height
            height: parent.height
            gradient: Gradient {
                GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
                GradientStop { position: 1.0; color: "transparent" }
            }

            Image {
                anchors.centerIn: parent
                source: iconSource + (highlighted ? "?" + Theme.highlightColor : "")
            }
        }
        Label {
            id: label

            width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            truncationMode: TruncationMode.Fade
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
        }
    }
}


