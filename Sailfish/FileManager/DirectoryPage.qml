import QtQuick 2.0
import Sailfish.Silica 1.0
import Nemo.FileManager 1.0
import Sailfish.FileManager 1.0
import org.nemomobile.notifications 1.0
import org.nemomobile.contentaction 1.0

Page {
    id: page

    property alias path: fileModel.path
    property string homePath
    property string title
    property bool showFormat
    property Notification errorNotification

    signal formatClicked

    backNavigation: !FileEngine.busy

    Component.onCompleted: {
        if (!errorNotification) {
            errorNotification = errorNotificationComponent.createObject(page)
        }
    }

    FileModel {
        id: fileModel

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
        id: fileList

        opacity: FileEngine.busy ? 0.6 : 1.0
        Behavior on opacity { FadeAnimator {} }

        anchors.fill: parent
        model: fileModel

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
                onClicked: {
                    var dialog = pageStack.push(Qt.resolvedUrl("NewFolderDialog.qml"), { path: page.path })
                }
            }

            MenuItem {
                //% "Paste"
                text: qsTrId("filemanager-me-paste")
                visible: FileEngine.clipboardCount > 0
                onClicked: FileEngine.pasteFiles(page.path)
            }
        }

        header: PageHeader {
            title: path == homePath && page.title.length > 0 ? page.title
                                                             : page.path.split("/").pop()
        }

        delegate: ListItem {
            id: fileItem

            function remove() {
                //% "Deleting"
                remorseAction(qsTrId("filemanager-la-deleting"), function() { FileEngine.deleteFiles(fileModel.fileNameAt(model.index)) })
            }

            width: ListView.view.width
            contentHeight: Theme.itemSizeMedium
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
                        source: {
                            var iconSource
                            if (model.isDir) {
                                iconSource = "image://theme/icon-m-file-folder"
                            } else {
                                var iconType = "other"
                                switch (model.mimeType) {
                                case "application/vnd.android.package-archive":
                                    iconType = "apk"
                                    break
                                case "application/x-rpm":
                                    iconType = "rpm"
                                    break
                                case "text/vcard":
                                    iconType = "vcard"
                                    break
                                case "text/plain":
                                case "text/x-vnote":
                                    iconType = "note"
                                    break
                                case "application/pdf":
                                    iconType = "pdf"
                                    break
                                case "application/vnd.oasis.opendocument.spreadsheet":
                                case "application/x-kspread":
                                case "application/vnd.ms-excel":
                                case "text/csv":
                                case "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet":
                                case "application/vnd.openxmlformats-officedocument.spreadsheetml.template":
                                    iconType = "spreadsheet"
                                    break
                                case "application/vnd.oasis.opendocument.presentation":
                                case "application/vnd.oasis.opendocument.presentation-template":
                                case "application/x-kpresenter":
                                case "application/vnd.ms-powerpoint":
                                case "application/vnd.openxmlformats-officedocument.presentationml.presentation":
                                case "application/vnd.openxmlformats-officedocument.presentationml.template":
                                    iconType = "presentation"
                                    break
                                case "application/vnd.oasis.opendocument.text-master":
                                case "application/vnd.oasis.opendocument.text":
                                case "application/vnd.oasis.opendocument.text-template":
                                case "application/msword":
                                case "application/rtf":
                                case "application/x-mswrite":
                                case "application/vnd.openxmlformats-officedocument.wordprocessingml.document":
                                case "application/vnd.openxmlformats-officedocument.wordprocessingml.template":
                                case "application/vnd.ms-works":
                                    iconType = "formatted"
                                    break
                                default:
                                    if (mimeType.indexOf("audio/") == 0) {
                                        iconType = "audio"
                                    } else if (mimeType.indexOf("image/") == 0) {
                                        iconType = "image"
                                    } else if (mimeType.indexOf("video/") == 0) {
                                        iconType = "video"
                                    }
                                }
                                iconSource = "image://theme/icon-m-file-" + iconType
                            }
                            return iconSource + (highlighted ? "?" + Theme.highlightColor : "")
                        }
                    }
                }
                Column {
                    width: parent.width - parent.height - parent.spacing - Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: -Theme.paddingSmall
                    Label {
                        text: model.fileName
                        width: parent.width
                        font.pixelSize: Theme.fontSizeLarge
                        truncationMode: TruncationMode.Fade
                        color: highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                    Label {
                        property string dateString: Format.formatDate(model.modified, Formatter.DateLong)
                        text: model.isDir ? dateString
                                            //: Shows size and modification date, e.g. "15.5MB, 02/03/2016"
                                            //% "%1, %2"
                                          : qsTrId("filemanager-la-file_details").arg(Format.formatFileSize(model.size)).arg(dateString)
                        width: parent.width
                        truncationMode: TruncationMode.Fade
                        font.pixelSize: Theme.fontSizeSmall
                        color: highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                    }
                }
            }
            menu: contextMenu

            ListView.onRemove: animateRemoval(fileItem)
            onClicked: {
                if (model.isDir) {
                    pageStack.push(Qt.resolvedUrl("DirectoryPage.qml"),
                                   { path: fileModel.appendPath(model.fileName), homePath: page.homePath, errorNotification: page.errorNotification })
                } else {
                    var filePath = Qt.resolvedUrl(fileModel.path + "/" + model.fileName)
                    var ok = ContentAction.trigger(filePath)
                    if (!ok) {
                        switch (ContentAction.error) {
                        case ContentAction.FileTypeNotSupported:
                            //: Notification text shown when user tries to open a file of a type that is not supported
                            //% "Cannot open file, file type not supported"
                            errorNotification.show(qsTrId("filemanager-la-file_type_not_supported"))
                            break
                        case ContentAction.FileDoesNotExist:
                            //: Notification text shown when user tries to open a file but the file is not found locally.
                            //% "Cannot open file, file was not found"
                            errorNotification.show(qsTrId("filemanager-la-file_not_found"))
                            break
                        default:
                            //% "Error opening file"
                            errorNotification.show(qsTrId("filemanager-la-file_generic_error"))
                            break
                        }
                    }
                }
            }

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        //% "Copy"
                        text: qsTrId("filemanager-me-copy")
                        onClicked: FileEngine.copyFiles([ fileModel.fileNameAt(model.index) ])
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
            enabled: fileModel.count === 0
            //% "No files"
            text: qsTrId("filemanager-la-no_files")
        }
        VerticalScrollDecorator {}
    }
    Component {
        id: errorNotificationComponent
        Notification {
            category: "x-jolla.storage.error"
            function show(errorText) {
                previewSummary = errorText
                publish()
            }
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
                    }
                }
            }
            property var busyView: Loader {
                parent: __silica_applicationwindow_instance
                active: FileEngine.busy
                onActiveChanged: active = true // remove binding
                anchors.fill: parent

                sourceComponent: Rectangle {
                    id: busyView

                    enabled: FileEngine.busy
                    opacity: enabled ? 1.0 : 0.0
                    Behavior on opacity { FadeAnimator { duration: 400 } }
                    color: Theme.rgba("black",  0.9)
                    anchors.fill: parent

                    TouchBlocker {
                        anchors.fill: parent
                    }
                    Column {
                        id: busyIndicator
                        anchors.centerIn: parent
                        spacing: Theme.paddingLarge
                        InfoLabel {
                            text: {
                                switch (FileEngine.mode) {
 /*
                                // JB#34729: Uncomment after branching 2.0.2
                                case FileEngine.DeleteMode:
                                    //% "Deleting"
                                  return qsTrId("filemanager-la-deleting")
 */
                                case FileEngine.CopyMode:
                                    //% "Copying"
                                    return qsTrId("filemanager-la-copying")
                                default:
                                    return ""
                                }
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                        BusyIndicator {
                            anchors.horizontalCenter: parent.horizontalCenter
                            size: BusyIndicatorSize.Large
                            running: busyView.enabled
                        }
                    }
                }
            }
        }
    }

    WindowOverride {
        id: windowOverride
        active: FileEngine.busy
    }
}
