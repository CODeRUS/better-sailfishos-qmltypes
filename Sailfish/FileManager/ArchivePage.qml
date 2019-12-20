import QtQuick 2.5
import Sailfish.Silica 1.0
import Sailfish.FileManager 1.0
import Nemo.FileManager 1.0

Page {
    id: page

    property alias path: extractor.path
    property alias archiveFile: extractor.archiveFile
    property alias fileName: extractor.fileName
    property alias baseExtractionDirectory: extractor.baseExtractionDirectory

    property string title
    property FileManagerNotification errorNotification

    signal archiveExtracted(string containingFolder)

    backNavigation: !extractor.model.extracting
    showNavigationIndicator: backNavigation

    Component.onCompleted: {
        if (!errorNotification) {
            errorNotification = errorNotificationComponent.createObject(page)
        }

        FileManager.init(pageStack)
    }

    SilicaListView {
        header: PageHeader {
            title: page.title.length > 0 ? page.title
                                         : fileName + (path != "/" ? path : "")
        }

        anchors.fill: parent
        delegate: FileItem {

            function cleanUp() {
                //% "Deleted extracted directory"
                var text = model.isDir ? qsTrId("filemanager-la-deleted_extracted_dir")
                                       : //% "Deleted extracted file"
                                         qsTrId("filemanager-la-deleted_extracted_file")
                remorseAction(text, function() {
                    FileEngine.deleteFiles(model.extractedTargetPath, true)
                    extractor.model.cleanExtractedEntry(model.fileName)
                })
            }

            menu: contextMenu
            onClicked: {
                if (model.extracted) {
                    if (model.isDir) {
                        var directory = FileManager.openDirectory({
                                                                      path: model.extractedTargetPath,
                                                                      initialPath: StandardPaths.home,
                                                                      showDeleteFolder: true,
                                                                      //% "Extracted folder"
                                                                      description: qsTrId("filemanager-he-extracted_folder")
                                                                  })
                        directory.folderDeleted.connect(function () {
                            extractor.model.cleanExtractedEntry(model.fileName)
                        })
                    } else {
                        Qt.openUrlExternally(FileManager.pathToUrl(model.extractedTargetPath))
                    }
                } else if (model.isDir) {
                    var obj = FileManager.openArchive(archiveFile, extractor.appendPath(model.fileName), baseExtractionDirectory)
                    obj.pageCompleted.connect(function(archivePage) {
                        archivePage.archiveExtracted.connect(page.archiveExtracted)
                    })
                } else {
                    openMenu()
                }
            }

            compressed: !model.extracted

            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        visible: !model.extracted
                        //% "Extract"
                        text: qsTrId("filemanager-me-extract")
                        onClicked: extractor.extractFile(model.fileName, model.isDir)
                    }

                    MenuItem {
                        visible: model.extracted
                        //% "Delete extracted directory"
                        text: model.isDir ? qsTrId("filemanager-me-delete_extracted_dir")
                                            //% "Remove extracted file"
                                          : qsTrId("filemanager-me-delete_extracted_file")
                        onClicked: cleanUp()
                    }
                }
            }
        }

        model: extractor.model

        PullDownMenu {
            visible: extractor.model.count > 0
            busy: extractor.model.extracting

            MenuItem {
                //% "Extract all"
                text: qsTrId("filemanager-me-extract_all")
                enabled: !parent.busy
                onDelayedClick: extractor.extractAllFiles()
            }
        }

        ViewPlaceholder {
            enabled: extractor.model.count === 0
            //% "No files"
            text: qsTrId("filemanager-la-no_files")
        }
        VerticalScrollDecorator {}

        Component {
            id: errorNotificationComponent

            FileManagerNotification {}
        }
    }

    ExtractorView {
        id: extractor

        onArchiveExtracted: page.archiveExtracted(containingFolder)
        onShowInfo: {
            if (!errorNotification) {
                errorNotification = errorNotificationComponent.createObject(page)
            }
            errorNotification.show(info)
        }
    }
}
