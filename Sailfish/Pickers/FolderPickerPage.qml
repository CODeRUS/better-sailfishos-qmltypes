/****************************************************************************
**
** Copyright (c) 2021 Open Mobile Platform LLC.
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Nemo.FileManager 1.0
import "private"

Page {
    id: folderPicker

    // "Select location"
    // String defined in FilePickerPage.qml
    property string title: qsTrId("components_pickers-he-select_location")
    property string dialogTitle

    property alias showSystemFiles: partitionList.showSystemFiles
    property string selectedPath
    property var acceptDestination

    property int sortBy: FileModel.SortByName
    property int sortOrder: Qt.AscendingOrder
    property int directorySort: FileModel.SortDirectoriesWithFiles
    property int caseSensitivity: Qt.CaseSensitive

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: __silica_applicationwindow_instance.contentItem
        targetPage: folderPicker
    }

    onStatusChanged: {
        if (page.status === PageStatus.Active) {
            acceptDestination = pageStack.previousPage(folderPicker)
        }
    }

    PartitionListView {
        id: partitionList

        header: PageHeader {
            title: folderPicker.title
        }

        onSelected: {
            var obj = pageStack.animatorPush(folderPickerDialog, {
                                                 title: folderPicker.dialogTitle,
                                                 path: info.path,
                                                 acceptDestination: folderPicker.acceptDestination
                                             })
        }
    }

    Component {
        id: folderPickerDialog
        FolderPickerDialog {
            allowedOrientations: folderPicker.allowedOrientations
            sortBy: folderPicker.sortBy
            sortOrder: folderPicker.sortOrder
            directorySort: folderPicker.directorySort
            caseSensitivity: folderPicker.caseSensitivity
            onAccepted: folderPicker.selectedPath = selectedPath
        }
    }
}
