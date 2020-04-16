/****************************************************************************************
**
** Copyright (c) 2019 Jolla Ltd.
** Copyright (c) 2019 Open Mobile Platform LLC
** All rights reserved.
**
** License: Proprietary.
**
****************************************************************************************/
import QtQuick 2.6
import Sailfish.Silica 1.0

Row {
    id: root

    property alias icon: mimeIcon
    property alias fileName: fileNameLabel.text
    property string mimeType: fileInfo ? fileInfo.mimeType : ""
    property int fileSize: fileInfo ? fileInfo.size : -1
    property real leftMargin: Theme.horizontalPageMargin
    property real rightMargin: Theme.horizontalPageMargin

    property var fileInfo

    width: parent.width
    leftPadding: leftMargin
    rightPadding: rightMargin
    spacing: Theme.paddingMedium

    Image {
        id: mimeIcon

        y: parent.height/2 - height/2
        source: Theme.iconForMimeType(root.mimeType)
    }

    Column {
        y: parent.height/2 - height/2
        width: parent.width - root.leftMargin - root.rightMargin - mimeIcon.width

        Label {
            id: fileNameLabel

            width: parent.width
            truncationMode: TruncationMode.Fade
            color: Theme.highlightColor
            text: root.fileInfo ? root.fileInfo.fileName : ""
        }

        Label {
            text: root.fileSize >= 0 ? Format.formatFileSize(root.fileSize) : ""
            visible: text.length > 0
            width: parent.width
            truncationMode: TruncationMode.Fade
            color: Theme.secondaryHighlightColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }
}
