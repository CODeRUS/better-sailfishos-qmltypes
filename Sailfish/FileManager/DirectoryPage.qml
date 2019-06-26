import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0
import Sailfish.FileManager 1.0

Page {
    id: page

    property alias path: fileModel.path
    property string homePath
    property string title
    property string description
    property bool showFormat
    property bool showDeleteFolder

    property bool mounting
    property bool showNewFolder: true

    property alias sortBy: fileModel.sortBy
    property alias sortOrder: fileModel.sortOrder
    property alias caseSensitivity: fileModel.caseSensitivity
    property alias directorySort: fileModel.directorySort

    /*!
    \internal

    Implementation detail for file manager
    */
    property FileManagerNotification errorNotification

    signal formatClicked

    signal folderDeleted(string path)

    function refresh() {
        fileModel.refresh()
    }

    backNavigation: !FileEngine.busy

    Component.onCompleted: {
        if (!errorNotification) {
            errorNotification = errorNotificationComponent.createObject(page)
        }

        FileManager.init(pageStack)
        if (!FileManager.errorNotification) {
            FileManager.errorNotification = errorNotification
        }
    }

    FileModel {
        id: fileModel

        directorySort: FileModel.SortDirectoriesBeforeFiles

        path: homePath
        active: page.status === PageStatus.Active
        onError: {
            if (error == FileModel.ErrorReadNoPermissions) {
                //% "No permissions to access %1"
                errorNotification.show(qsTrId("filemanager-la-folder_no_permission_to_access").arg(fileName))

            }
        }
    }
    SilicaListView {
        opacity: {
            if (FileEngine.busy) {
                return 0.6
            } else if (page.mounting) {
                return 0.0
            } else {
                return 1.0
            }
        }
        Behavior on opacity { FadeAnimator {} }

        anchors.fill: parent
        model: fileModel

        RemorsePopup { id: remorse }

        PullDownMenu {
            MenuItem {
                //% "Format"
                text: qsTrId("filemanager-me-format")
                visible: showFormat
                onClicked: page.formatClicked()
            }

            MenuItem {
                //% "New folder"
                text: qsTrId("filemanager-me-new_folder")
                visible: page.showNewFolder
                onClicked: {
                    pageStack.animatorPush(Qt.resolvedUrl("NewFolderDialog.qml"), { path: page.path })
                }
            }

            MenuItem {
                //% "Delete folder"
                text: qsTrId("filemanager-me-delete_folder")
                visible: page.showDeleteFolder
                //% "Deleting folder"
                onClicked: remorse.execute(qsTrId("filemanager-la-deleting_folder"), function() {
                    FileEngine.deleteFiles(path, true)
                    folderDeleted(path)
                    pageStack.pop()
                })
            }


            MenuItem {
                //% "Sort"
                text: qsTrId("filemanager-me-sort")
                visible: fileModel.count > 0
                onClicked: {
                    var obj = pageStack.animatorPush(Qt.resolvedUrl("SortingPage.qml"))
                    obj.pageCompleted.connect(function(dialog) {
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
                                            pageStack.pop()
                                        }
                                    })
                    })
                }
                function pop() {
                    pageStack.pop()
                    fileModel.sortByChanged.disconnect(pop)
                    fileModel.sortOrderChanged.disconnect(pop)
                }
            }

            MenuItem {
                //% "Paste"
                text: qsTrId("filemanager-me-paste")
                visible: FileEngine.clipboardCount > 0
                onClicked: FileEngine.pasteFiles(page.path, true)
            }
        }

        header: PageHeader {
            title: path == homePath && page.title.length > 0 ? page.title
                                                             : page.path.split("/").pop()
            description: page.description
        }

        delegate: FileItem {
            id: fileItem

            function remove() {
                //% "Deleting"
                remorseAction(qsTrId("filemanager-la-deleting"), function() { FileEngine.deleteFiles(fileModel.fileNameAt(model.index), true) })
            }

            menu: contextMenu

            ListView.onRemove: if (page.status === PageStatus.Active) animateRemoval(fileItem)
            onClicked: {
                if (model.isDir) {
                    FileManager.openDirectory({
                                                  path: fileModel.appendPath(model.fileName),
                                                  homePath: page.homePath,
                                                  sortBy: page.sortBy,
                                                  sortOrder: page.sortOrder,
                                                  caseSensitivity: page.caseSensitivity,
                                                  directorySort: page.directorySort
                                              })
                } else {
                    var filePath = Qt.resolvedUrl(fileModel.path + "/" + model.fileName)
                    FileManager.openUrlExternally(filePath)
                }
            }

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        //% "Details"
                        text: qsTrId("filemanager-me-details")
                        onClicked: {
                            pageStack.animatorPush("DetailsPage.qml", {
                                               fileName: model.fileName,
                                               mimeType: model.mimeType,
                                               isDir: model.isDir,
                                               modified: model.modified,
                                               size: model.size
                                           })
                        }
                    }

                    MenuItem {
                        //% "Copy"
                        text: qsTrId("filemanager-me-copy")
                        onClicked: FileEngine.copyFiles([ fileModel.fileNameAt(model.index) ])
                    }

                    MenuItem {
                        visible: !model.isDir && !model.isLink
                        //% "Share"
                        text: qsTrId("filemanager-me-share")
                        onClicked: {
                            pageStack.animatorPush("Sailfish.TransferEngine.SharePage", {
                                               source: Qt.resolvedUrl(model.absolutePath),
                                               mimeType: model.mimeType,
                                               serviceFilter: ["sharing", "e-mail"]
                                           })
                        }
                    }

                    MenuItem {
                        //% "Delete"
                        text: qsTrId("filemanager-me-delete")
                        onClicked: remove()
                    }
                }
            }
        }
        ViewPlaceholder {
            enabled: fileModel.count === 0 && fileModel.populated
            //% "No files"
            text: qsTrId("filemanager-la-no_files")
        }
        VerticalScrollDecorator {}
    }

    Component {
        id: errorNotificationComponent

        FileManagerNotification {
            property var connections: Connections {
                target: FileEngine
                onError: {
                    switch (error) {
                    case FileEngine.ErrorOperationInProgress:
                        //% "File operation already in progress"
                        show(qsTrId("filemanager-la-operation_already_in_progress"))
                        break
                    case FileEngine.ErrorCopyFailed:
                        //% "Copying failed"
                        show(qsTrId("filemanager-la-copy_failed"))
                        break
                    case FileEngine.ErrorDeleteFailed:
                        //% "Deletion failed"
                        show(qsTrId("filemanager-la-deletion_failed"))
                        break
                    case FileEngine.ErrorMoveFailed:
                        //% "Moving failed"
                        show(qsTrId("filemanager-la-moving_failed"))
                        break
                    case FileEngine.ErrorRenameFailed:
                        //% "Renaming failed"
                        show(qsTrId("filemanager-la-renaming_failed"))
                        break
                    case FileEngine.ErrorCannotCopyIntoItself:
                        //% "You cannot copy a folder into itself"
                        show(qsTrId("filemanager-la-cannot_copy_folder_into_itself"))
                        break
                    case FileEngine.ErrorFolderCopyFailed:
                        //% "Copying folder failed"
                        show(qsTrId("filemanager-la-copying_folder_failed"))
                        break
                    case FileEngine.ErrorFolderCreationFailed:
                        //% "Could not create folder"
                        show(qsTrId("filemanager-la-folder_creation_failed"))
                        break
                    case FileEngine.ErrorChmodFailed:
                        //% "Could not set permission"
                        show(qsTrId("filemanager-la-set_permissions_failed"))
                        break
                    }
                }
            }
            property var busyView: BusyView {
                busy: FileEngine.busy
                enabled: busy || page.mounting
                text: {
                    if (page.mounting) {
                        //% "Mounting SD card"
                        return qsTrId("filemanager-la-mounting")
                    } else switch (FileEngine.mode) {
                        case FileEngine.DeleteMode:
                            //% "Deleting"
                            return qsTrId("filemanager-la-deleting")
                        case FileEngine.CopyMode:
                            //% "Copying"
                            return qsTrId("filemanager-la-copying")
                        default:
                            return ""
                    }
                }
            }
        }
    }
}
