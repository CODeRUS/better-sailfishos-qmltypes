/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Nemo.FileManager 1.0

PickerPage {
    id: page

    property alias path: fileModel.path
    property alias includeDirectories: fileModel.includeDirectories
    property alias includeHiddenFiles: fileModel.includeHiddenFiles
    property alias includeSystemFiles: fileModel.includeSystemFiles
    property alias sortBy: fileModel.sortBy
    property alias sortOrder: fileModel.sortOrder
    property alias directorySort: fileModel.directorySort
    property alias nameFilters: fileModel.nameFilters
    property alias caseSensitivity: fileModel.caseSensitivity
    property alias showParentDirectory: listView.showParentDirectory

    signal filePicked(var path)

    title: fileModel.directoryName

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: page
    }

    DirectoryListView {
        id: listView

        header: PageHeader {
            title: page.title
        }

        model: FileModel {
            id: fileModel
            active: page.status === PageStatus.Active
            path: StandardPaths.home
            includeDirectories: true
            sortBy: FileModel.SortByName
            directorySort: FileModel.SortDirectoriesBeforeFiles

            // Include parent directory even if not shown, so we can differentiate empty from inaccessible
            includeParentDirectory: true
        }

        onClicked: {
            if (model.isDir) {
                var obj = pageStack.animatorPush('DirectoryPage.qml', {
                                                     path: model.absolutePath,
                                                     includeHiddenFiles: fileModel.includeHiddenFiles,
                                                     sortBy: fileModel.sortBy,
                                                     sortOrder: fileModel.sortOrder,
                                                     directorySort: fileModel.directorySort,
                                                     nameFilters: fileModel.nameFilters,
                                                     caseSensitivity: fileModel.caseSensitivity
                                                 })
                obj.pageCompleted.connect(function(nextPage) {
                    nextPage.filePicked.connect(page.filePicked)
                })
            } else {
                page.filePicked({
                                    'url': "file://" + model.absolutePath,
                                    'title': model.fileName,
                                    'lastAccessed': model.accessed,
                                    'lastModified': model.modified,
                                    'filePath': model.absolutePath,
                                    'fileName': model.fileName,
                                    'fileSize': model.size,
                                    'mimeType': model.mimeType,
                                    'selected': true,
                                    'contentType': listView.contentTypeForIcon(iconSource)
                                })
            }
        }
    }
}
