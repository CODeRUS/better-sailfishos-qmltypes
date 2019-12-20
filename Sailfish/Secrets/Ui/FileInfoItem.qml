import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Gallery 1.0

Row {
    property alias source: fileInfo.source

    x: Theme.horizontalPageMargin
    width: parent.width - 2 * x
    spacing: Theme.paddingMedium

    Image {
        id: mimeIcon
        source: Theme.iconForMimeType(fileInfo.mimeType)
        anchors.verticalCenter: parent.verticalCenter
    }

    Column {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width - mimeIcon.width

        Label {
            text: fileInfo.fileName
            width: parent.width
            wrapMode: Text.Wrap
            color: Theme.highlightColor
        }

        Label {
            text: Format.formatFileSize(fileInfo.size)
            width: parent.width
            wrapMode: Text.Wrap
            color: Theme.secondaryHighlightColor
            font.pixelSize: Theme.fontSizeSmall
        }
    }

    FileInfo {
        id: fileInfo
    }
}
