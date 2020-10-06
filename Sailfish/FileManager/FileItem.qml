/*
 * Copyright (c) 2018 – 2019 Jolla Ltd.
 * Copyright (c) 2019 Open Mobile Platform LLC.
 *
 * License: Proprietary
 */
import QtQuick 2.6
import Sailfish.Silica 1.0

Row {
    id: root

    property string fileName
    property string mimeType
    property double size
    property bool isDir
    property var created
    property var modified
    property bool compressed

    readonly property alias icon: icon
    property alias textFormat: nameLabel.textFormat

    width: parent.width
    height: Theme.itemSizeMedium
    spacing: Theme.paddingLarge

    Rectangle {
        width: height
        height: parent.height
        gradient: Gradient {
            // Abusing gradient for inactive mimeTypes
            GradientStop { position: 0.0; color: Theme.rgba(Theme.primaryColor, 0.1) }
            GradientStop { position: 1.0; color: "transparent" }
        }

        HighlightImage {
            id: icon

            anchors.centerIn: parent
            source: root.isDir
                    ? "image://theme/icon-m-file-folder"
                    : Theme.iconForMimeType(root.mimeType)
        }

        Image {
            anchors {
                top: parent.top
                right: parent.right
            }
            visible: compressed

            source: {
                var iconSource = "image://theme/icon-m-file-compressed"
                return iconSource + (highlighted ? "?" + Theme.highlightColor : "")
            }
        }
    }

    Column {
        width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter

        Label {
            id: nameLabel
            text: root.fileName
            width: parent.width
            truncationMode: TruncationMode.Fade
        }

        Label {
            property string dateString: Format.formatDate(root.modified || root.created, Formatter.DateLong)
            text: root.isDir ? dateString
                                //: Shows size and modification/created date, e.g. "15.5MB, 02/03/2016"
                                //% "%1, %2"
                              : qsTrId("filemanager-la-file_details").arg(Format.formatFileSize(root.size)).arg(dateString)
            width: parent.width
            truncationMode: TruncationMode.Fade
            font.pixelSize: Theme.fontSizeExtraSmall
            color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
            textFormat: nameLabel.textFormat
        }
    }
}
