/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

BackgroundItem {
    id: backgroundItem

    property string baseName
    property string extension
    property var size
    property var modified
    property string iconSource
    property bool selected
    property real leftMargin: Theme.horizontalPageMargin
    property bool isParentDirectory: baseName == '..' && extension == ''
    property alias textFormat: nameLabel.textFormat

    property string _iconSource: isParentDirectory ? 'image://theme/icon-m-page-up' : iconSource

    width: ListView.view.width
    height: Theme.itemSizeMedium
    highlighted: down || selected
    _showPress: false

    HighlightItem {
        anchors.fill: parent
        highlightOpacity: Theme.highlightBackgroundOpacity
        active: highlighted
    }

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
                source: backgroundItem._iconSource + (highlighted ? "?" + Theme.highlightColor : "")
            }
        }
        Column {
            visible: !backgroundItem.isParentDirectory
            width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            Label {
                id: nameLabel
                text: backgroundItem.baseName + backgroundItem.extension
                width: parent.width
                truncationMode: TruncationMode.Fade
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
            }
            Label {
                property string dateString: Format.formatDate(backgroundItem.modified, Formatter.DateLong)
                text: model.isDir ? dateString
                                    //: Shows size and modification date, e.g. "15.5MB, 02/03/2016"
                                    //% "%1, %2"
                                  : qsTrId("components_pickers-la-file_details").arg(Format.formatFileSize(backgroundItem.size)).arg(dateString)
                width: parent.width
                truncationMode: TruncationMode.Fade
                font.pixelSize: Theme.fontSizeExtraSmall
                color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                textFormat: nameLabel.textFormat
            }
        }
        Label {
            visible: backgroundItem.isParentDirectory
            //% "Parent folder"
            text: qsTrId("components_pickers-la-parent_folder")
            width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            truncationMode: TruncationMode.Fade
            color: highlighted ? Theme.highlightColor : Theme.primaryColor
        }
    }
}
