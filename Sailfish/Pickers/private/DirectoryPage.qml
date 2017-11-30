/****************************************************************************
**
** Copyright (C) 2016 Jolla Ltd.
** Contact: Matt Vogt <matthew.vogt@jollamobile.com>
**
****************************************************************************/

import QtQuick 2.0
import Sailfish.Silica 1.0
import Sailfish.Silica.private 1.0 as Private
import Sailfish.Pickers 1.0
import Sailfish.FileManager 1.0
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
    property bool showParentDirectory: false

    signal filePicked(var path)

    title: fileModel.directoryName

    orientationTransitions: Private.PageOrientationTransition {
        fadeTarget: _background ? listView : __silica_applicationwindow_instance.contentItem
        targetPage: page
    }

    function contentTypeForIcon(iconSource) {
        switch (iconSource) {
            case "image://theme/icon-m-file-image":
                return ContentType.Image
            case "image://theme/icon-m-file-audio":
                return ContentType.Music
            case "image://theme/icon-m-file-video":
                return ContentType.Video
            case "image://theme/icon-m-file-vcard":
                return ContentType.Person
            case "image://theme/icon-m-file-note":
            case "image://theme/icon-m-file-pdf":
            case "image://theme/icon-m-file-spreadsheet":
            case "image://theme/icon-m-file-presentation":
            case "image://theme/icon-m-file-formatted":
                return ContentType.Document
        }

        return ContentType.InvalidType
    }

    FileModel {
        id: fileModel
        path: StandardPaths.home
        includeDirectories: true
        sortBy: FileModel.SortByName
        directorySort: FileModel.SortDirectoriesBeforeFiles

        // Include parent directory even if not shown, so we can differentiate empty from inaccessible
        includeParentDirectory: true
    }

    SilicaListView {
        id: listView

        currentIndex: -1
        anchors.fill: parent

        header: PageHeader {
            title: page.title
        }

        model: fileModel

        delegate: FileItem {
            id: fileItem
            baseName: model.isDir ? model.fileName : model.baseName
            extension: model.isDir ? "" : (model.extension != "" ? "." + model.extension : "")
            size: model.size
            modified: model.modified
            iconSource: model.mimeType ? Theme.iconForMimeType(model.mimeType) : ""
            visible: !isParentDirectory || page.showParentDirectory

            Binding {
                when: !fileItem.visible
                target: fileItem
                property: 'height'
                value: 0
            }

            // Animations disabled because they occasionally cause the delegates to end up with zero height
            //ListView.onAdd: AddAnimation { target: fileItem; duration: _animationDuration }
            //ListView.onRemove: RemoveAnimation { target: fileItem; duration: _animationDuration }

            onClicked: {
                if (model.isDir) {
                    var nextPage = pageStack.push('DirectoryPage.qml', {
                        path: model.absolutePath,
                        includeHiddenFiles: fileModel.includeHiddenFiles,
                        sortBy: fileModel.sortBy,
                        sortOrder: fileModel.sortOrder,
                        directorySort: fileModel.directorySort,
                        nameFilters: fileModel.nameFilters,
                        caseSensitivity: fileModel.caseSensitivity
                    })
                    nextPage.filePicked.connect(page.filePicked)
                } else {
                    page.filePicked({
                        'url': model.absolutePath,
                        'title': model.fileName,
                        'lastAccessed': model.accessed,
                        'lastModified': model.modified,
                        'filePath': model.absolutePath,
                        'fileName': model.fileName,
                        'fileSize': model.size,
                        'mimeType': model.mimeType,
                        'selected': true,
                        'contentType': contentTypeForIcon(iconSource)
                    })
                }
            }
        }

        PullDownMenu {
            id: pdm

            property var closeAction
            onActiveChanged: {
                if (!active && closeAction) {
                    closeAction()
                    closeAction = undefined
                }
            }

            MenuItem {
                                                     //% "Hide hidden files"
                text: fileModel.includeHiddenFiles ? qsTrId("components_pickers-me-hide_hidden_files")
                                                     //% "Show hidden files"
                                                   : qsTrId("components_pickers-me-show_hidden_files")
                onClicked: pdm.closeAction = function() { fileModel.includeHiddenFiles = !fileModel.includeHiddenFiles }
            }
            MenuItem {
                //% "Sort"
                text: qsTrId("components_pickers-me-sort")
                visible: fileModel.count > 0
                onClicked: {
                    var dialog = pageStack.push(sortingPage)
                    dialog.selected.connect(
                        function(sortBy, sortOrder, directorySort) {
                            if (sortBy !== fileModel.sortBy || sortOrder !== fileModel.sortOrder) {
                                fileModel.sortBy = sortBy
                                fileModel.sortOrder = sortOrder
                                fileModel.directorySort = directorySort

                                // Wait for the changes to take effect
                                // before popping the sorting page
                                fileModel.sortByChanged.connect(pop)
                                fileModel.sortOrderChanged.connect(pop)
                            } else {
                                PageStack.pop()
                            }
                        }
                    )
                }
                function pop() {
                    pageStack.pop()
                    fileModel.sortByChanged.disconnect(pop)
                    fileModel.sortOrderChanged.disconnect(pop)
                }

                Component {
                    id: sortingPage

                    SortingPage {}
                }
            }
        }

        ViewPlaceholder {
            text: {
                if (page.nameFilters.length) {
                    //: Empty state text if no files match the filter
                    //% "No files match filter"
                    return qsTrId("components_pickers-ph-no_matching_files")
                }
                //: Empty state text if the directory contains no content
                //% "Empty folder"
                return qsTrId("components_pickers-ph-empty_folder")
            }
            enabled: fileModel.populated && fileModel.count == 1 && !page.showParentDirectory
        }

        ViewPlaceholder {
            //: Empty state text if the path is not readable by the application
            //% "The location cannot be accessed"
            text: qsTrId("components_pickers-ph-unreadable_location")
            enabled: fileModel.populated && fileModel.count == 0
        }

        VerticalScrollDecorator {}
    }
}
