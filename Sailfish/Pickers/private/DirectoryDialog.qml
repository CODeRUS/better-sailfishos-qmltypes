/****************************************************************************
**
** Copyright (C) 2017 Jolla Ltd.
** Contact: Raine Mäkeläinen <raine.makelainen@jolla.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Pickers 1.0
import Sailfish.FileManager 1.0
import Nemo.FileManager 1.0

PickerDialog {
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

    _clearOnBackstep: false

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: page
    }

    DirectoryListView {
        id: listView

        highlightSelected: true

        header: PickerDialogHeader {
            showBack: !_clearOnBackstep
            selectedCount: page._selectedCount
            _glassOnly: _background
        }

        model: FileModel {
            id: fileModel
            path: StandardPaths.home
            active: page.status === PageStatus.Active
            includeDirectories: true
            sortBy: FileModel.SortByName
            directorySort: FileModel.SortDirectoriesBeforeFiles

            // Include parent directory even if not shown, so we can differentiate empty from inaccessible
            includeParentDirectory: true

            onPopulatedChanged: {
                if (populated) {
                    var i = showParentDirectory ? 0 : 1
                    for (; i < count; ++i) {
                        var absolutePath = fileNameAt(i)
                        var selectedInSelectedModel = _selectedModel.selected(absolutePath)
                        if (selectedInSelectedModel) {
                            fileModel.toggleSelectedFile(i)
                        }
                    }
                }
            }
        }


        onClicked: {
            if (model.isDir) {
                var obj = pageStack.animatorPush('DirectoryDialog.qml', {
                                                     path: model.absolutePath,
                                                     includeHiddenFiles: fileModel.includeHiddenFiles,
                                                     sortBy: fileModel.sortBy,
                                                     sortOrder: fileModel.sortOrder,
                                                     directorySort: fileModel.directorySort,
                                                     nameFilters: fileModel.nameFilters,
                                                     caseSensitivity: fileModel.caseSensitivity,
                                                     _selectedModel: page._selectedModel,
                                                     acceptDestination: page.acceptDestination,
                                                     acceptDestinationAction: page.acceptDestinationAction,
                                                     _animationDuration: page._animationDuration,
                                                     _background: page._background,
                                                     _clearOnBackstep: false
                                                 })
                obj.pageCompleted.connect(function(nextPage) {
                    nextPage.accepted.connect(function() {
                        page._dialogDone(DialogResult.Accepted)
                    })
                })
            } else {
                fileModel.toggleSelectedFile(index)

                var fileItem = {
                    'url': "file://" + model.absolutePath,
                    'title': model.fileName,
                    'lastAccessed': model.accessed,
                    'lastModified': model.modified,
                    'filePath': model.absolutePath,
                    'fileName': model.fileName,
                    'fileSize': model.size,
                    'mimeType': model.mimeType,
                    'selected': model.isSelected,
                    'contentType': ContentType.File,
                    "fileModel": fileModel
                }

                if (_selectedModel) {
                    _selectedModel.update(fileItem)
                }
            }
        }
    }
}
