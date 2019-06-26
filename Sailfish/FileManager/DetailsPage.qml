import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.FileManager 1.0

Page {

    property alias fileName: fileNameItem.value
    property alias mimeType: fileTypeItem.value
    property bool isDir
    property date modified
    property int size

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingMedium

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingSmall

            PageHeader {
                title: isDir ?
                               //% "Directory information"
                               qsTrId("filemanager-he-dir-info")
                               //% "File information"
                             : qsTrId("filemanager-he-file-info")
            }

            DetailItem {
                id: fileNameItem
                //% "Name"
                label: qsTrId("filemanager-he-name")
            }

            DetailItem {
                //% "Size"
                label: qsTrId("filemanager-he-size")
                value: Format.formatFileSize(size)
            }

            DetailItem {
                id: fileTypeItem
                //% "Type"
                label: qsTrId("filemanager-he-type")
            }

            DetailItem {
                //% "Modified"
                label: qsTrId("filemanager-he-modified")
                value: Format.formatDate(modified, Formatter.DateLong)
            }
        }

        VerticalScrollDecorator {}
    }
}
