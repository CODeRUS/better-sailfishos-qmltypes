import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0

Page {
    id: root

    signal selected(int sortOrder, int sortBy, int directorySort)

    function qsTrIdStrings() {
        //% "Name ascending"
        QT_TRID_NOOP("filemanager-la-name_ascending")
        //% "Name descending"
        QT_TRID_NOOP("filemanager-la-name_descending")
        //% "Size"
        QT_TRID_NOOP("filemanager-la-size")
        //% "Date modified"
        QT_TRID_NOOP("filemanager-la-date_modified")
        //% "Extension"
        QT_TRID_NOOP("filemanager-la-extension")
    }

    SilicaListView {
        anchors.fill: parent
        header: PageHeader {
            //% "Sort"
            title: qsTrId("filemanager-he-sort")
        }
        model: ListModel {
            ListElement {
                sortOrder: Qt.AscendingOrder
                sortBy: FileModel.SortByName
                directorySort: FileModel.SortDirectoriesBeforeFiles
                label: "filemanager-la-name_ascending"
            }
            ListElement {
                sortOrder: Qt.DescendingOrder
                sortBy: FileModel.SortByName
                directorySort: FileModel.SortDirectoriesAfterFiles
                label: "filemanager-la-name_descending"
            }
            ListElement {
                sortOrder: Qt.AscendingOrder
                sortBy: FileModel.SortBySize
                directorySort: FileModel.SortDirectoriesAfterFiles
                label: "filemanager-la-size"
            }
            ListElement {
                sortOrder: Qt.AscendingOrder
                sortBy: FileModel.SortByModified
                directorySort: FileModel.SortDirectoriesBeforeFiles
                label: "filemanager-la-date_modified"
            }
            ListElement {
                sortOrder: Qt.AscendingOrder
                sortBy: FileModel.SortByExtension
                directorySort: FileModel.SortDirectoriesBeforeFiles
                label: "filemanager-la-extension"
            }
        }
        delegate: BackgroundItem {
            onClicked: root.selected(sortBy, sortOrder, directorySort)

            height: Math.max(Theme.itemSizeSmall, sortingLabel.height+2*Theme.paddingMedium)
            Label {
                id: sortingLabel
                anchors.verticalCenter: parent.verticalCenter
                x: Theme.horizontalPageMargin
                width: parent.width - 2*x
                wrapMode: Text.Wrap
                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                text: qsTrId(label)
            }
        }
    }
}
