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

    property string text
    property alias textFormat: label.textFormat
    property url iconSource
    property alias icon: icon
    property bool selected: parent && parent.selectedButton == button
    property bool highlight: (button.pressed && button.containsMouse) || button.selected

    width: parent ? parent.buttonWidth : label.implicitWidth + Theme.paddingMedium
    implicitHeight: label.y + label.height + Theme.paddingMedium

    onClicked: parent.selectedButton = button

    Rectangle {
        visible: (button.pressed && button.containsMouse)
        anchors.fill: parent
        color: Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
    }

    Image {
        id: icon

        y: Theme.paddingLarge
        width: Theme.iconSizeLarge
        height: Theme.iconSizeLarge
        anchors.horizontalCenter: parent.horizontalCenter
        source: button.iconSource != "" ? button.iconSource + "?" + (button.highlight ? Theme.highlightColor : Theme.primaryColor) : ""
    }
    Label {
        id: label
        anchors {
            left: button.left
            top: icon.bottom
            right: button.right
            margins: Theme.paddingMedium
        }
        text: button.text + "\n"
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: Theme.fontSizeExtraSmall
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
        color: button.highlight ? Theme.highlightColor : Theme.primaryColor
    }
}
