/****************************************************************************
**
** Copyright (C) 2013 Jolla Ltd.
** Contact: Petri M. Gerdt <petri.gerdt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0

MouseArea {
    id: button

    property alias text: label.text
    property url iconSource

    width: parent.itemWidth
    height: parent.height

    onClicked: parent.selectedItem = button

    Rectangle {
        id: highlightBackground
        visible: parent.pressed && parent.containsMouse || button.parent.selectedItem == button

        anchors.fill: parent

        color: Theme.highlightBackgroundColor
    }

    Image {
        id: icon

        y: Theme.paddingLarge
        width: Theme.iconSizeLarge
        height: Theme.iconSizeLarge
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.5
        source: button.iconSource != "" ? button.iconSource + "?" + Theme.highlightDimmerColor : ""
    }
    Label {
        id: label
        anchors {
            left: parent.left
            top: icon.bottom
            right: parent.right
            margins: Theme.paddingMedium
        }
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.WordWrap
        color: "black"
        opacity: 0.5
    }
}
